# Configure static IP for analysis guest VM
# Avoids 192.168.122.x range (anti-VM detection signature)

param(
    [string]$IPAddress = "192.168.56.10",
    [string]$Gateway = "192.168.56.1",
    [string]$PrefixLength = "24",
    [string]$DNS = "8.8.8.8"
)

Write-Host "=== Configuring Static IP ===" -ForegroundColor Green

# Get the primary network adapter (usually Ethernet or Ethernet0)
$adapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -notlike '*Loopback*' } | Select-Object -First 1

if (-not $adapter) {
    Write-Host "No active network adapter found!" -ForegroundColor Red
    exit 1
}

Write-Host "Configuring adapter: $($adapter.Name) ($($adapter.InterfaceDescription))"

# Remove existing IP configuration
Remove-NetIPAddress -InterfaceIndex $adapter.ifIndex -Confirm:$false -ErrorAction SilentlyContinue
Remove-NetRoute -InterfaceIndex $adapter.ifIndex -Confirm:$false -ErrorAction SilentlyContinue

# Set static IP
New-NetIPAddress -InterfaceIndex $adapter.ifIndex -IPAddress $IPAddress -PrefixLength $PrefixLength -DefaultGateway $Gateway

# Set DNS
Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses $DNS

# Disable DHCP
Set-NetIPInterface -InterfaceIndex $adapter.ifIndex -Dhcp Disabled

Write-Host "Static IP configured:" -ForegroundColor Green
Write-Host "  IP Address: $IPAddress/$PrefixLength"
Write-Host "  Gateway: $Gateway"
Write-Host "  DNS: $DNS"

# Verify configuration
Write-Host "`nVerifying configuration..."
Get-NetIPAddress -InterfaceIndex $adapter.ifIndex | Format-Table IPAddress, PrefixLength

Write-Host "=== Static IP Configuration Complete ===" -ForegroundColor Green