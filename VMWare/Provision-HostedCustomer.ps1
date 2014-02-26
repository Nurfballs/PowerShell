# Reqirements:
# 1. A tag in VMWare exists for the CustomerID.
# 2. ovftool is installed: - Required to deploy Watchguard XTMv
# -- Download: https://developercenter.vmware.com/web/dp/tool/ovf
# 3. VMWare PowerCLI

param (
    [Parameter(Mandatory=$True)][string]$CustomerID,
    [Parameter(Mandatory=$true)][string]$VLANID
)

# Add the VMWare Snappin
Try
{
    Write-Verbose "Loading VMWare PowerCLI snappins ... "
    Add-PSSnapin VMWare.VIMAutomation.Core
    Add-PSSnapin VMWare.VIMAutomation.VDS
}
Catch
{
    Write-Error "Unable to load VMWare PowerCLI snappin."
    Exit
}


# Connect to VCenter
Try
{
    Write-Verbose "Connecing to vc.hotline.net.au ..."
    Connect-VIServer vc.hotline.net.au
}
Catch
{
    Write-Error "Unable to connect to vSphere server (vc.hotline.net.au)."
    Exit
}



# Make sure ovftool is installed.
Write-Verbose "Checking for ovftool ..."
if ((Test-Path 'C:\Program Files\VMware\VMware OVF Tool\ovftool.exe') -eq $False) { Write-Error "VMWare Open Virtualization Tool (ovftool.exe) not installed. Download: https://developercenter.vmware.com/web/dp/tool/ovf"; Exit }

# Make sure a tag for the CustomerID exits.
Write-Verbose "Checking for CustomerID in VMware ... "
Try { Get-Tag -Name $CustomerID -ErrorAction Stop }
Catch [System.Management.Automation.ActionPreferenceStopException] {
    Write-Error "No tag for $CustomerID exists in vSphere."

    # Get user's email address from AD
    Write-Verbose "Gathering email address from Active Directory ..."
    $searcher = [adsisearcher]"(samaccountname=$env:USERNAME)"
    $emailaddr = $searcher.FindOne().Properties.mail

    # Send user a failure email
    Write-Verbose "Sending email ..."
    Send-MailMessage -From 'vmware@hotlineit.com' -To $emailaddr -Subject "Customer Provisioning Falure - $CustomerID" -BodyAsHtml "Provisioning of customer $CustomerID failed because no Tag for $CustomerID exists in vSphere." -SmtpServer 'mx5.hotline.net.au'
    Exit;
}

# Create new distributed port group on the distributed switch
Write-Output "Creating dvPortGroup: Hosted Customer - $CustomerID with VLANID $VLANID"
$dvPortGroup = New-VDPortGroup -VDSwitch dvSwitch -Name "Hosted Customer - $CustomerID" -VlanId $VLANID 
Start-Sleep -Seconds 3
New-TagAssignment -tag $CustomerID -Entity $dvPortGroup > $Null

# Create new resource pool
Write-Output "Creating resource pool: Hosted Customers\$CustomerID"
$ResourcePool = New-ResourcePool -Name $CustomerID -Location (Get-ResourcePool -Location "VMWare Cluster" -Name "Hosted Customers") 
Start-Sleep -Seconds 3
New-TagAssignment -Tag $CustomerID -Entity $ResourcePool > $Null

# Create new folder for the customer's VMs
Write-Output "Creating Virtual Machine folder: Hosted Customers\$CustomerID"
$Folder = New-Folder -Name $CustomerID -Location (Get-Folder -Name "Hosted Customers")
Start-Sleep -Seconds 3
New-TagAssignment -Tag $CustomerID -Entity $Folder > $Null

# Deploy XTMv:
# - eth0 (External): Hotline IT - Public network
# - eth1 (Trusted): Hosted Customer network
Write-Output "Deploying Watchguard XTMv ... "
$arglist =  "--acceptAllEulas --datastore=""VNX NL-SAS"" --vmFolder=""Hosted Customers/$CustomerID"" --name=""XTMv"" --net:""Network 0=dvPortGroup-Hotline IT - Public"" --net:""Network 1=Hosted Customer - $CustomerID"" http://cdn.watchguard.com/SoftwareCenter/Files/XTM/11_8_1/xtmv_11_8_1.ova vi://vc.hotline.net.au/PowerTel%20CoLocation/host/VMWare%20Cluster/Resources/Hosted%20Customers/$CustomerID"
Start-Process 'C:\Program Files\VMware\VMware OVF Tool\ovftool.exe' -ArgumentList $arglist -Wait

# Assign customer tag to XTMv
$XTMV = Get-VM -Name XTMv -Location $CustomerID
New-TagAssignment -Tag $CustomerID -Entity $XTMV  > $null
Start-Sleep -Seconds 3

# Set network adapater to VMXNET3 (to resolve PPTP VPN issue with e1000 cards)
Write-Verbose "Changing network adapter type to VMXNET3 ..."
$XTMV | Get-NetworkAdapter | Set-NetworkAdapter -type VMXNET3 > $null

# Boot the XTMv
Start-VM -VM $XTMV > $null

# Open the XTMv in the browser for configuration
Open-VMConsoleWindow -VM $XTMV > $null

# ========================
# == Configure Backups ==
# ========================

# Configure PS Remoting
Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force

# Set credentials for SVR-COLO-BACK
$username = "hotadmin"
$password = ConvertTo-SecureString (Read-Host "Enter password to connect to SVR-COLO-BCK (hotadmin)") -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential("SVR-COLO-BCK\$username",$password)

# Create a new PS Session to SVR-COLO-BCK
$session = New-PSSession 210.87.22.64 -Credential $cred

$ScriptPath = (Split-Path ((Get-Variable MyInvocation).Value).MyCommand.Path)

# Create Backup Job
Invoke-Command -Session $session -FilePath "$ScriptPath\Create-VeeamBackupJob.ps1" -ArgumentList $CustomerID


# Define HTML Email Subject
$htmlsubject = "VMware Customer Provisioning Complete"

# Define HTML Email body
[string]$htmlbody = ""
$htmlbody += "<h1>Customer Creation Success!</h1>"
$htmlbody += "<table border=1>"
$htmlbody += "<thead>"
$htmlbody += "<th colspan=4>VMware Resource Configuration</th>"
$htmlbody += "<tr>"
$htmlbody += "<td>Resource</td>"
$htmlbody += "<td>Name</td>"
$htmlbody += "<td>Tag</td>"
$htmlbody += "<td>Info</td>"
$htmlbody += "</tr>"
$htmlbody += "</thead>"
$htmlbody += "<tbody>"
$htmlbody += "<tr>"
$htmlbody += "<td>Distributed Virtual Port Group</td>"
$htmlbody += "<td>Hosted Customer - $CustomerID</td>"
$htmlbody += "<td>$CustomerID</td>"
$htmlbody += "<td>$VLANDI</td>"
$htmlbody += "</tr>"
$htmlbody += "<tr>"
$htmlbody += "<td>Resource Pool</td>"
$htmlbody += "<td>Hosted Customers\$CustomerID</td>"
$htmlbody += "<td>$CustomerID</td>"
$htmlbody += "<td>&nbsp;</td>"
$htmlbody += "</tr>"
$htmlbody += "<tr>"
$htmlbody += "<td>Virtual Machine Folder</td>"
$htmlbody += "<td>Hosted Cusotmers\$CustomerID</td>"
$htmlbody += "<td>$CustomerID</td>"
$htmlbody += "<td>&nbsp;</td>"
$htmlbody += "</tr>"
$htmlbody += "</tbody>"
$htmlbody += "</table>"
$htmlbody += "<br>"
$htmlbody += "<table border=1>"
$htmlbody += "<thead>"
$htmlbody += "<th colspan=7>Virtual Machine Configuration</th>"
$htmlbody += "<tr>"
$htmlbody += "<td>Name</td>"
$htmlbody += "<td>Location</td>"
$htmlbody += "<td>eth0 (External)</td>"
$htmlbody += "<td>VLAN</td>"
$htmlbody += "<td>eth1 (Trusted)</td>"
$htmlbody += "<td>VLAN</td>"
$htmlbody += "<td>Description</td>"
$htmlbody += "</tr>"
$htmlbody += "</thead>"
$htmlbody += "<tr>"
$htmlbody += "<td>XTMv</td>"
$htmlbody += "<td>Hosted Customers\$CustomerID</td>"
$htmlbody += "<td>Hotline IT - Public Network</td>"
$htmlbody += "<td>VLAN</td>"
$htmlbody += "<td>Hosted Customer - $CustomerID</td>"
$htmlbody += "<td>$VLANID</td>"
$htmlbody += "<td>Watchguard XTMv 11.8.1 Virtual Appliance</td>"
$htmlbody += "</tr>"
$htmlbody += "<tbody>"
$htmlbody += "</tbody>"
$htmlbody += "</table>"
$htmlbody += "<br>"
$htmlbody += "<hr>"
$htmlbody += "<h2>Additional Action Required</h2>"
$htmlbody += "<p>You must now login to the console of the XTMv and set it's public IP address by issuing the following commands, substituting the correct IP address where applicable:</p>"
$htmlbody += "<p>"
$htmlbody += "configure<br>"
$htmlbody += "interface FastEthernet 0<br>"
$htmlbody += "ip address 210.87.22.102/25 default-gw 210.87.22.1<br>"
$htmlbody += "</p>"
$htmlbody += "<p>Once the public IP has been set, you can login to the XTMv web interface (https://[public ip]:9443) and configure firewall policies and the internal interfaces.</p>"

# Get user's email address from AD
Write-Verbose "Gathering email address from Active Directory ..."
$searcher = [adsisearcher]"(samaccountname=$env:USERNAME)"
$emailaddr = $searcher.FindOne().Properties.mail

# Send user a completion email
Write-Verbose "Sending email ..."
Send-MailMessage -From 'vmware@hotlineit.com' -To $emailaddr -Subject $htmlsubject -BodyAsHtml $htmlbody -SmtpServer 'mx5.hotline.net.au'

Write-Output "Script completed successfully!"
