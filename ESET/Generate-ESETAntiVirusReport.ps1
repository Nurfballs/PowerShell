Function SQLQuery {

Param(
  [Parameter(
  Mandatory = $true,
  ParameterSetName = '',
  ValueFromPipeline = $true)]
  [string]$Query
  )

$MySQLAdminUserName = 'ltro'
$MySQLAdminPassword = 'LabTechReadOnly!'
$MySQLDatabase = 'labtech'
$MySQLHost = 'labtech.hotline.net.au'
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
  $DataSet.Tables[0]
  }

Catch {
  Write-Host "ERROR : Unable to run query : $query `n$Error[0]"
 }

Finally {
  $Connection.Close()
  }
 }
 
$SQLQuery=@"
SELECT software.ComputerID, software.Name, v_computers.Client_Company, v_computers.Computer_Name
FROM software
JOIN v_computers ON software.ComputerID = v_computers.ComputerID
AND (software.Name = 'ESET File Security' OR software.Name LIKE '%ESET%Antivirus%')
AND Client_Company <> 'Magna Systems and Engineering'

"@
$data = SQLQuery($SQLQuery)

$objResults = @()

$Companies = $data | Select-Object -ExpandProperty  Client_Company -Unique

foreach ($company in $companies) 
{
    # $company
    $ESETAV = $data | Where-Object { ($_.Client_Company -eq $company) -and ($_.Name -like "*ESET*Antivirus*") } | Measure-Object ComputerID
    $FileSecurity = $data | Where-Object { ($_.Client_Company -eq $company) -and ($_.Name -like "*File Security*") } | Measure-Object ComputerID
    
    $objCustomer = New-Object -TypeName PSObject
    $objCustomer | Add-Member -MemberType NoteProperty -Name CompanyName -Value $Company
    $objCustomer | Add-Member -MemberType NoteProperty -Name AntiVirus -Value $ESETAV.Count
    $objCustomer | Add-Member -MemberType NoteProperty -Name FileSecurity -Value $FileSecurity.Count
    $objResults += $objCustomer
}

$objResults = $objResults | Sort-Object CompanyName

# Generate the HTML Summary
$SummaryHTML = "<table><tr><th colspan=2>Summary</th></tr><tr><td>Report Generated: $(Get-Date -format 'd MMMM yyyy')</td></tr></table>"

# Add the header
$BodyHTML = "<table><tr><th>Company Name</th><th>ESET AntiVirus</th><th>File Security</th></tr>"

# Add the content
ForEach ($Company in $objResults)
{
    $tmpBodyHTML = ""
    $tmpBodyHTML += "<tr>"
    $tmpBodyHTML += "<td>$($Company.CompanyName)</td>"
    $tmpBodyHTML += "<td>$($Company.AntiVirus)</td>"
    $tmpBodyHTML += "<td>$($Company.FileSecurity)</td>"
    $tmpBodyHTML += "</tr>"
    
    $BodyHTML += $tmpBodyHTML
    
}

$BodyHTML += "</table>"

$HTML = ConvertTo-Html -Body "$SummaryHTML $BodyHTML" -Head "<h1>Hotline Monthly ESET AntiVirus Licence Report</h1><h2>by Hotline IT PTY LTD</h2><style> h1 {color: #3F4650; text-align: center;} h2 {color: #3F4650; text-align: center; font-size: 0.8em; } body {background-color: #F7F7F7; font-family: 'Trebuchet MS', Arial, Helvetica, sans-serif;} table {background-color: white; width: 80%; margin: 5px; padding: 5px; margin-left: auto; margin-right: auto; font-size: 0.8em; border-collapse:collapse;} td,th{font-size: 1em; border: 1px solid #3F4650; padding: 3px 7px 2px 7px; background-color #FFFFFF;} th {font-size: 1.1em; text-align:left; padding-top:5px; padding-bottom: 4px; background-color:#3F4650; color:#FFFFFF; } tr:nth-child(odd) {background-color: #F4F1EA; } </style>"
$HTML | Out-File $env:windir\LTSVC\scripts\ESETAntiVirusSubscriptionReport.html
Send-MailMessage -from "LabTech Automated Script <labtech@hotlineit.com>" -to "accounts@hotlineit.com; Casey Mullineaux <casey@hotlineit.com>" -subject "Hotine Monthly ESET Antivirus Licence Report" -body "See attached for this months ESET AntiVirus report" -Attachments "$env:windir\LTSVC\scripts\ESETAntiVirusSubscriptionReport.html" -smtpServer mx5.hotline.net.au

