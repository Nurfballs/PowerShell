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


$rubycuts = @("Delicate Primordial Ruby", "Brilliant Primordial Ruby", "Bold Primordial Ruby", "Precise Primordial Ruby", "Flashing Primordial Ruby")
#$rubyperfectcuts = @("Delicate Pandarian Garnet","Brilliant Pandarian Garnet", "Bold Pandarian Garnet", "Precise Pandarian Garnet", "Flashing Pandarian Garnet")



foreach ($cut in $rubycuts)
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


$objGemPrices | ft -AutoSize
