<#
.SYNOPSIS
Moves data from one share to another.

.DESCRIPTION
The Move-ShareData function will use robocoppy to move all files from one share to another, keeping in tact all NTFS permissions.

All copy operations are logged to a log file you specify.

Upon script completion, the log file will be emailed to an email address you specify.

Robocopy uses the following switches
/MOVE - Moves files and directories Delete from source after copying)
/ZB - Copies files using restartable model if access denied, use backup mode.
/E - Copies subdirectories, including empty ones.
/SEC - Copies files with security
/MT:25 - Increases max threads to 25 (default:8)
/R:3 - Max retries 3
/LOG - Logs output
/TEE - Sends output to screen as well as log

The log file is created under C:\Windows\Temp\<ShareName>.log
E.g. C:\Windows\Temp\Home.log


.PARAMETER SourcePath
The full path of the share that contains the contents you want to move.
E.g. C:\Shares\Home
E.g. \\SVR-FP-01\Home$

Note: If using a UNC path, ensure you have appropriate share permissions to access the share.

.PARAMETER DestinationPath
The full path of the root directory to where you wish to move the files.
E.g. C:\Shares\Home
E.g \\SVR-FP-01\Home$

Note: If using a UNC path, ensure you have appropriate share permissins to access and modify the share.

.PARAMETER EmailAddress
The email address of where you wish to send the log file and completion notification.

.EXAMPLE
Move data from the local folder C:\Shares\Home to the destination folder on \\SVR-FP-02\Home$

Move-DataShare.ps1 -SourcePath C:\Shares\Home -DestinationPath \\SVR-FP-02\Home$ -EmailAddress casey@hotlineit.com

.EXAMPLE
Move data from the remote share \\SVR-FP-01\Home$ to the local destination folder D:\Shares\Home

Move-DataShare.ps1 -SourcePath \\SVR-FP-01\Home$ -DestinationPath D:\Shares\Home -EmailAddress casey@hotlineit.com

#>

param (
    [Parameter(Mandatory=$True)][string]$SourcePath,
    [Parameter(Mandatory=$True)][string]$DestinationPath,
    [Parameter(Mandatory=$True)][string]$EmailAddress

)

# Make sure source and destination directories exist
if (Test-Path $SourcePath -eq $False) { Write-Error "Unable to locate $SourcePath. Please check the directory exists, and try again"; Exit }
if (Test-Path $DestinationPath -eq $False) { Write-Error "Unable to locate $DestinationPath. Please check the directory exists, and try again"; Exit }
$SourceDir = Get-Item $SourcePath

# Check for trailing backslash on the directory name
if ($Destinationpath.EndsWith("\") -eq $False) { $DestinationPath = $DestinationPath + "\" }

$LogFile = "C:\Windows\Temp\" + $Sourcedir.Name + ".log"

Write-Output "Copying $SourcePath to $DestinationPath"

# Record the start time
$StartTime = Get-Date

# Perform the copy operation
robocopy $SourcePath $DestinationPath /MOVE /ZB /E /SEC /MT:25 /R:3 /W:5 /LOG:$Logfile /TEE

# record the end time
$EndTime = Get-Date

# Calculate time taken for the copy
$TimeDiff = New-TimeSpan -Start $starttime -End $EndTime
[decimal]$TimeDiffMin = [decimal]::round($Timediff.TotalMinutes,2)

# Define email body
$body = @"
Source Directory: $SourcePath
Destination Directory: $DestinationPath
Time Elapsed: $TimeDiffMin minutes
"@

# send email
Send-MailMessage -to $EmailAddress -from "filecopy@hotlineit.com" -SmtpServer "mx5.hotline.net.au" -Subject "Copy Completed - $SourcePath" -Body $body -Attachments $LogFile