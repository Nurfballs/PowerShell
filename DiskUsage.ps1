#Files
$files = @()
$files += Get-ChildItem D:\ -recurse -ErrorAction SilentlyContinue | Sort-Object length -Descending | Select-Object -first 50
$files | Select-Object FullName, Length

#Directories
$directories = @()
$directories += Get-ChildItem D:\ -recurse -Directory -ErrorAction SilentlyContinue | Sort-Object length -Descending | Select-Object -first 50
$directories | Select-Object FullName, Length


