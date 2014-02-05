param (
    [Parameter(Mandatory=$True)][string]$CustomerID,
    [Parameter(Mandatory=$true)][string]$VLANID
)

# Add the VMWare Snappin
Add-PSSnapin VMWare.VIMAutomation.Core
Add-PSSnapin VMWare.VIMAutomation.VDS

# Make sure a tag for the CustomerID exits.
if ((Get-Tag -Name $CustomerID) -eq $False) { Write-Error "No tag for $CustomerID exists."; exit }

# Create new distributed port group on the distributed switch
Write-Progress -Activity "Provisioning New Customer" -Status "Creating dvPortGroup" -PercentComplete 33.3
$dvPortGroup = New-VDPortGroup -VDSwitch dvSwitch -Name "Hosted Customer - $CustomerID" -VlanId $VLANID 
Start-Sleep -s 3
New-TagAssignment -tag $CustomerID -Entity $dvPortGroup

# Create new resource pool
Write-Progress -Activity "Provisioning New Customer" -Status "Creating Resource Pool" -PercentComplete 66.6
$ResourcePool = New-ResourcePool -Name $CustomerID -Location (Get-ResourcePool -Location "VMWare Cluster" -Name "Hosted Customers") 
Start-Sleep -s 3
New-TagAssignment -Tag $CustomerID -Entity $ResourcePool

# Create new folder for the customer's VMs
Write-Progress -Activity "Provisioning New Customer" -Status "Creating Virtual Machine Folder" -PercentComplete 99.9
$Folder = New-Folder -Name $CustomerID -Location (Get-Folder -Name "Hosted Customers")
Start-Sleep -s 3
New-TagAssignment -Tag $CustomerID -Entity $Folder



