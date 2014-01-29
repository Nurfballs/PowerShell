Import-Module ActiveDirectory

$ImportedUsers = Import-CSV C:\Hotline\signatures.csv 

ForEach ($User in $ImportedUsers)
{
    Write-Output "Processing $($User.SAMAccountName)"
    
    ForEach ($Property in $user.PSObject.Properties)
    {
        # If the field is blank in the CSV
        # set the value to null

        If ($Property.Value -eq "") { 
        # -- DEBUG -- Write-Output "Empty Value: $($user.SAMAccountName) ->  $($Property.Name)" } 
        $Property.Value = $null
        }

    }
    
    Set-ADUser -Identity $User.SamAccountName -Title $User.Title -MobilePhone $User.MobilePhone -StreetAddress $user.StreetAddress -City $user.City -State $user.State -PostalCode $user.PostalCode -Fax $User.Fax -OfficePhone $user.OfficePhone
}