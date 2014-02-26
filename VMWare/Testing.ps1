# Set credentials for SVR-COLO-BACK
$username = "hotadmin"
$password = ConvertTo-SecureString (Read-Host "Enter password to connect to SVR-COLO-BCK (hotadmin)") -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential("SVR-COLO-BCK\$username",$password)

# Create a new PS Session to SVR-COLO-BCK
$session = New-PSSession 210.87.22.64 -Credential $cred

$ScriptPath = (Split-Path ((Get-Variable MyInvocation).Value).MyCommand.Path)
$ScriptPath

# TO DO:
Invoke-Command -Session $session -FilePath "$ScriptPath\Create-VeeamBackupJob.ps1" -ArgumentList $CustomerID