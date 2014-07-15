#$VM = "Automatic-2012"
Param(
    [Parameter(Mandatory=$True)]
    [Vmware.VIMAutomation.ViCore.Impl.V1.Inventory.VirtualMachineImpl]$VM
    )

$GuestUsername = "hotadmin"
$GuestPassword = ConvertTo-SecureString "Hotline68+1" -AsPlainText -Force
$PSCred = New-Object System.Management.Automation.PSCredential($GuestUsername,$GuestPassword)


# ====================================================================
# = Configure Page File =
# ====================================================================

# Change the drive letter of the CD-ROM to F:
Write-Output "Changing CD-ROM drive letter to F:"
$script = '(Get-WmiObject WIN32_CDROMDRIVE).Drive | ForEach-Object { $tmpDrive = mountvol $_ /L; mountvol $_ /D; $tmpDrive = $tmpDrive.Trim(); mountvol F: $tmpDrive }'
Invoke-VMScript -ScriptText $script -vm $VM -GuestCredential $PSCred > $null

# -- Configure the page file drive --
Write-Output "Configuring page file drive (bring online, initialize, format, assign drive letter D:\)"
# Bring online, initalize, format and assign drive letter (D:)
$Script = 'Get-Disk | Where-Object PartitionStyle -eq "RAW" | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -DriveLetter D -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "PAGE FILE" -Confirm:$False'
Invoke-VMScript -ScriptText $script -vm $VM -GuestCredential $PSCred > $null

# -- Configure page file in OS --
#  Disable automatic page file on all drives
Write-Output "Disabling automatic page file management on all drives"
$script = 'Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges | Set-WmiInstance -Arguments @{AutomaticManagedPageFile=$False}'
Invoke-VMScript -ScriptText $script -vm $VM -GuestCredential $PSCred > $null

# Delete paging file on C:\
Write-Output "Deleting page file on C:\pagefile.sys"
$script = "(Get-WmiObject -Query ""SELECT * FROM Win32_PageFileSetting WHERE Name='c:\\pagefile.sys'"").Delete()"
Invoke-VMScript -ScriptText $script -vm $VM -GuestCredential $PSCred > $null

# Set page file on page file drive
Write-Output "Configuring page file on page file drive"
$InstalledRAM = (Get-VM $VM).MemoryMB #* 1.5
$Script = "Set-WmiInstance Win32_PageFileSetting -Arguments @{Name='D:\pagefile.sys'; InitialSize=$InstalledRAM; MaximumSize=$InstalledRAM}"
Invoke-VMScript -ScriptText $script -vm $VM -GuestCredential $PSCred > $null

# ====================================================================
# = Install LabTech Agent =
# ====================================================================

# - Create a new user for the labtech service

# - Download the labtech agent
Write-Output "Downloading LabTech Agent"
$script = '$wc = New-Object System.Net.WebClient; $wc.DownloadFile("https://labtech.hotline.net.au/labtech/deployment.aspx?PROBE=1&ID=1","$env:windir\Temp\LT_Agent.exe")'
Invoke-VMScript -ScriptText $script -vm $VM -GuestCredential $PSCred > $null

# - Install the agent
Write-Output "Installing LabTech Agent"
# Agent_Install.exe user_name=domain\username password=password /s


# ====================================================================
# = Configure local administrator =
# ====================================================================


# Set password never expires
Write-Output "Setting local administrator password to never expire"
$script = "Get-WmiObject -query ""SELECT * FROM Win32_UserAccount WHERE Name='Administrator'"" | Set-WmiInstance -Arguments @{PasswordExpires=0}"
Invoke-VMScript -ScriptText $script -vm $VM -GuestCredential $PSCred > $Nulll

# Generate the password
Write-Output "Generating random passsword"
Add-Type -AssemblyName System.Web
$length = 10
$numberOfNonAlphanumericCharacters = 2
$NewAdminPassword = [Web.Security.Membership]::GeneratePassword($length,$numberOfNonAlphanumericCharacters)
Write-Host "New Password: $NewAdminPassword"

# Set the password
Write-Output "Setting local administrator password"
$script = "([adsi]""WinNT://localhost/Administrator"").SetPassword(""$NewAdminPassword"")"
Invoke-VMScript -ScriptText $script -vm $VM -GuestCredential $PSCred > $null

# Update PSCreds
# $GuestUsername = "Administrator"
$GuestPassword = ConvertTo-SecureString $NewAdminPassword -AsPlainText -Force 
$PSCred = New-Object System.Management.Automation.PSCredential($GuestUsername,$GuestPassword)

# Rename administrator account to 'hotadmin'
Write-Output "Renaming local administrator to 'hotadmin'"
$script = "(Get-WMIObject -Query ""SELECT * FROM Win32_UserAccount WHERE Name='Administrator'"").Rename('hotadmin')"
Invoke-VMScript -ScriptText $script -vm $VM -GuestCredential $PSCred > $null

#
# = Disable UAC =
#
Write-Output "Disabling UAC ... "
Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\" -Name "EnableLUA" -Value 0


# ====================================================================
# = Reboot VM =
# ====================================================================
Write-Output "Restarting VM"
Restart-VMGuest $VM > $null

