﻿# ----------------------------------------------# Define executible locations# ----------------------------------------------$psExec = "C:\Hotline\Scripts\Powershell for XP\psexec.exe"$dotNetFramework = "C:\Hotline\Scripts\Powershell for XP\NetFx20SP1_x86.exe"$WindowsManagementFamework = "C:\Hotline\Scripts\Powershell for XP\WindowsXP-KB968930-x86-ENG.exe"Function Deploy-PowerShellToXP($ComputerName) {    $VerbosePreference = "Continue"    # ------------------------------------------------    # Pre-requisite check    # ------------------------------------------------    Write-Output "Begin Pre-requisite check"        #Make sure the remote computer is Winodws XP.    Write-Verbose "Checking Operating System Version..."    Write-Log -type "INFO" -msg "Checking operating system version"    $OS = Get-WmiObject Win32_OperatingSystem -Computername $ComputerName    if ($OS.Version -notmatch "5.1")    {         Write-Error "Remote computer is not Windows XP. Exiting script."        Write-Log -type "ERROR" -msg "Remote computer is not Windows XP. Exiting script."         Break;    }    Write-Log -type "OK" -msg "Windows XP detected."    #Check if PowerShell is already installed.    Write-Verbose "Checking if PowerShell already installed..."    Write-Log -type "INFO" -msg "Checking if Powershell is already installed"    try     {        $Registry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine", $ComputerName)        $RegKey_PowerShell = $registry.OpenSubKey("Software\Microsoft\Powershell\1")        $RegVal_PowerShell = $RegKey_PowerShell.GetValue("Install")        if ($RegVal_PowerShell -eq "1")        {            Write-Log -type "INFO" -msg "Powershell detected."            $PowerShellInstalled = $True        }        else        {            $PowerShellInstalled = $False        }    }     catch     {        $PowerShellInstalled = $False        Write-Output "PowerShell not installed"        Write-Log -type "OK" -msg "Powershell not installed."    }        # If powershell installed, check which version it is        if ($PowerShellInstalled -eq $True)    {        Write-Verbose "Checking PowerShell Version..."        Write-Log -type "INFO" -msg "Checking Powershell version"        $Registry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine", $ComputerName)        $RegKey_PowerShell = $registry.OpenSubKey("Software\Microsoft\Powershell\1\PowerShellEngine")        $RegVal_PowerShell = $RegKey_PowerShell.GetValue("PowerShellVersion")        $PowerShellVersion = $RegVal_PowerShell                if ($PowerShellVersion -eq "2.0")        {            Write-Output "Powershell 2.0 already installed. Exiting script."            Write-Log -type "OK" -msg "Powershell 2.0 already installed. Exiting script."            Break;        }        elseif ($PowerShellVersion -eq "")         {            Write-Verbose "Powershell appears to be installed, but the version number was unable to be determined."            Write-Verbose "Gonna try installing version 2.0 anyway."            Write-Log -type "INFO" -msg "Powershell appears to be installed, but the version number was unabel to be determined."            Write-Log -type "INFO" -msg "Trying to install Powershell 2.0 anyway."                   }    }    # Install Powershell 2.0    Write-Output "Installing PowerShell 2.0..."    Write-Log -type "INFO" -msg "Installing Powershell 2.0"    # Check if Service Pack 3 is installed.    Write-Verbose "Checking for Windows XP Service Pack 3..."    Write-Log -type "INFO" -msg "Checking if Windows XP Service Pack 3 is installed."    $Registry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine", $ComputerName)    $RegKey_PowerShell = $registry.OpenSubKey("Software\Microsoft\Windows NT\CurrentVersion")    $RegVal_PowerShell = $RegKey_PowerShell.GetValue("CSDVersion")    $ServicePackVersion = $RegVal_PowerShell        if ($ServicePackVersion -notmatch "Service Pack 3")    {        Write-Error "It appears you are using Windows XP, but without Service Pack 3."        Write-Error "Please install Service Pack 3 and try again."        Write-Log -type "ERROR" -msg "Windows XP Service Pack 3 is not installed. Install Service Pack 3 and run the script again."        Write-Log -type "ERROR" -msg "Exiting script."        break;    }    Write-Verbose "Windows XP Service Pack 3 installed."    Write-Log -type "OK" -msg "Windows XP Service Pack 3 is installed."    #Check if .NET Framework 2.0 installed (at least SP1)    Write-Verbose "Checking for .NET Framework 2.0 SP1"    Write-Log -type "INFO" -msg "Checking for.NET Framework 2.0 SP1"    try    {        $Registry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine", $ComputerName)        $RegKey_PowerShell = $registry.OpenSubKey("Software\Microsoft\NET Framework Setup\NDP\v2.0.50727")        $RegVal_PowerShell = $RegKey_PowerShell.GetValue("SP")        $NetFrameworkVersion = $RegVal_PowerShell        if ($NetFrameworkVersion -ne "" -or $NetFrameworkVersion -ne "0")        {            Write-Verbose ".Net Framework 2.0 SP1 or greater installed"            Write-Log -type "OK" -msg ".NET Framewok 2.0 SP1 or greater is already installed."            $NETFrameworkInstalled = $True        }        else        {            Write-Verbose ".NET Framework 2.0 SP1 is not installed."            Write-Log -type "INFO" -msg ".NET Framework 2.0 SP1 is not installed."            $NETFrameworkInstalled = $False        }    }    catch    {        Write-Verbose ".NET Framework 2.0 SP1 not installed."        Write-Log -type "INFO" -msg ".NET Framework 2.0 SP1 is not installed."        $NETFrameworkInstalled = $False    }    # Install .NET Framework 2.0 SP1    if ($NETFrameworkInstalled -eq $False)    {        Write-Output "Installing .NET Framework 2.0 SP1..."        Write-Log -type "INFO" -msg "Installing .NET Frameowrk 2.0 SP1."        &$psexec /AcceptEULA \\$ComputerName -c -f $dotNetFramework /q /norestart            }    # Install Powershell 2.0    Write-Output "Installing PowerShell 2.0 ..."    Write-Log -type "INFO" -msg "Installing Powershell 2.0"     &$psexec /AcceptEULA \\$ComputerName -c -f $WindowsManagementFamework /quiet /passive /norestart        Write-Log -type INFO -msg "Script Complete!" }Function Write-Log {    param(        [string]$msg,        [string]$type    )           # Dim Variables    $Date = Get-Date -format "yyyy-MM-dd"    $LogFile = "C:\Hotline\Scripts\Logs\$date-InstallPowershell.log"     # Make the log file if it doesnt exist.    if (!(test-path $LogFile)) { New-Item $LogFile -type file -force }     # Write to the log file        Add-Content $LogFile "$(get-date -format 'yyyy-MM-dd HH:mm:ss') [$($type.toupper())]: $msg"}