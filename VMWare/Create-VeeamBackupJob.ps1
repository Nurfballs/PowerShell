param (
    [Parameter(Mandatory=$true)][string]$CustomerID
)

# Load the Veeaem Powershell Snapin
Add-PsSnapin -Name VeeamPSSnapIn


# Find the resource pool matching the CustomerID
$respool = Find-VBRViEntity -ResourcePools -Server vsphere.hotline.net.au | Where-Object { $_.Name -eq $CustomerID }
$respool

# Define backup repository
$backuprepo = Get-VBRBackupRepository -Name "ReadyNAS4200 - Datacentre"
$backuprepo

# Create the job
$job = Add-VBRViBackupJob -Name "Hosted Customer - $CustomerID" -Entity $respool -BackupRepository $backuprepo

# Configure the backup job

 #Set schedule options
   #Create random backup time between 6PM and 4AM
   $Hours = (18,19,20,21,22,23,'00','01','02','03','04') | Get-Random | Out-String
   $Minutes = "{0:D2}" -f (Get-Random -Minimum 0 -Maximum 59) | Out-String
   $Time = ($Hours+':'+$Minutes+':00').replace("`n","")
      
   $JobScheduleOptions = $Job | Get-VBRJobScheduleOptions
      $JobScheduleOptions.OptionsDaily.Enabled = $true
      $JobScheduleOptions.OptionsDaily.Kind = "Everyday"
      $JobScheduleOptions.OptionsDaily.Time = $Time
      $JobScheduleOptions.NextRun = $Time
      $JobScheduleOptions.StartDateTime = $Time
Set-VBRJobScheduleOptions -Job $job -Options $JobScheduleOptions

$JobOptions = $job | Get-VBRJobOptions
$JobOptions.JobOptions.RunManually = $False
Set-VBRJobOptions -job $job -Options $JobOptions


   #Set VSS Options
<#
   $JobVSSOptions = $Job | Get-VBRJobVSSOptions
      $VSSUSername = 'DOMAIN\USERNAME'
      $VSSPassword = 'PASSWORD'
      $VSSCredentials = New-Object -TypeName Veeam.Backup.Common.CCredentials -ArgumentList $VSSUSername,$VSSPassword,0,0
      $JobVSSOptions.Credentials = $VSSCredentials
      $JobVSSOptions.Enabled = $true
      #Change default behavior per job object
      foreach ($JobObject in ($Job | Get-VBRJobObject))
         {
         $ObjectVSSOptions = Get-VBRJobObjectVssOptions -ObjectInJob $JobObject
         $ObjectVSSOptions.IgnoreErrors = $true
         Set-VBRJobObjectVssOptions -Object $JobObject -Options $ObjectVSSOptions
         }
   $Job | Set-VBRJobVssOptions -Options $JobVSSOptions
#>


