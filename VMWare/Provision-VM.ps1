param(
    [Parameter(Mandatory=$True)][string]$CustomerID,
    [Parameter(Mandatory=$True)][string]$VMName,
    [Parameter(Mandatory=$True)][ValidatePattern("\b(Standard|Professional|None)\b")][string]$VMHostingPlan,
    [int64]$VMMemoryGB,
    [int32]$VMNumCPU
    )

$VM = $null

Write-Output "VM Hosting Plan: $VMHostingPlan"
Write-Progress -id 1 -Activity "Provisioning VM: $CustomerID\$VMName" -status "Validating parameters"

# Validate Input and determine resources based on hosting plan
Switch ($VMHostingPlan)
{
    "Standard" { $VMMemoryGB = 2; $VMNumCPU = 1; [int]$VMPageDiskGB = $VMMemoryGB * 1.5; Write-Output $VMMemoryGB }
    "Professional" { $VMMemoryGB = 4; $VMNumCPU = 2; [int]$VMPageDiskGB = $VMMemoryGB * 1.5 }
    "None" 
    { 
       if(($VMMemoryGB -eq "") -or ($VMNumCPU -eq "")) 
        {
            Write-Error "You must either specify a Hosting Plan, or Memory/CPU to assign to the VM. Exiting script."
            Exit;
         } 
    }
}

Write-Progress -id 1 -Activity "Provisioning VM: $CustomerID\$VMName" -status "Connecting to vCenter server"
# Add the VMWare Snappin
Add-PSSnapin VMWare.VIMAutomation.Core
Add-PSSnapin VMWare.VIMAutomation.VDS

# Connect to the VC Server
Connect-VIServer vc.hotline.net.au



Write-Progress -id 1 -Activity "Provisioning VM: $CustomerID\$VMName" -status "Gathering required information from vCenter"
$Folder = Get-Folder -Name $CustomerID
$datastorecluster = Get-DatastoreCluster -Name "VNX-SAS Cluster"

$vm_template = Get-Template -Name "TEMPL_WindowsSeverStandard2012R2"
$ResoucePool = Get-ResourcePool -Name $CustomerID
$OSCustomSpec = Get-OSCustomizationSpec -Name "Windows Server 2012"
$dvPortGroup = Get-VDPortgroup -Name "Hosted Customer - $CustomerID"

# Create the VM
Write-Progress -id 1 -Activity "Provisioning VM: $CustomerID\$VMName" -status "Creating virtual machine: $VMName"
$VMCloneTask = New-VM -Name $VMName -Location $folder  -ResourcePool $ResourcePool -Template $vm_template -OSCustomizationSpec $OSCustomSpec -Datastore "VNX NL-SAS" -RunAsync #-Whatif #-NetworkName "Hosted Customer - $CustomerID" -WhatIf
$VMCloneTask.Id

# Display progress while the clone task is occurring
While ($VMCloneTask.ExtensionData.Info.State -eq "running") {
    Write-Progress -id 2 -parentid 1 -Activity "Cloning virtual machine template" -PercentComplete (Get-Task -id $VMCloneTask.ID | Select-Object -ExpandProperty PercentComplete)
    Sleep 1
    $VMCloneTask.ExtensionData.UpdateViewData('Info.State')
}

$VM = Get-VM -Location $CustomerID -Name $VMName

# Change resources based on plan
Write-Progress -id 2 -ParentId 1 -Activity "Configuring memory and cpu"
Set-VM $VM -NumCpu $VMNumCPU -MemoryGB $VMMemoryGB -confirm:$False

# Change network adapater for correct network
Write-Progress -id 2 -ParentId 1 -Activity "Configuring network adapter for correct VLAN" 
Get-VM $VM | Get-NetworkAdapter | Set-NetworkAdapter -Portgroup $dvPortGroup -Confirm:$False -ErrorAction Ignore
Get-VM $VM | Get-NetworkAdapter | Set-NetworkAdapter -StartConnected -Confirm:$False -ErrorAction Ignore

# Create page file hard disk
Write-Progress -id 2 -ParentId 1 -Activity "Creating page file disk" 
New-HardDisk -CapacityGB $VMPageDiskGB -StorageFormat Thin -persistence Persistent -disktype Flat -vm $VM -ErrorAction Ignore

# Assign Tag
Write-Progress -id 2 -ParentId 1 -Activity "Assigning Customer Tag" 
New-TagAssignment -Entity $VM -Tag $CustomerID


Write-Progress -id 1 -Activity "Provisioning VM: $CustomerID\$VMName" -status "Booting virtual machine"
Start-VM $VM 


