#$results = Invoke-Restmethod -Uri "https://vault.hotlineit.com/api/passwordlists/463?apikey=8d9e4f3c76b2a55c4b98673aefd2753f&format=json"

# Import CSV
$passwords = Import-Csv -Path I:\passwordimport.csv

$PasswordListID = "469"

foreach ($password in $passwords)
{

# Add a new password
$jsonString = @"
{
    "PasswordListID":"$PasswordListID",
    "Title":"$($password.title)",
    "Username":"$($password.username)",
    "password":"$($password.password)",
    "Description":"$($password.description)",
    "apikey":"8d9e4f3c76b2a55c4b98673aefd2753f"
}
"@

Invoke-RestMethod -Method POST -Uri "https://vault.hotlineit.com/api/passwords/" -ContentType "application/json" -Body $jsonString


}


