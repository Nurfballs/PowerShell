param (
    [Parameter(Mandatory=$true)][string]$VMFolder,
    [Parameter(Mandatory=$true)][string]$VMName
)

Write-Output "Loading VMWare PowerCLI snappins ... "
Add-PSSnapin VMWare.VIMAutomation.Core
Add-PSSnapin VMWare.VIMAutomation.VDS
Remove-Module -Name Hyper-V


Write-Output "Connecting to vc.hotline.net.au"
Connect-VIServer vc.hotline.net.au | Out-Null

    
Write-Output "Gathering VM Object information"
# Get the VM Objec to modify
$VM = Get-Folder -Name $VMFolder | Get-VM -Name $VMName -ErrorAction Stop
    
# Shutdown the VM
Write-Output "Initiated shutdown of Guest VM: $VM"
Shutdown-VMGuest -VM $VM -Confirm:$False

# Wait for the VM to shutdown
do {
    Write-Output "Waiting for guest OS to shutdown..."
    sleep 15
    $VMPowerState = (get-VMGuest $VM).State
}
while ($VMPowerState -ne "NotRunning")
Write-Output "Guest OS is now shutdown"



# Change the ctk advanced setting to false
Write-Output "Changing VM scsi disk advanced settings to False"
$AdvancedSetting = Get-AdvancedSetting -Entity $VM | Where-Object Name -like *scsi*ctk*
ForEach ($Setting in $AdvancedSetting) { $Setting | Set-AdvancedSetting -Value 'false' -Confirm:$False }

# Remove the chk files from the datastore
# - Create custom powershell Datastore drive
$Datastore = Get-Datastore -Name "EMC VNX"
New-PSDrive -Location $Datastore -Name ds -PSProvider VimDatastore -Root '\'

# - Remove the checkpoint file for each disk.
Write-Output "Removing ctk files for each disk"
$vmhds = Get-HardDisk $VM
ForEach ($vmhd in $vmhds)
    {
        # Get the datastore location of the VMDK
        $filename = $vmhd.FileName
        $VMDKFolder = $filename.split(']')[1].split('/')[0].TrimStart()
        
        # Formulate the -ctk file name
        $ctkFilename = $filename.split(']')[1].split('/')[1].Replace(".vmdk","-ctk.vmdk")
                   
        # Remove the ctk file
        Write-Output "Deleted File: ds:\$VMDKFolder\$ctkFileName"
        Remove-Item ds:\$VMDKFolder\$ctkFileName
    }

# Remove custom drive
Remove-PSDrive -Name ds

# Power on the VM
Start-VM $VM
# - Wait for VM to start
do 
    {
        Write-Output "Waiting for guest OS to boot"
        sleep 15
        $VMPowerState = (Get-VMGuest $VM).State
    }
While ($VMPowerState -ne "Running")
Write-Output "Virtual Machine is now Powered On"

# Power off the VM
Stop-VM -VM $VM -Confirm:$False
# - Wait for the VM to shutdown
do {
    Write-Output "Waiting for guest OS to shutdown..."
    sleep 15
    $VMPowerState = (get-VMGuest $VM).State
}
while ($VMPowerState -ne "NotRunning")
Write-Output "Virtual Machine is now Powered Off"

# Change the ctk advanced setting to true
Write-Output "Changing VM scsi disk advanced settings to True"
$AdvancedSetting = Get-AdvancedSetting -Entity $VM | Where-Object Name -like *scsi*ctk*
ForEach ($Setting in $AdvancedSetting) { $Setting | Set-AdvancedSetting -Value 'true' -Confirm:$False }

# Power on the VM
Write-Output "Powering on the VM"
Start-VM $VM

Write-Output "Script Completed!"