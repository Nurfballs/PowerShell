# Wowuction URL
$url = "http://www.wowuction.com/us/bloodscalp/alliance/Tools/RealmDataExportGetFileStatic?type=csv&token=Oq_4EsX7G1zjuxD7Fits0w2"

# Download the file
$workingdir = "C:\Windows\Temp"
$webclient = New-Object System.Net.WebCLient
$file = "$workingdir\wowuction.csv"
$webclient.DownloadFile($url,$file)

# Load the file
$items = Import-Csv $file


#$items | Where-Object { $_."Item Name" -like "*ruby*" } | Select-Object "Item Name", "Median Market Price StdDev", "PMktPrice StdDev"

$objGemPrices = @()


# Red Cuts
$redcuts = @("Delicate Primordial Ruby", "Brilliant Primordial Ruby", "Bold Primordial Ruby", "Precise Primordial Ruby", "Flashing Primordial Ruby")
$bluecuts = @("Sparkling River's Heart", "Rigid River's Heart", "Stormy River's Heart", "Solid River's Heart")
$orangecuts = @("Fierce Vermilion Onyx", "Deadly Vermilion Onyx", "Potent Vermilion Onyx", "Inscribed Vermilion Onyx", "Polished Vermilion Onyx", "Resolute Vermilion Onyx", "Stalwart Vermilion Onyx", "Champion's Vermilion Onyx", "Deft Vermilion Onyx", "Wicked Vermilion Onyx", "Reckless Vermilion Onyx", "Crafty Vermilion Onyx", "Adept Vermilion Onyx", "Keen Vermilion Onyx", "Artful Vermilion Onyx", "Fine Vermilion Onyx", "Skillful Vermilion Onyx", "Lucent Vermilion Onyx", "Tenuous Vermilion Onyx", "Willful Vermilion Onyx", "Splendid Vermilion Onyx", "Resplendent Vermilion Onyx")
$purplecuts = @("Glinting Imperial Amethyst", "Purified Imperial Amethyst", "Assassin's Imperial Amethyst", "Accurate Imperial Amethyst", "Mysterious Imperial Amethyst", "Veiled Imperial Amethyst", "Etched Imperial Amethyst", "Tense Imperial Amethyst", "Guardian's Imperial Amethyst", "Defender's Imperial Amethyst", "Shifting Imperial Amethyst", "Retailiating Imperial Amethyst", "Sovereign Imperial Amethyst", "Timeless Imperial Amethyst" )
$greencuts = @("Sensei's Wild Jade", "Lightning Wild Jade", "Piercing Wild Jade", "Misty Wild Jade", "Energized Wild Jade", "Radiant Wild Jade", "Puissant Wild Jade", "Zen Wild Jade", "Effulgent Wild Jade", "Jagged Wild Jade", "Forceful Wild Jade", "Confounded Wild Jade", "Vivid Wild Jade", "Shattered Wild Jade", "Regal Wild Jade", "Nimble Wild Jade", "Steady Wild Jade", "Turbid Wild Jade", "Balanced Wild Jade")
$yellowcuts = @("Smooth Sun's Radiance", "Quick Sun's Radiance", "Fractured Sun's Radiance", "Mystic Sun's Radiance", "Subtle Sun's Radiance")

#Red Cuts
Write-Output "Processing Red Cuts ..."
foreach ($cut in $redcuts)
    {
        
        $tmp = $cut.split(" ")
        $prefix = $tmp[0]
        $gem = $tmp[1] + " " + $tmp[2]
        

        $cutResults = $items | Where-Object { $_."Item Name" -like $cut } | Select-Object "Item Name", "Median Market Price StdDev", "PMktPrice StdDev"
        
        $perfectcut = "Perfect " + $prefix + " Pandarian Garnet"
        $perfectcutResults = $items | Where-Object { $_."Item Name" -eq $perfectcut } | Select-Object "Item Name", "Median Market Price StdDev", "PMktPrice StdDev"

        $objCutDetails = New-Object -TypeName psobject
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Colour" -Value "Red"
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Prefix" -Value $prefix
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Gem" -Value $Gem
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Cut Name" -Value $Cut
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Median Price" -Value $cutResults.'Median Market Price StdDev'
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Projected Price" -Value $cutresults.'PMktPrice StdDev'
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Perfect Cut Name" -Value $perfectcutresults.'Item Name'
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "PC Median Price" -Value $perfectcutResults.'Median Market Price StdDev'
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "PC Projected Price" -Value $perfectcutresults.'PMktPrice StdDev'
        $objGemPrices += $objCutDetails
    }

#Blue Cuts
Write-Output "Processing Blue Cuts ..."
foreach ($cut in $bluecuts)
    {
        
        $tmp = $cut.split(" ")
        $prefix = $tmp[0]
        $gem = $tmp[1] + " " + $tmp[2]
        

        $cutResults = $items | Where-Object { $_."Item Name" -like $cut } | Select-Object "Item Name", "Median Market Price StdDev", "PMktPrice StdDev"
        
        $perfectcut = "Perfect " + $prefix + " Lapis Lazuli"
        $perfectcutResults = $items | Where-Object { $_."Item Name" -eq $perfectcut } | Select-Object "Item Name", "Median Market Price StdDev", "PMktPrice StdDev"

        $objCutDetails = New-Object -TypeName psobject
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Colour" -Value "Blue"
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Prefix" -Value $prefix
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Gem" -Value $Gem
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Cut Name" -Value $Cut
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Median Price" -Value $cutResults.'Median Market Price StdDev'
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Projected Price" -Value $cutresults.'PMktPrice StdDev'
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Perfect Cut Name" -Value $perfectcutresults.'Item Name'
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "PC Median Price" -Value $perfectcutResults.'Median Market Price StdDev'
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "PC Projected Price" -Value $perfectcutresults.'PMktPrice StdDev'
        $objGemPrices += $objCutDetails
    }


#Orange Cuts
Write-Output "Processing Orange Cuts ..."
foreach ($cut in $orangecuts)
    {
        
        $tmp = $cut.split(" ")
        $prefix = $tmp[0]
        $gem = $tmp[1] + " " + $tmp[2]
        

        $cutResults = $items | Where-Object { $_."Item Name" -like $cut } | Select-Object "Item Name", "Median Market Price StdDev", "PMktPrice StdDev"
        
        $perfectcut = "Perfect " + $prefix + " Tiger Opal"
        $perfectcutResults = $items | Where-Object { $_."Item Name" -eq $perfectcut } | Select-Object "Item Name", "Median Market Price StdDev", "PMktPrice StdDev"

        $objCutDetails = New-Object -TypeName psobject
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Colour" -Value "Orange"
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Prefix" -Value $prefix
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Gem" -Value $Gem
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Cut Name" -Value $Cut
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Median Price" -Value $cutResults.'Median Market Price StdDev'
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Projected Price" -Value $cutresults.'PMktPrice StdDev'
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Perfect Cut Name" -Value $perfectcutresults.'Item Name'
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "PC Median Price" -Value $perfectcutResults.'Median Market Price StdDev'
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "PC Projected Price" -Value $perfectcutresults.'PMktPrice StdDev'
        $objGemPrices += $objCutDetails
    }

#Purple Cuts
Write-Output "Processing Purple Cuts ..."
foreach ($cut in $purplecuts)
    {
        
        $tmp = $cut.split(" ")
        $prefix = $tmp[0]
        $gem = $tmp[1] + " " + $tmp[2]
        

        $cutResults = $items | Where-Object { $_."Item Name" -like $cut } | Select-Object "Item Name", "Median Market Price StdDev", "PMktPrice StdDev"
        
        $perfectcut = "Perfect " + $prefix + " Roguestone"
        $perfectcutResults = $items | Where-Object { $_."Item Name" -eq $perfectcut } | Select-Object "Item Name", "Median Market Price StdDev", "PMktPrice StdDev"

        $objCutDetails = New-Object -TypeName psobject
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Colour" -Value "Purple"
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Prefix" -Value $prefix
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Gem" -Value $Gem
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Cut Name" -Value $Cut
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Median Price" -Value $cutResults.'Median Market Price StdDev'
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Projected Price" -Value $cutresults.'PMktPrice StdDev'
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Perfect Cut Name" -Value $perfectcutresults.'Item Name'
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "PC Median Price" -Value $perfectcutResults.'Median Market Price StdDev'
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "PC Projected Price" -Value $perfectcutresults.'PMktPrice StdDev'
        $objGemPrices += $objCutDetails
    }

#Green Cuts
Write-Output "Processing Green Cuts ..."
foreach ($cut in $greencuts)
    {
        
        $tmp = $cut.split(" ")
        $prefix = $tmp[0]
        $gem = $tmp[1] + " " + $tmp[2]
        

        $cutResults = $items | Where-Object { $_."Item Name" -like $cut } | Select-Object "Item Name", "Median Market Price StdDev", "PMktPrice StdDev"
        
        $perfectcut = "Perfect " + $prefix + " Alexandrite"
        $perfectcutResults = $items | Where-Object { $_."Item Name" -eq $perfectcut } | Select-Object "Item Name", "Median Market Price StdDev", "PMktPrice StdDev"

        $objCutDetails = New-Object -TypeName psobject
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Colour" -Value "Green"
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Prefix" -Value $prefix
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Gem" -Value $Gem
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Cut Name" -Value $Cut
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Median Price" -Value $cutResults.'Median Market Price StdDev'
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Projected Price" -Value $cutresults.'PMktPrice StdDev'
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Perfect Cut Name" -Value $perfectcutresults.'Item Name'
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "PC Median Price" -Value $perfectcutResults.'Median Market Price StdDev'
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "PC Projected Price" -Value $perfectcutresults.'PMktPrice StdDev'
        $objGemPrices += $objCutDetails
    }

#Yellow Cuts
Write-Output "Processing Yellow Cuts ..."
foreach ($cut in $yellowcuts)
    {
        
        $tmp = $cut.split(" ")
        $prefix = $tmp[0]
        $gem = $tmp[1] + " " + $tmp[2]
        

        $cutResults = $items | Where-Object { $_."Item Name" -like $cut } | Select-Object "Item Name", "Median Market Price StdDev", "PMktPrice StdDev"
        
        $perfectcut = "Perfect " + $prefix + " Sunstone"
        $perfectcutResults = $items | Where-Object { $_."Item Name" -eq $perfectcut } | Select-Object "Item Name", "Median Market Price StdDev", "PMktPrice StdDev"

        $objCutDetails = New-Object -TypeName psobject
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Colour" -Value "Yellow"
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Prefix" -Value $prefix
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Gem" -Value $Gem
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Cut Name" -Value $Cut
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Median Price" -Value $cutResults.'Median Market Price StdDev'
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Projected Price" -Value $cutresults.'PMktPrice StdDev'
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "Perfect Cut Name" -Value $perfectcutresults.'Item Name'
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "PC Median Price" -Value $perfectcutResults.'Median Market Price StdDev'
        $objCutDetails | Add-Member -MemberType NoteProperty -Name "PC Projected Price" -Value $perfectcutresults.'PMktPrice StdDev'
        $objGemPrices += $objCutDetails
    }



$objprofitablecuts = @()

$colours = @("Red", "Blue", "Green", "Purple", "Orange", "Yellow")

foreach ($colour in $colours)
    {
        
        $ProfitableCut = $objGemPrices | Select-Object "Colour", "Perfect Cut Name", "PC Projected Price", "Cut Name", "Projected Price" | Where-Object { $_.Colour -eq $colour } | Sort-Object @{e={[int]$_.'Projected Price'}} -Descending | Select-Object -First 1
        
        $objResult = New-Object PSObject
        $objResult | Add-Member -Membertype NoteProperty -Name "Colour" -Value $Colour
        $objResult | Add-Member -MemberType NoteProperty -Name "Perfect Cut" -Value $ProfitableCut.'Perfect Cut Name'
        $objResult | Add-Member -MemberType NoteProperty -Name "PC Projected Price" -Value $ProfitableCut.'PC Projected Price'
        $objResult | Add-Member -MemberType NoteProperty -Name "Cut" -Value $ProfitableCut.'Cut Name'
        $objResult | Add-Member -MemberType NoteProperty -Name "Projected Price" -Value $ProfitableCut.'Projected Price'
        $objprofitablecuts += $objResult
    }

#$objGemPrices | ft -AutoSize
$objprofitablecuts | ft -AutoSize
