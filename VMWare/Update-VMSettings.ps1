param(
    [Parameter(Mandatory=$True)]
    [string]$VMName
)

Add-PSSnapin VMWare.VimAutomation.Core
Connect-VIServer localhost

#$VMName = "SVR-COLO-VO"

# Shutdown the guest
Get-VM $VMName | Shutdown-VMGuest 
Start-Sleep -Seconds 60

# Upgrade VM Hardware
Set-VM -VM $VMName -Version v10

# Change Network Adapters to VMXNET3
Get-VM $VMName | Get-NetworkAdapter | Set-NetworkAdapter -type Vmxnet3

# Enable Copy-Paste
Get-VM $VMName | New-AdvancedSetting -Name isolation.tools.copy.disable -Value FALSE -Confirm:$false -Force:$true
Get-VM $VMName | New-AdvancedSetting -Name isolation.tools.paste.disable -Value FALSE -Confirm:$false -Force:$true


# Start the VM
Start-VM $VMName
Start-Sleep -seconds 180

# Update the VMWare Tools
Update-Tools $VMName