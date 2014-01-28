# !! Must be run on a Domain Controller !! #
# !! or machine with AD module installed !! #

Import-Module ActiveDirectory

$DetailedUsers = @()

# ' Get a list of all enabled user accounts
$users = Get-ADUser -Filter {Enabled -eq "True"} -Properties SAMAccountName, GivenName, Surname, Title, MobilePhone, StreetAddress, City, State, PostalCode, Fax 

ForEach ($user in $users)
{
    # Get extended user account info
    $hash =  @{
        'SAMAccountName' = $user.SamAccountName
        'GivenName' = $user.GivenName
        'Surname' = $user.surname
        'Title' = $user.title
        'MobilePhone' = $user.Mobilephone
        'StreetAddress' = $user.StreetAddress
        'City' = $user.City
        'State' = $user.state
        'PostalCode' = $user.PostalCode
        'Fax' = $user.fax
    } 
    
    $DetailedUsers += New-Object -TypeName PSObject -Property $hash

    
           
    
}

# Export to CSV
 $DetailedUsers | Select-Object SAMAccountName, GivenName, Surname, Title, MobilePhone, StreetAddress, City, State, PostalCode, Fax  | Sort-Object Surname | Export-Csv C:\Hotline\280114_UserExport.csv -NoTypeInformation


