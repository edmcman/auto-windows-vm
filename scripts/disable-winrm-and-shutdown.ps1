# Uncomment for debugging
#Start-Transcript C:/debug.log -Append

Param(
    [Switch]$DisableWinRM,
    [Switch]$SetStaticIP
)

Start-Sleep -Seconds 15

if ($SetStaticIP) {
    Write-Host "Configuring static IP for CAPE analysis network"
    $adapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notlike '*Loopback*' } | Select-Object -First 1
    if ($adapter) {
        Remove-NetIPAddress -InterfaceIndex $adapter.ifIndex -Confirm:$false -ErrorAction SilentlyContinue
        Remove-NetRoute -InterfaceIndex $adapter.ifIndex -Confirm:$false -ErrorAction SilentlyContinue
        New-NetIPAddress -InterfaceIndex $adapter.ifIndex -IPAddress "192.168.56.10" -PrefixLength 24 -DefaultGateway "192.168.56.1" -ErrorAction SilentlyContinue
        Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses "8.8.8.8" -ErrorAction SilentlyContinue
        Set-NetIPInterface -InterfaceIndex $adapter.ifIndex -Dhcp Disabled -ErrorAction SilentlyContinue
        Write-Host "Static IP 192.168.56.10/24 configured"
    } else {
        Write-Host "No active adapter found, skipping static IP"
    }
}

if ($DisableWinRM) {
    Write-Host "Disabling WinRM"
    Disable-PSRemoting -Force
    Set-Service WinRM -StartupType Disabled -PassThru
    Remove-Item -Path WSMan:\Localhost\listener\listener* -Recurse
    Set-NetFirewallRule -DisplayName 'Windows Remote Management (HTTP-In)' -Enabled False -PassThru | Select -Property DisplayName, Profile, Enabled
} else {
    Write-Host "Skipping WinRM disable (DisableWinRM = $DisableWinRM)"
}

Write-Host "Shutting down now"
shutdown /s /f /t 0 /c "Packer has finished. Shutting down."
