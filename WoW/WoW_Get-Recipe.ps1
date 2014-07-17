$WebClient = New-Object net.webclient

# Recipe Lookup
$RecipeID = '148290'
$FeedURL = "http://us.battle.net/api/wow/recipe/$RecipeID"
$Recipe = $WebClient.Downloadstring($FeedURL) | ConvertFrom-Json
Write-Output $Recipe
