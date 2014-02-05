Add-PSSnapin Microsoft.Exchange.Management.Powershell.E2010
Import-Module ActiveDirectory

$data = Invoke-WebRequest https://mpanel.myhotline.com.au/webservices/machpanelservice.asmx -method post -ContentType "text/xml" -InFile C:\HotlineIT\Scripts\MPanelSOAP_GetAllSubscriptions.txt
[xml]$xml = $data.content

$SubscriptionInfo = $XML.GetElementsByTagName("GetAllSubscriptionsResult").SubscriptionInfo
$ExchangeSubscriptionInfo = $SubscriptionInfo | Where-Object {($_.PackageName -eq "MyHotline Hosted Exchange") -and ($_.Status -eq "Active")}

$objResults = @()
$objErrorResults = @()

foreach ($Subscription in $ExchangeSubscriptionInfo) {
    [int]$Plan1=0
    [int]$Plan2=0
    [int]$Plan3=0
    [int]$Plan4=0
    [int]$Other=0
    
    # Replace . with _ to generate the OU for the company
    $OU = $Subscription.DomainName.Replace(".","_")
    Write-Output "Processing $OU"

    # Retrieve a list of all user accounts in the OU
    Try
    { 
        $UserAccounts = Get-ADUser -filter *  -SearchBase "OU=$OU,OU=Hosting,DC=myhotline,DC=com,DC=AU" -ErrorAction SilentlyContinue
    }

    Catch 
    {
        $objError = New-Object -TypeName PSObject
        $objError | Add-Member -MemberType NoteProperty -Name CompanyName -Value $Subscription.CompanyName
        $objError | Add-Member -MemberType NoteProperty -Name ErrorDetails -Value "An error occurred reading domain information for OU=$OU"
        $objError | Add-Member -MemberType NoteProperty -Name RecommendedAction -Value "Cross-reference this customer manually."
        $objErrorResults += $objError

Continue
    }

    
        
   # $Mailboxes = Get-Mailbox | Where-Object {$_.PrimarySMTPAddress -match $Subscription.DomainName}
    
   # foreach ($Mailbox in $Mailboxes) {
   ForEach ($User in $UserAccounts) {
        
        # Clear the error list
        $Error.clear()
        
        # Get mailbox information for the user account
        $Mailbox = Get-Mailbox -identity $user.SAMAccountName -ErrorAction Continue
        
        # If a non terminating error occurred (ie no mailbox for the user account), then skip to next user
        If ($error.count -gt 0) { Continue }

        Switch -Wildcard ($Mailbox.ProhibitSendQuota) 
        {
            "500 MB*" { $Plan1 += 1 }
            "5 GB*" { $Plan2 += 1 }
            "10 GB*" { $Plan3 += 1 }
            "25 GB*" { $Plan4 += 1 }
            Default { $Other += 1 }
        }
        
    }

    $objCustomer = New-Object -TypeName PSObject
    $objCustomer | Add-Member -MemberType NoteProperty -Name CompanyName -Value $Subscription.CompanyName
    $objCustomer | Add-Member -MemberType NoteProperty -Name FirstName -Value $Subscription.CustomerFirstName
    $objCustomer | Add-Member -MemberType NoteProperty -Name LastName -Value $Subscription.CustomerLastName
    $objCustomer | Add-Member -MemberType NoteProperty -Name DomainName -Value $Subscription.DomainName
    $objCustomer | Add-Member -MemberType NoteProperty -Name Plan1 -Value $Plan1
    $objCustomer | Add-Member -MemberType NoteProperty -Name Plan2 -Value $Plan2
    $objCustomer | Add-Member -MemberType NoteProperty -Name Plan3 -Value $Plan3
    $objCustomer | Add-Member -MemberType NoteProperty -Name Plan4 -Value $Plan4
    $objCustomer | Add-Member -MemberType NoteProperty -Name Other -Value $Other
    $objResults += $objCustomer


}

#$objResults | ft
$objResults = $objResults | Sort-Object CompanyName

# Generate the HTML Summary
$SummaryHTML = "<table><tr><th colspan=2>Summary</th></tr><tr><td>Report Generated: $(Get-Date -format 'd MMMM yyyy')</td></tr></table>"

# Add the header
$BodyHTML = "<table><tr><th>CompanyName</th><th>FirstName</th><th>LastName</th><th>DomainName</th><th>Plan1</th><th>Plan2</th><th>Plan3</th><th>Plan4</th><th>Other</th></tr>"

# Add the content
foreach ($Company in $objResults) {
    $tmpBodyHTML = ""
    $tmpBodyHTML += "<tr>"
    $tmpBodyHTML += "<td>$($Company.CompanyName)</td>"
    $tmpBodyHTML += "<td>$($Company.FirstName)</td>"
    $tmpBodyHTML += "<td>$($Company.LastName)</td>"
    $tmpBodyHTML += "<td>$($Company.DomainName)</td>"
    $tmpBodyHTML += "<td>$($Company.Plan1)</td>"
    $tmpBodyHTML += "<td>$($Company.Plan2)</td>"
    $tmpBodyHTML += "<td>$($Company.Plan3)</td>"
    $tmpBodyHTML += "<td>$($Company.Plan4)</td>"
    $tmpBodyHTML += "<td>$($Company.Other)</td>"
    $tmpBodyHTML += "</tr>"
    
    $BodyHTML += $tmpBodyHTML
    
}

$BodyHTML += "</table>"

$ErrorBodyHTML = "<table><tr><th>Error #</th><th>Company Name</th><th>Error Details</th><th>Recommended Action</th></tr>"

[int]$ErrorCount = 0
ForEach ($ErrorDetail in $objErrorResults)
{
    $ErrorCount += 1
    $tmpBodyHTML = ""
    $tmpBodyHTML += "<tr>"
    $tmpBodyHTML += "<td>$ErrorCount</td>"
    $tmpBodyHTML += "<td>$($ErrorDetail.CompanyName)</td>"
    $tmpBodyHTML += "<td>$($ErrorDetail.ErrorDetails)</td>"
    $tmpBodyHTML += "<td>$($ErrorDetail.RecommendedAction)</td>"
    $tmpBodyHTML += "</tr>"

    $ErrorBodyHTML += $tmpBodyHTML
}

$ErrorBodyHTML += "</table>"

$HTML = ConvertTo-Html -Body "$SummaryHTML $BodyHTML $ErrorBodyHTML" -Head "<h1>MyHotline Hosted Exchange Subscription List</h1><h2>by Hotline IT PTY LTD</h2><style> h1 {color: #3F4650; text-align: center;} h2 {color: #3F4650; text-align: center; font-size: 0.8em; } body {background-color: #F7F7F7; font-family: 'Trebuchet MS', Arial, Helvetica, sans-serif;} table {background-color: white; width: 80%; margin: 5px; padding: 5px; margin-left: auto; margin-right: auto; font-size: 0.8em; border-collapse:collapse;} td,th{font-size: 1em; border: 1px solid #3F4650; padding: 3px 7px 2px 7px; background-color #FFFFFF;} th {font-size: 1.1em; text-align:left; padding-top:5px; padding-bottom: 4px; background-color:#3F4650; color:#FFFFFF; } tr:nth-child(odd) {background-color: #F4F1EA; } </style>"
$HTML | Out-File $env:windir\LTSVC\scripts\MyHotlineHostedExchange_Report.html

Send-MailMessage -from "MyHotline Hosted Services <myhotline@hotlineit.com>" -to "accounts@hotlineit.com; Casey Mullineaux <casey@hotlineit.com>" -subject "MyHotline Hosted Exchange Report" -body "See attached for this months MyHotline Hosted Exchange report" -Attachments "$env:windir\LTSVC\scripts\MyHotlineHostedExchange_Report.html" -smtpServer mx5.hotline.net.au