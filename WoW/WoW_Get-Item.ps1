$WebClient = New-Object net.webclient

# Item Lookup
$ItemID = '104219'
$FeedURL = "http://us.battle.net/api/wow/item/$ItemID"
$Item = $WebClient.Downloadstring($FeedURL) | ConvertFrom-Json
Write-Output $Item
