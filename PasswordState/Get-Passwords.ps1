# Retrieve all passwords
$results = Invoke-Restmethod -Uri "https://vault.hotlineit.com/api/passwords/?apikey=8d9e4f3c76b2a55c4b98673aefd2753f&queryall&format=json"

# Display ADA NSW Passwords
$results | Where-Object { $_.TreePath -like "*ADA NSW*" } | Select TreePath, PasswordList, Title, Description, Username, Password