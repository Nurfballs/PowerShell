[string]$Password = ''

# Define all lower case characters
[char[]]$lowercase = ''
foreach ($i in 98..100)  { $lowercase += ([char]($i)) } # b-d
foreach ($i in 102..104) { $lowercase += ([char]($i)) } # f-h
foreach ($i in 106..110) { $lowercase += ([char]($i)) } # j-n
foreach ($i in 112..116) { $lowercase += ([char]($i)) } # p-t
foreach ($i in 118..122) { $lowercase += ([char]($i)) } # v-z

# Define lower case vowels
[char[]]$vowel = ''
$vowel += 'a'
$vowel += 'e'
$vowel += 'i'
$vowel += 'o'
$vowel += 'u'

# Define upper case characters
[char[]]$uppercase = ''
foreach ($i in 66..68) { $uppercase += ([char]($i)) } # B-D
foreach ($i in 70..72) { $uppercase += ([char]($i)) } # F-H
foreach ($i in 74..78) { $uppercase += ([char]($i)) } # J-N
foreach ($i in 80..84) { $uppercase += ([char]($i)) } # P-T
foreach ($i in 86..90) { $uppercase += ([char]($i)) } # V-Z

# Generate the password
$Password += Get-Random -InputObject $uppercase
$Password += Get-Random -InputObject $vowel
$Password += Get-Random -InputObject $lowercase
$Password += Get-Random -InputObject $vowel
$Password += Get-Random -InputObject (1..9)
$Password += Get-Random -InputObject (1..9)
$Password += Get-Random -InputObject (1..9)
$Password += Get-Random -InputObject (1..9)

Write-Output $Password
