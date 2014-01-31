$VM = "Automatic-2012"

$GuestUsername = "Administrator"
$GuestPassword = ConvertTo-SecureString "Hotline68+1" -AsPlainText -Force
$PSCred = New-Object System.Management.Automation.PSCredential($GuestUsername,$GuestPassword)


# ====================================================================
# = Configure Page File =
# ====================================================================

# Change the drive letter of the CD-ROM to F:
$script = '(Get-WmiObject WIN32_CDROMDRIVE).Drive | ForEach-Object { $tmpDrive = mountvol $_ /L; mountvol $_ /D; $tmpDrive = $tmpDrive.Trim(); mountvol F: $tmpDrive }'
Invoke-VMScript -ScriptText $script -vm $VM -GuestCredential $PSCred

# -- Configure the page file drive --
# Bring online, initalize, format and assign drive letter (D:)
$Script = 'Get-Disk | Where-Object PartitionStyle -eq "RAW" | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -DriveLetter D -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "PAGE FILE" -Confirm:$False'
Invoke-VMScript -ScriptText $script -vm $VM -GuestCredential $PSCred

# -- Configure page file in OS --
#  Disable automatic page file on all drives
$script = 'Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges | Set-WmiInstance -Arguments @{AutomaticManagedPageFile=$False}'
Invoke-VMScript -ScriptText $script -vm $VM -GuestCredential $PSCred

# Delete paging file on C:\
$script = "(Get-WmiObject -Query ""SELECT * FROM Win32_PageFileSetting WHERE Name='c:\\pagefile.sys'"").Delete()"

# Set page file on page file drive
$InstalledRAM = (Get-VM $VM).MemoryMB #* 1.5
$Script = "Set-WmiInstance Win32_PageFileSetting -Arguments @{Name='D:\pagefile.sys'; InitialSize=$InstalledRAM; MaximumSize=$InstalledRAM}"
Invoke-VMScript -ScriptText $script -vm $VM -GuestCredential $PSCred

# ====================================================================
# = Install LabTech Agent =
# ====================================================================

# - Create a new user for the labtech service

# - Download the labtech agent
$script = '$wc = New-Object System.Net.WebClient; $wc.DownloadFile("https://labtech.hotline.net.au/labtech/deployment.aspx?PROBE=1&ID=1","$env:windir\Temp\LT_Agent.exe")'
Invoke-VMScript -ScriptText $script -vm $VM -GuestCredential $PSCred

# - Install the agent
# Agent_Install.exe user_name=domain\username password=password /s


# ====================================================================
# = Configure local administrator =
# ====================================================================


# Set password never expires
$script = "Get-WmiObject -query ""SELECT * FROM Win32_UserAccount WHERE Name='Administrator'"" | Set-WmiInstance -Arguments @{PasswordExpires=0}"
Invoke-VMScript -ScriptText $script -vm $VM -GuestCredential $PSCred

# Generate the password
Add-Type -AssemblyName System.Web
$length = 10
$numberOfNonAlphanumericCharacters = 2
$NewAdminPassword = [Web.Security.Membership]::GeneratePassword($length,$numberOfNonAlphanumericCharacters)
Write-Host "New Password: $NewAdminPassword"

# Set the password
$script = "([adsi]""WinNT://localhost/Administrator"").SetPassword(""$NewAdminPassword"")"
Invoke-VMScript -ScriptText $script -vm $VM -GuestCredential $PSCred

# Update PSCreds
$GuestUsername = "Administrator"
$GuestPassword = ConvertTo-SecureString $NewAdminPassword -AsPlainText -Force
$PSCred = New-Object System.Management.Automation.PSCredential($GuestUsername,$GuestPassword)

# Rename administrator account to 'hotadmin'
$script = "(Get-WMIObject -Query ""SELECT * FROM Win32_UserAccount WHERE Name='Administrator'"").Rename('hotadmin')"
Invoke-VMScript -ScriptText $script -vm $VM -GuestCredential $PSCred


# ====================================================================
# = Reboot VM =
# ====================================================================
Restart-VMGuest $VM

