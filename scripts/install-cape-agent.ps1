# Install CAPE agent and configure auto-start with admin privileges
# Renamed to avoid CAPE-related naming (anti-VM detection)

param(
    [string]$AgentUrl = "https://raw.githubusercontent.com/kevoreilly/CAPEv2/master/agent/agent.py",
    [string]$InstallDir = "C:\Analysis"
)

Write-Host "=== Installing analysis agent ===" -ForegroundColor Green

# Create installation directory
if (-not (Test-Path $InstallDir)) {
    New-Item -Path $InstallDir -ItemType Directory -Force | Out-Null
}

$agentPath = Join-Path $InstallDir "agent.pyw"

# Download agent
Write-Host "Downloading agent from $AgentUrl..."
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $AgentUrl -OutFile $agentPath -UseBasicParsing
    Write-Host "Agent downloaded to $agentPath" -ForegroundColor Green
} catch {
    Write-Host "Failed to download agent: $_" -ForegroundColor Red
    exit 1
}

# Find Python installation (32-bit preferred for CAPE)
$pythonPaths = @(
    "C:\Python310-32\pythonw.exe",
    "C:\Python310\pythonw.exe",
    "C:\Python39-32\pythonw.exe",
    "C:\Python39\pythonw.exe"
)

$pythonExe = $pythonPaths | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $pythonExe) {
    $pythonExe = (Get-Command pythonw.exe -ErrorAction SilentlyContinue).Source
}

if (-not $pythonExe) {
    Write-Host "Python not found! Please install 32-bit Python first." -ForegroundColor Red
    exit 1
}

Write-Host "Using Python: $pythonExe"

# Create scheduled task
$taskName = "SystemMonitor"

$action = New-ScheduledTaskAction -Execute $pythonExe -Argument $agentPath
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Highest

try {
    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Force -ErrorAction Stop
    Write-Host "Scheduled task '$taskName' created" -ForegroundColor Green
} catch {
    Write-Host "Warning: Failed to create scheduled task: $_" -ForegroundColor Yellow
    Write-Host "Sleeping 15 minutes for troubleshooting..." -ForegroundColor Yellow
    Start-Sleep -Seconds 900
}

# Also create a startup shortcut as backup
$startupPath = [Environment]::GetFolderPath("CommonStartup")
$shortcutPath = Join-Path $startupPath "SystemMonitor.lnk"

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $pythonExe
$shortcut.Arguments = "`"$agentPath`""
$shortcut.WorkingDirectory = $InstallDir
$shortcut.Description = "System Monitor"
$shortcut.Save()

Write-Host "Startup shortcut created" -ForegroundColor Green

Write-Host "=== Agent installation complete ===" -ForegroundColor Green