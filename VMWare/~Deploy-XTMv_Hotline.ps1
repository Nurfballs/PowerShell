param(
    [Parameter(Mandatory=$true)][string]$CustomerID
    #[Parameter(Mandatory=$true)][string]$VLANID,
    #[Parameter(Mandatory=$true)][string]$PublicIP

)

# Requirements:
# -- Download: https://developercenter.vmware.com/web/dp/tool/ovf

# Make sure ovftool is installed
if ((Test-Path 'C:\Program Files\VMware\VMware OVF Tool\ovftool.exe') -eq $False) 
{
    Write-Error "VMWare Open Virtualization Tool (ovftool.exe) not installed. Download: https://developercenter.vmware.com/web/dp/tool/ovf"
}



#Properties:
#  ClassId:     vami
#  Key:         gateway
# InstanceId   XTMv
# Category:    Networking Properties
#  Label:       Default Gateway
#  Type:        string
#  Description: The default gateway address for this VM. Leave blank if DHCP is 
#               desired. 

# ClassId:     vami
#  Key:         DNS
#  InstanceId   XTMv
#  Category:    Networking Properties
#  Label:       DNS
#  Type:        string
#  Description: The domain name servers for this VM (comma separated). Leave 
#               blank if DHCP is desired. 

#   ClassId:     vami
#  Key:         ip0
#  InstanceId   XTMv
#  Category:    Networking Properties
#  Label:       Network 1 IP Address
#  Type:        string
#  Description: The IP address for this interface. Leave blank if DHCP is 
#              desired. 

#  ClassId:     vami
#  Key:         netmask0
#  InstanceId   XTMv
#  Category:    Networking Properties
#  Label:       Network 1 Netmask
#  Type:        string
#  Description: The netmask or prefix for this interface. Leave blank if DHCP is
 #              desired. 

$arglist =  "--acceptAllEulas --datastore=""EMC VNX"" --vmFolder=""Hosted Customers/$CustomerID"" --name=""XTMv"" --net:""Network 0=dvPortGroup-Hotline IT - Public"" --net:""Network 1=Hosted Customer - $CustomerID"" http://cdn.watchguard.com/SoftwareCenter/Files/XTM/11_8_3_U1/xtmv_11_8_3_U1.ova vi://vc.hotline.net.au/PowerTel%20CoLocation/host/VMWare%20Cluster/Resources/Hosted%20Customers/$CustomerID"
Start-Process 'C:\Program Files\VMware\VMware OVF Tool\ovftool.exe' -ArgumentList $arglist

