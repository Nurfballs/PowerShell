$GuestUsername = "admin"
$GuestPassword = ConvertTo-SecureString "readwrite" -AsPlainText -Force
$PSCred = New-Object System.Management.Automation.PSCredential($GuestUsername,$GuestPassword)

$vm = Get-VM -Name XTMv -Location "TestCustomer"
Invoke-VMScript -ScriptText 'configure; interface FastEthernet 0; ip address 192.168.0.1/24 default-gw 192.168.0.254' -vm $vm -GuestUser 'admin' -GuestPassword 'readwrite' -ScriptType Bash

