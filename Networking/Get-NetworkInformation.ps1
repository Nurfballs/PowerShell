function Export-NetworkInfo 
{
    param(
        #[parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$True)]
        [parameter(Mandatory=$True)]
        [string[]]$ComputerName = $env:computername
    )

    begin{ New-Item -ItemType Directory -Force -Path C:\Hotline | Out-Null }
    process {
        ForEach ($Computer in $ComputerName) {
            Write-Output "+ $Computer"
            If (Test-Connection -ComputerName $ComputerName -Count 1 -ea 0) {
                # Get Network Information
                $Networks = Get-WMIObject -Class Win32_NetworkAdapterConfiguration -ComputerName $Computer -Filter IPEnabled=TRUE
                ForEach ($Network in $Networks) {
                    $IPAddress = $Network.IPAddress[0]
                    $SubnetMask = $Network.IPSubnet[0]
                    [String]$DefaultGateway =  $Network.DefaultIPGateway
                    [String]$DNSServers = $Network.DNSServerSearchOrder
                    $IsDHCPEnabled = $False
                    If ($Network.DHCPEnabled) { $IsDHCPEnabled = $True }
                    $MACAddress = $Network.MACAddress
        
                    $objOutput = New-Object PSObject
                    $objOutput | Add-Member -MemberType NoteProperty -Name IPAddress -Value $IPAddress
                    $objOutput | Add-Member -MemberType NoteProperty -Name SubnetMask -Value $SubnetMask
                    $objOutput | Add-Member -MemberType NoteProperty -Name DefaultGateway -Value $DefaultGateway
                    $objOutput | Add-Member -MemberType NoteProperty -Name IsDHCPEnabled -Value $IsDHCPEnabled
                    $objOutput | Add-Member -MemberType NoteProperty -Name DNSServers -Value $DNSServers
                    $objOutput | Add-Member -MemberType NoteProperty -Name MACAddress -Value $MACAddress
                    $objOutput | Export-Csv -Path C:\Hotline\$Computer.csv -Append -NoTypeInformation
                    $objOutput
                }
            }
        }
    }
    end {}
}


function Import-NetworkInfo 
{
    param(
    [parameter(Mandatory=$True)]
    [String]$File
    )


}





