Function Get-NewsFeed {
    param(
            [String]$Character,
            [String]$Realm
        )

#$Character = "Chunder"
#$Realm = "Blackrock"
Write-Host "Displaying news feed for $Character @ $Realm" -ForegroundColor Yellow


$FeedURL = "http://us.battle.net/api/wow/character/$Realm/$($Character)?fields=feed"
$WebClient = New-Object net.webclient
$Json = $WebClient.Downloadstring($FeedURL) | ConvertFrom-Json

$Events = $Json.Feed | Select-Object -First 20

foreach ($Event in $Events)
{
Switch ($Event.Type)
    {
        "ACHIEVEMENT" 
            { 
                Write-Host "Earned the achievement " -NoNewline
                Write-Host "[$($Event.Achievement.Title)]" -ForegroundColor Yellow
            }
        "CRITERIA" 
            {   Write-Host "Completed step " -nonewline
                Write-Host "[$($Event.criteria.description)] " -foregroundcolor Gray  -nonewline
                Write-Host "towards " -nonewline
                Write-Host "[$($Event.achievement.title)]"  -ForegroundColor Yellow
            }
        "BOSSKILL" 
            { 
                Write-Host "Killed " -nonewline
                Write-host "[$($Event.name)] " -NoNewline -ForegroundColor Red
                Write-Host "(x$($Event.quantity))"
            }
        "LOOT" 
            { 
                $FeedURL = "http://us.battle.net/api/wow/item/$($Event.ItemID)"
                $Item = $WebClient.Downloadstring($FeedURL) | ConvertFrom-Json
                
                Write-Host "Gained item " -NoNewline

                Switch ($Item.quality)
                    {
                        0 { $ItemColour = "Gray" }
                        1 { $ItemColour = "White" }
                        2 { $ItemColour = "Green" }
                        3 { $ItemColour = "Cyan" }
                        4 { $ItemColour = "Magenta" }
                        5 { $ItemColour = "Orange" }
                    }

                Write-Host "[$($Item.name)]" -ForegroundColor $ItemColour
            }
    }
}
}