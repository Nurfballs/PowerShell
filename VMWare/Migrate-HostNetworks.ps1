param (
    [Parameter(Mandatory=$True)][string]$VMHost,
   [Parameter(Mandatory=$True)][string]$ManagementIP
)

#$VMhost = "svr-inf-esxi1.hotline.net.au"
#$ManagementIP = "210.87.22.81"

# Add the VMWare Snappin
Try
{
    Write-Verbose "Loading VMWare PowerCLI snappins ... "
    Add-PSSnapin VMWare.VIMAutomation.Core
    Add-PSSnapin VMWare.VIMAutomation.VDS
}
Catch
{
    Write-Error "Unable to load VMWare PowerCLI snappin."
    Exit
}

Write-Output "Connecting to vCenter Server"
Connect-ViServer vc.hotline.net.au
Sleep 10

Write-Output "Enabling Maintenance Mode on $VMHost"
Set-VMHost "$VMHost" -state "Maintenance"

Write-Output "Creating new managemnet network vmkernal adapter on $VMHost"
Get-VMHost $VMHost | New-VMHostNetworkAdapter -VirtualSwitch "dvSwitch" -PortGroup "Infrastructure - Public Network" -IP $ManagementIP -SubnetMask "255.255.255.128" -ManagementTrafficEnabled:$true -Confirm:$False
#Get-VMHost "$ESXiHost" | New-VMHostNetworkAdapter -VirtualSwitch "vSwitch0" -PortGroup "MGMT Network" -IP "$New_MGMT_Network" -SubnetMask "$New_MGMT_Subnet" -ManagementTrafficEnabled:$true -Confirm:$false | out-nul


Write-Output "Changing vmkernal default gateway to new adapater (vmk2)"
Get-VMHost $VMHost | Get-VMHostNetwork | Set-VMHostNetwork -VMKernelGateway "210.87.22.1" -VMKernelGatewayDevice "vmk2"

Write-Output "Update public DNS for $VMHost to $ManagementIP Now" 
Write-Output "Update public DNS for $VMHost to $ManagementIP Now" 
Write-Output "Update public DNS for $VMHost to $ManagementIP Now" 


Write-Output "Rebooting $VMHost"
Restart-VMHost -VMHost $VMHost -Confirm:$False

# Wait for Server to show as down
do {
    sleep 15
    $ServerState = (get-vmhost $VMHost).ConnectionState
}
while ($ServerState -ne "NotResponding")

# Wait for server to reboot
Write-Host "$VMHost is Down"
 do {
    sleep 60
    $ServerState = (get-vmhost $VMHost).ConnectionState
    Write-Host "Waiting for Reboot ..."
}
while ($ServerState -ne "Maintenance")

Write-Host "$VMHost is back up"

 
Write-Output "Removing old management network from $VMHost"
Get-VMHostNetworkAdapter -VMHost $VMHost -name vmk0 | Remove-VMHostNetworkAdapter -Confirm:$False

Write-Output "Exiting maintenance mode"
Set-VMHost $VMHost -state "Connected" -RunAsync
