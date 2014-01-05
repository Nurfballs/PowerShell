# Created by Casey Mullineaux
# Date: 21-05-2013

# This script will query the ImageManager database for the list of folders that images
# are being replicated to, and make sure they exist. If they dont, it will create them.


# Exit Codes
# 1 - Error occurred connecting to IM database
# 2 - Error occurred booking CW ticket


# Define parameters
param (
    [Parameter(Mandatory=$True)]
    [string]$CompanyName = "Hotline"
    )

$Date = Get-Date -format "yyyy-MM-dd"
$LogFile = "C:\Hotline\Scripts\Logs\$($date)_Verify-IMReplicationPath.log"

Function Write-Log {
    param(
        [string]$msg,
        [string]$type
    )
    # Make the log file if it doesn't exist
    if (!(test-path $LogFile)) { New-Item $LogFile -type file -force }
    # Write to the log file
    Add-Content $LogFile "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [$($type.ToUpper())]: $msg"
}

Function Create-CWTicket {
    param(
        [string]$Summary,
        [string]$Status,
        [string]$Board,
        [String]$Description,
        [String]$CompanyName
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

Function Verify-Folders {
# Set variables
$ImageManagerDB = "C:\Program Files (x86)\StorageCraft\ImageManager\ImageManager.mdb"
$strQuery = "SELECT * FROM TargetPaths"
$dsn = "Provider=Microsoft.ACE.OLEDB.12.0; Data Source=$ImageManagerDB;"
 
try {
        ## create connection object and open the database
        $objConn = New-Object System.Data.OleDb.OleDbConnection $dsn
        $objCmd  = New-Object System.Data.OleDb.OleDbCommand $strQuery,$objConn
        $objConn.Open()
        
        ## get query results, populate data-adapter, close connection
        $adapter = New-Object System.Data.OleDb.OleDbDataAdapter $objCmd
        $dataset = New-Object System.Data.DataSet
        [void] $adapter.Fill($dataSet)
    }

catch {
        Write-Log -msg "An error has occurred connecting to the ImageManager database." -type error
        Write-Log -msg $_.Exception.Message -type error

        $error_msg = @"
        An error has occurred accessing the Image Manager database.
        Please ensure that the Microsoft Access Database Engine is installed. (http://download.microsoft.com/download/2/4/3/24375141-E08D-4803-AB0E-10F2E3A07AAA/AccessDatabaseEngine_x64.exe)

"@


        # Book a CW Ticket
        $TicketNumber = Create-CWTicket -Summary "BU - HIT - LT Script: Error occurred accessing ImageManager database - $env:COMPUTERNAME" -Status "New" -Board "Service/MSP" -Description $error_msg -CompanyName $CompanyName
        
        if ($TicketNumber -ne "ERROR") {
            Write-Log -msg "Ticket booked: #$TicketNumber" -type OK
            Write-Log -msg "Exiting script" -type info
            Exit 1
            
        } else {
            Write-Log -msg "Error sending ticket information to ConnectWise" -type ERROR
            Write-Log -msg "Exiting script." -type info
            Exit 2
        }

    }

finally {
        ## close the connection   
        $objConn.Close()
    }

 
    ## check the folders
    foreach ($row in $dataset.Tables[0].Rows) {
        $ManagedFolder = $row[0]
        $DriveLetter = $ManagedFolder.Substring(0,3)
 
        #Check if RDX has a cartridge
        if (test-path $DriveLetter) {

            Write-Log -msg "Checking path: $ManagedFolder" -type INFO
            #Check if the managed folder exists on the drive
            if (!(test-path $ManagedFolder)) {
                write-output "Creating $($ManagedFolder)"
                New-Item $ManagedFolder -type directory -force
                Write-Log -msg "$ManagedFolder does not exist" -type INFO
                Write-Log -msg "Creating folder: $ManagedFolder" -type OK
            }

            else { Write-Log -msg "No cartridge inserted into $DriveLetter" -type WARNING }
        }
     }
 }

 Verify-Folders