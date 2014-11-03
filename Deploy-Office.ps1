#Map Deployment Share
NET USE z: \\192.168.0.1\DeploymentShare$ /user:vmdomain\Administrator pa55word!

# Get local machine serial number
$LocalSerialNumber = Get-WmiObject Win32_ComputerSystemProduct -ComputerName localhost | Select-Object -ExpandProperty IdentifyingNumber

# Import matching keys from spreadsheet
$keys = Import-CSV "Z:\Keys\Keys.csv" | Where-Object { $_.SerialNumber -eq $LocalSerialNumber }

# Create custom config.xml for Office Install
$ConfigFile = "Z:\Keys\$($LocalSerialNumber)\Office2010_Config.xml"
New-Item $ConfigFile -ItemType file -force

$OfficeKey = $keys.OfficeKey.Replace("-","")

Write-Output "<Configuration Product=`"SingleImage`">" | Out-File $ConfigFile -append
Write-Output "<Display Level=`"Basic`" CompletionNotice=`"No`" SuppressModal=`"No`" AcceptEula=`"Yes`" />" | Out-File $ConfigFile -append
Write-Output "<COMPANYNAME Value=`"Virtual Machine Networks`" />" | Out-File $ConfigFile -append
Write-Output "<Setting Id=`"SETUP_REBOOT`" Value=`"Never`" />" | Out-File $ConfigFile -append
Write-Output "<AddLanguage Id=`"match`" />" | Out-File $ConfigFile -append
Write-Output "<AddLanguage Id=`"en-us`" ShellTransform=`"Yes`" />" | Out-File $ConfigFile -append
Write-Output "<PIDKEY Value=`"$($OfficeKey)`" />" | Out-File $ConfigFile -append
Write-Output "</Configuration>" | Out-File $ConfigFile -append

If (!(Test-Path -path C:\Hotline)) { New-Item C:\Hotline -type Directory }
Copy-Item $ConfigFile "C:\Hotline\Office2010_Config.xml" -force

#Remove mapped drive
NET USE Z: /DELETE
