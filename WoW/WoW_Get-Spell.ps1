$WebClient = New-Object net.webclient

# Spell Lookup
$SpellID = '148266'
$FeedURL = "http://us.battle.net/api/wow/spell/$SpellID"
$Spell = $WebClient.Downloadstring($FeedURL) | ConvertFrom-Json
Write-Output $Spell
