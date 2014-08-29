Function Create-CWTicket {
    param(
        [string]$Summary,
        [string]$Status="New",
        [string]$Board="Service/MSP",
        [String]$Description,
        [String]$CompanyName="Hotline"
    )
     
    # Generate the POST URL
    $url = "https://cw.hotlineit.com/v4_6_release/services/system_io/integration_io/processclientaction.rails?actionString=<UpdateTicketAction xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema'><CompanyName>hotline</CompanyName><IntegrationLoginId>labtech</IntegrationLoginId><IntegrationPassword>labtech</IntegrationPassword><CompanyId>$CompanyName</CompanyId><SrServiceRecid>0</SrServiceRecid><Ticket><Summary>$Summary</Summary><SiteName>hotline</SiteName><StatusName>$Status</StatusName><ServiceBoard>$Board</ServiceBoard><ProblemDescription>$Description</ProblemDescription></Ticket></UpdateTicketAction>"
    
    # Create the ticket
    $result = Invoke-WebRequest $URL -Method POST
     
    if ($result.StatusDescription -ne "OK")
        {
            # Error booking ticket
            Return "ERROR"
             
        } else {
             
            # Ticket booked sucessfully
            # Get ticket number
            [xml]$ResultXML = $Result.Content
            $TicketNumber = $ResultXML.Childnodes[1].SrServiceRecID
             
            Return $TicketNumber
        }
     
}

# Step 1
# Copy Files from Source to USB
$source = "G:\!Stuff\MPanel"
$dest = "C:\!Stuff\MPanel"
$LogFIle = "$env:windir\Temp\Veeam-BackupCopy.log"

Copy-Item $source G:\ -recurse -erroraction SilentlyContinue  #-Filter *.vib 


# Step 2
# Compare MD5 hashes to determine successful copy.
$files  = Get-ChildItem $source -recurse -file

foreach ($file in $files)
{
    $DestinationFile = $File.FullName.Replace($Source,$Dest)

    # Check destination file exists
    if (!(Test-Path $DestinationFile)) 
    {
        # File does not exist in the destination (USB)
        Write-Output "$DestinationFile does not exist."

        # Write to log file
        Add-Content $LogFile "[$(Get-Date -f "dd-MM-yyyy hh:mm tt")] - File Copy - [FAILED]: $DestinationFile does not exist."
        
    } else {
        
       # Grab the MD5 hash of the source file.
       $SourceHash = Get-FileHash -path $file.Fullname -Algorithm MD5
       
       # Grab the MD5 hash of the destination file
       $DestHash = Get-FileHash -path $DestinationFile -Algorithm MD5

       # Compare the hashes
       if ($SourceHash.Hash -ne $DestHash.Hash)
       {
            # Issue with file copy
            Write-Output "There was an issue copying file: $DestinationFile"
            Write-Output "The destination MD5 checksum does not match the source."
            
            # Write to log file
            Add-Content $LogFile "[$(Get-Date -f "dd-MM-yyyy hh:mm tt")] - Hash Check - [FAILED]: $DestinationFile - the MD5 hash does not match the source."
       }
    }

}

# Step 3
# If there were errors - notify us
if (Test-Path $LogFile)
{
    # TO DO: Book a ticket.
    $Description = Get-Content $LogFIle
    $Description = $Description.Trim()
    Create-CWTicket -Summary "BU - Veeam USB Replication Failed - $env:ComputerName" -Description $Description

    # Remove the file
    Remove-Item $LogFile -force
}