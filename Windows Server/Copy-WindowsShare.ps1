<#
.SYNOPSIS
Gatheres the share information from a remote share, and creates the folder, and replicates the permissions on to a local folder.

.DESCRIPTION
The Copy-WindowsShare funtion will query the permissions of a share on a remote server, create a folder on the local machine, and apply the same share name and permissions.

.PARAMETER SourceComputer
A single computer name or IP address of the remote machine in which to query share permissions.

.PARAMETER ShareName
The name of the share on the remote computer in which to query share permissions. E.g. Home$

.PARAMETER DesintationPath
The full path to the folder location on the local machine in which you wish to recreate the share. E.g. D:\Shares\Home

.EXAMPLE
Read the share information for the Home$ share on SVR-FP-01 (\\SVR-FP-01\Home$), and recreate the share, and it's permissions to the local D:\Shares\Home folder.

Copy-SharePermissions -SourceComputer SVR-FP-01 -ShareName Home$ -DestinationPath D:\Shares\Home

#>

Param (
    [parameter(Mandatory=$True,HelpMessage="Source computer containing the shares you wish to copy.")][string]$SourceComputer,
    [parameter(Mandatory=$True,HelpMessage="The name of the share you wish to copy. eg. Home$")][string]$ShareName,
    [parameter(Mandatory=$True,HelpMessage="Full path of the destionation folder. eg. D:\Shares\Home")][string]$DestinationPath
)

function Get-SharePermissions 
{ 
        param([string]$computername,[string]$sharename) 
        $ShareSec = Get-WmiObject -Class Win32_LogicalShareSecuritySetting -ComputerName $computername 
        ForEach ($ShareS in ($ShareSec | Where {$_.Name -eq $sharename})) 
        { 
                $SecurityDescriptor = $ShareS.GetSecurityDescriptor() 
                $myCol = @() 
                ForEach ($DACL in $SecurityDescriptor.Descriptor.DACL) 
                { 
                        $myObj = "" | Select Domain, ID, AccessMask, AceType 
                        $myObj.Domain = $DACL.Trustee.Domain 
                        $myObj.ID = $DACL.Trustee.Name 
                        Switch ($DACL.AccessMask) 
                        { 
                                2032127 {$AccessMask = "FullControl"} 
                                1179785 {$AccessMask = "Read"} 
                                1180063 {$AccessMask = "Read, Write"} 
                                1179817 {$AccessMask = "ReadAndExecute"} 
                                -1610612736 {$AccessMask = "ReadAndExecuteExtended"} 
                                1245631 {$AccessMask = "ReadAndExecute, Modify, Write"} 
                                1180095 {$AccessMask = "ReadAndExecute, Write"} 
                                268435456 {$AccessMask = "FullControl (Sub Only)"} 
                                default {$AccessMask = $DACL.AccessMask} 
                        } 
                        $myObj.AccessMask = $AccessMask 
                        Switch ($DACL.AceType) 
                        { 
                                0 {$AceType = "Allow"} 
                                1 {$AceType = "Deny"} 
                                2 {$AceType = "Audit"} 
                        } 
                        $myObj.AceType = $AceType 
                        Clear-Variable AccessMask -ErrorAction SilentlyContinue 
                        Clear-Variable AceType -ErrorAction SilentlyContinue 
                        $myCol += $myObj 
                } 
        } 
        Return $myCol 
} 


New-SmbShare -Name $ShareName -Path $DestinationPath

# Get Full Access Users
$tmp = (Get-SharePermissions $SourceComputer $ShareName |  Where-Object AccessMask -eq "FullControl" | Select-Object -ExpandProperty ID )

if ($tmp -ne $null) {
    foreach ($user in $tmp) 
    {
       Grant-SmbShareAccess -Name $ShareName -AccountName $user -AccessRight Full -Confirm:$False
    }
}

#Get Modify Users
$tmp = (Get-SharePermissions $SourceComputer $ShareName |  Where-Object AccessMask -eq "ReadAndExecute, Modify, Write" | Select-Object -ExpandProperty ID )

if ($tmp -ne $null) {
    foreach ($user in $tmp) 
    {
       Grant-SmbShareAccess -Name $ShareName -AccountName $user -AccessRight Change -Confirm:$False
    }
}

#Get Read Only Users
$tmp = (Get-SharePermissions $SourceComputer $ShareName |  Where-Object AccessMask -eq "ReadAndExecute" | Select-Object -ExpandProperty ID )

if ($tmp -ne $null) {
    foreach ($user in $tmp) 
    {
       Grant-SmbShareAccess -Name $ShareName -AccountName $user -AccessRight Read -Confirm:$Fralse
    }
}

 
