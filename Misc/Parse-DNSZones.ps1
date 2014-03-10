$files = Get-Childitem "I:\Clients\HVG\HVGDomains\" -filter "*.txt"


foreach ($File in $files)
{
    $domain = Get-Content $file.FullName
    $outputfile = "I:\Clients\HVG\HVGDomains\Processed\" + $File.Name

    foreach ($line in $domain)
    {
        # search for A records
        $regex = [regex]"\b(A)\b"
        if ($line -match $regex) { $line | Out-File $outputfile -Append }
        
        # Serach for MX records
        $regex = [regex]"\b(MX)\b"
        if ($line -match $regex) { $line | Out-File $outputfile -Append }
    
        # Search for CNAME records
        $regex = [regex]"\b(CNAME)\b"
        if ($line -match $regex) { $line | Out-File $outputfile -Append }
    }
}