param(
    [Parameter(Mandatory=$True)][string]$CustomerID,
    [Parameter(Mandatory=$True)][string]$VMName,
    [Parameter(Mandatory=$True)][ValidatePattern("\b(Standard|Professional|None)\b")][string]$VMHostingPlan,
    [int64]$VMMemoryGB,
    [int32]$VMNumCPU
    )

$VM = $null
# Validate Input and determine resources based on hosting plan

Write-Output "Validating parameters ..."
switch ($VMHostingPlan)
{
    "Standard" { $VMMemoryGB = 2; $VMNumCPU = 1 }
    "Professional" { $VMMemoryGB = 4; $VMNumCPU = 2  }
    "None" 
    { 
       if(($VMMemoryGB -eq "") -or ($VMNumCPU -eq "")) 
        {
            Write-Error "You must either specify a Hosting Plan, or Memory/CPU to assign to the VM. Exiting script."
            Exit;
         } 
    }
}

[int]$VMPageDiskGB = $VMMemoryGB * 1.5

# Add the VMWare Snappin
Add-PSSnapin VMWare.VIMAutomation.Core
Add-PSSnapin VMWare.VIMAutomation.VDS

# Connect to the VC Server
Connect-VIServer vc.hotline.net.au


# Verify the customer has been setup correctly.
If ((Get-Folder -Name $CustomerID -ErrorAction SilentlyContinue) -eq $null) { Write-Error "No folder found for $CustomerID"; exit }
If ((Get-ResourcePool -Name $CustomerID -ErrorAction SilentlyContinue) -eq $null) { Write-Error "No resouce pool found for $CustomerID"; exit }
If ((Get-VDPortGroup -Name "Hosted Customer - $CustomerID" -ErrorAction SilentlyContinue) -eq $null) { Write-Error "No port group found for $CustomerID"; exit }

# Gather information from VMWare
$Folder = Get-Folder -Name $CustomerID
$datastorecluster = Get-DatastoreCluster -Name "VNX-SAS Cluster"
$vm_template = Get-Template -Name "TEMPL_WindowsSeverStandard2012R2"
$ResourcePool = Get-ResourcePool -Name $CustomerID
$OSCustomSpec = Get-OSCustomizationSpec -Name "Windows Server 2012"
$dvPortGroup = Get-VDPortgroup -Name "Hosted Customer - $CustomerID"

# Create the VM
Write-Output "Creating virtual machine $VMName"
$VM = New-VM -Name $VMName -ResourcePool $ResourcePool -Template $vm_template  -OSCustomizationSpec $OSCustomSpec  -Location $Folder -datastore "VNX NL-SAS"  #-Whatif #-NetworkName "Hosted Customer - $CustomerID" -WhatIf

# Assign Tag
Write-Output "Assigning customer tag"
New-TagAssignment -Entity $VM -Tag $CustomerID > $null

# Change resources based on plan
Write-Output "Configuring memory and cpu"
Set-VM $VM -NumCpu $VMNumCPU -MemoryGB $VMMemoryGB -confirm:$False > $null

# Change network adapater for correct network
Write-Output "Configuring network adapater for correct VLAN"

Get-VM $VM -Location $Folder -Tag $CustomerID | Get-NetworkAdapter | Set-NetworkAdapter -Portgroup $dvPortGroup -Confirm:$False > $Null
Get-VM $VM -Location $Folder -Tag $CustomerID | Get-NetworkAdapter | Set-NetworkAdapter -StartConnected $True -Confirm:$False > $Null

# Create page file hard disk
Write-Output "Creating page file disk"
New-HardDisk -CapacityGB $VMPageDiskGB -StorageFormat Thin -persistence Persistent -disktype Flat -vm $VM > $null

Write-Output "Booting virtual machine"

# wait until the VM has started
Start-VM $VM -Confirm:$False -ErrorAction:Stop > $null

Write-Output "Waiting for the VM to start ..."
while ($True)
{
    $vmEvents = Get-VIEvent -Entity $VM
    $startedEvent = $vmEvents | Where { $_.GetType().Name -eq "VMStartingEvent" }
    if ($startedEvent)
    {
        break
    }
    else
    {
        Start-Sleep -Seconds 5
    }
}

# wait until the customization process has started
Write-Output "Waiting for customization to start ..."
While ($True)
{
    $vmEvents = Get-VIEvent -Entity $VM
    $startedEvent = $vmEvents | Where { $_.GetType().Name -eq "CustomizationStartedEvent" }

    if ($startedEvent)
    {
        break
    }
    else 
    {
        Start-Sleep -Seconds 2
    }
}

# Wait until the customization process has completed or failed
Write-Output "Waiting for customization to complete ..."
While ($true)
{
    $vmEvents = Get-VIEvent -Entity $VM
    $succeedEvent = $vmEvents | where { $_.GetType().Name -eq "CustomizationSucceeded" }
    $failEvent = $vmEvents | Where { $_.GetType().Name -eq "CustomizationFailed" }

    if ($failEvent)
    {
        Write-Output "Customization Failed"
        break
        #return $false
    }

    if ($succeedEvent)
    {
        Write-Host "Customization completed successfully!"
        break
        #Return $true
    }

    Start-sleep -Seconds 2
}

