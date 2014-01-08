param(
    [Parameter(Mandatory=$True)]
    [string]$VMName
)

Add-PSSnapin VMWare.VimAutomation.Core
Connect-VIServer localhost

#$VMName = "SVR-COLO-VO"

# Shutdown the guest
Get-VM $VMName | Shutdown-VMGuest -Confirm:$False
Write-Output "Stopping VM Guest"
Do { 
    Write-Output "Sleeping for 10 seconds ..."
    Start-Sleep -Seconds 10 
    $PowerState = Get-VM $VMName | Select-Object -ExpandProperty PowerState
}
While  ($PowerState -eq "PoweredOn")


# Upgrade VM Hardware
Set-VM -VM $VMName -Version v10 -Confirm:$False

# Change Network Adapters to VMXNET3
Get-VM $VMName | Get-NetworkAdapter | Set-NetworkAdapter -type Vmxnet3 -Confirm:$False

# Enable Copy-Paste
Get-VM $VMName | New-AdvancedSetting -Name isolation.tools.copy.disable -Value FALSE -Confirm:$false -Force:$true
Get-VM $VMName | New-AdvancedSetting -Name isolation.tools.paste.disable -Value FALSE -Confirm:$false -Force:$true


# Start the VM
Start-VM $VMName | Wait-Tools
Write-Output "Starting VM Guest"


# Update the VMWare Tools
Update-Tools $VMName