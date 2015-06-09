

# Requirements:
# MySQL .NET connector
# http://dev.mysql.com/downloads/file.php?id=450594

function MySQLQuery
{
    Param(
      [Parameter(
      Mandatory = $true,
      ParameterSetName = '',
      ValueFromPipeline = $true)]
      [string]$Query
      )

    $MySQLAdminUserName = 'username'
    $MySQLAdminPassword = 'password'
    $MySQLDatabase = 'database'
    $MySQLHost = 'host'
    $ConnectionString = "server=" + $MySQLHost + ";port=3306;uid=" + $MySQLAdminUserName + ";pwd=" + $MySQLAdminPassword + ";database="+$MySQLDatabase

    Try {
      [void][System.Reflection.Assembly]::LoadWithPartialName("MySql.Data")
      $Connection = New-Object MySql.Data.MySqlClient.MySqlConnection
      $Connection.ConnectionString = $ConnectionString
      $Connection.Open()

      $Command = New-Object MySql.Data.MySqlClient.MySqlCommand($Query, $Connection)
      $DataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($Command)
      $DataSet = New-Object System.Data.DataSet
      $RecordCount = $dataAdapter.Fill($dataSet, "data")
      Return $DataSet.Tables[0]
      }

    Catch {
      Write-Host "ERROR : Unable to run query : $query `n$Error[0]"
     }

    Finally {
      $Connection.Close()
      }
}

Function Get-DiskUsage {
    param(
        [parameter(Mandatory=$True)][string]$ClientID
    )

$ComputerIDs = MySQLQuery("SELECT ComputerID from Computers WHERE ClientID = '$ClientID' AND OS LIKE '%SERVER%'")



$DiskResults = @()
foreach ($ComputerID in $ComputerIDs)
{
    $CompID = $computerid | Select-Object -ExpandProperty ComputerID

    $Query = @"
    SELECT Computers.ClientID, Computers.ComputerID, Computers.Name, Computers.OS, Ceiling(Sum(Drives.Size)/1024) As TotalDiskGB, Ceiling(Sum((Drives.Size)/1024)-(Drives.Free)/1024) As TotalUsedGB, Ceiling(Sum(Drives.Free)/1024) as TotalFreeGB
    FROM v_Computers, Drives
    INNER JOIN Computers

    WHERE v_Computers.ComputerID = Computers.ComputerID
    AND v_Computers.ComputerID = Drives.ComputerID
    AND Computers.ComputerID = '$CompID'
    AND Drives.Missing != '1'
    AND Drives.Size > '10240'
    AND Drives.FileSystem NOT IN ('CDFS','UNKFS','DVDFS','FAT','FAT32','NetFS')
    AND Drives.Model Not LIKE ('%USB%')
"@

    $Results = MySQLQuery($Query)

    $Object = New-Object PSObject -Property @{
        ClientID=$Results.ClientID
        ComputerID=$Results.ComputerID
        Name=$Results.Name
        OS=$Results.OS
        TotalDiskGB=$Results.TotalDiskGB
        TotalUsedGB=$Results.TotalUsedGB
        TotalFreeGB=$Results.TotalFreeGB
        }

    $DiskResults+= $Object
        
}

Return $DiskResults 

}
