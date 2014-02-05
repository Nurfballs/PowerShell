param(
    [Parameter(Mandatory=$true)][string]$CustomerID,
    [Parameter(Mandatory=$true)][string]$VLANID,
    [Parameter(Mandatory=$true)][string]$PublicIP

)

# Requirements:
# 1. VMware Open Virtualization Format Tool (ovftool.exe) installed locally
# -- Download: https://developercenter.vmware.com/web/dp/tool/ovf

# Make sure ovftool is installed
if ((Test-Path 'C:\Program Files\VMware\VMware OVF Tool\ovftool.exe') -eq $False) 
{
    Write-Error "VMWare Open Virtualization Tool (ovftool.exe) not installed. Download: https://developercenter.vmware.com/web/dp/tool/ovf"
}


& 'C:\Program Files\VMware\VMware OVF Tool\ovftool.exe' --acceptAllEulas --lax "--datastore=VNX NL-SAS" "--vmFolder=Hosted Customers/$($CustomerID)" "--name=XTMv" "--net:Network 0=dvPortGroup-Hotline IT - Public" "--net:Network 1=Hosted Customer - $($CustomerID)" "https://vc.hotline.net.au/folder/Watchguard%2fXTMv/11.8.1?dcPath=PowerTel%2520CoLocation&dsName=CD%2520Images/xtmv_11_8_1.ova" vi://vc.hotline.net.au/PowerTel%20CoLocation/host/VMWare%20Cluster/Resources/Hosted%20Customers/TestCustomer