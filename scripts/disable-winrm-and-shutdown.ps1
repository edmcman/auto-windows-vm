Param(
    [Switch]$DisableWinRM,
    [string]$StaticIP    = '',
    [string]$Gateway     = '',
    [int]$PrefixLength   = 24,
    [string]$Mac         = ''
)

$ErrorActionPreference = 'Stop'
$errors = @()

Start-Sleep -Seconds 15

if ($StaticIP -ne '') {
    try {
        $adapter = if ($Mac -ne '') {
            $macFormatted = ($Mac -replace ':', '-').ToUpper()
            Get-NetAdapter | Where-Object { $_.MacAddress -eq $macFormatted } | Select-Object -First 1
        } else {
            Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notlike '*Loopback*' } | Select-Object -First 1
        }
        if (-not $adapter) { throw "No adapter found for MAC $Mac" }

        Set-NetIPInterface -InterfaceIndex $adapter.ifIndex -Dhcp Disabled
        Remove-NetIPAddress -InterfaceIndex $adapter.ifIndex -Confirm:$false -ErrorAction SilentlyContinue
        Remove-NetRoute -InterfaceIndex $adapter.ifIndex -Confirm:$false -ErrorAction SilentlyContinue
        New-NetIPAddress -InterfaceIndex $adapter.ifIndex -IPAddress $StaticIP -PrefixLength $PrefixLength -DefaultGateway $Gateway
        Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses '8.8.8.8'
    } catch {
        $errors += "Static IP config failed: $_"
    }
}

if ($DisableWinRM) {
    try {
        Disable-PSRemoting -Force
        Set-Service WinRM -StartupType Disabled -PassThru
        Remove-Item -Path WSMan:\Localhost\listener\listener* -Recurse
        Set-NetFirewallRule -DisplayName 'Windows Remote Management (HTTP-In)' -Enabled False -PassThru | Select -Property DisplayName, Profile, Enabled
    } catch {
        $errors += "WinRM disable failed: $_"
    }
}

if ($errors) {
    $msg = "Errors during shutdown script:`n`n" + ($errors -join "`n`n")
    (New-Object -ComObject WScript.Shell).Popup($msg, 300, 'Shutdown Script Error', 16)
}

shutdown /s /f /t 0 /c "Packer has finished. Shutting down."