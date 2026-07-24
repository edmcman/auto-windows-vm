# Disable Microsoft and Google updater clients without blocking provider domains.

Function Set-PolicyDword {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [int]$Value
    )

    New-Item -Path $Path -Force -ErrorAction Stop | Out-Null
    New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType DWord -Force -ErrorAction Stop | Out-Null
}

Function Disable-ServiceIfPresent {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $service = Get-Service -Name $Name -ErrorAction SilentlyContinue
    if ($null -eq $service) {
        return
    }

    try {
        Set-Service -Name $service.Name -StartupType Disabled -ErrorAction Stop
    } catch {
        try {
            Set-ItemProperty `
                -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$($service.Name)" `
                -Name "Start" `
                -Value 4 `
                -Type DWord `
                -ErrorAction Stop
        } catch {
            Write-Warning "Could not disable service $($service.Name): $($_.Exception.Message)"
        }
    }

    try {
        Stop-Service -Name $service.Name -Force -ErrorAction Stop
    } catch {
        if ((Get-Service -Name $service.Name -ErrorAction SilentlyContinue).Status -ne 'Stopped') {
            Write-Warning "Could not stop service $($service.Name): $($_.Exception.Message)"
        }
    }
}

Write-Output "Disabling Microsoft and Google updater clients..."

# Enforce Windows Update policy without disabling general-purpose BITS.
$windowsUpdatePath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
$windowsUpdateAuPath = "$windowsUpdatePath\AU"
Set-PolicyDword -Path $windowsUpdatePath -Name "DoNotConnectToWindowsUpdateInternetLocations" -Value 1
Set-PolicyDword -Path $windowsUpdatePath -Name "SetDisableUXWUAccess" -Value 1
Set-PolicyDword -Path $windowsUpdateAuPath -Name "NoAutoUpdate" -Value 1

# Prevent Edge and its component updater from running in the background.
Set-PolicyDword -Path "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate" -Name "UpdateDefault" -Value 0
Set-PolicyDword -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "ComponentUpdatesEnabled" -Value 0
Set-PolicyDword -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "BackgroundModeEnabled" -Value 0

# Prevent Google Update and Chrome's component updater from running.
Set-PolicyDword -Path "HKLM:\SOFTWARE\Policies\Google\Update" -Name "UpdateDefault" -Value 0
Set-PolicyDword -Path "HKLM:\SOFTWARE\Policies\Google\Update" -Name "AutoUpdateCheckPeriodMinutes" -Value 0
Set-PolicyDword -Path "HKLM:\SOFTWARE\Policies\Google\Chrome" -Name "ComponentUpdatesEnabled" -Value 0
Set-PolicyDword -Path "HKLM:\SOFTWARE\Policies\Google\Chrome" -Name "BackgroundModeEnabled" -Value 0

$services = Get-Service -ErrorAction SilentlyContinue | Where-Object {
    $_.Name -in @("wuauserv", "UsoSvc", "WaaSMedicSvc", "DoSvc", "edgeupdate", "edgeupdatem", "gupdate", "gupdatem") -or
    $_.Name -like "GoogleUpdaterInternalService*" -or
    $_.Name -like "GoogleUpdaterService*"
}

foreach ($service in $services) {
    Disable-ServiceIfPresent -Name $service.Name
}

try {
    $updateTaskPaths = @(
        "\Microsoft\Windows\WindowsUpdate\",
        "\Microsoft\Windows\UpdateOrchestrator\",
        "\Microsoft\Windows\WaaSMedic\",
        "\Microsoft\Windows\DeliveryOptimization\",
        "\Microsoft\EdgeUpdate\"
    )

    $updateTasks = Get-ScheduledTask -ErrorAction Stop | Where-Object {
        $_.TaskPath -in $updateTaskPaths -or
        $_.TaskName -like "MicrosoftEdgeUpdateTask*" -or
        $_.TaskName -like "GoogleUpdateTask*" -or
        $_.TaskName -like "GoogleUpdaterTask*"
    }

    foreach ($task in $updateTasks) {
        try {
            Disable-ScheduledTask -InputObject $task -ErrorAction Stop | Out-Null
        } catch {
            Write-Warning "Could not disable scheduled task $($task.TaskPath)$($task.TaskName): $($_.Exception.Message)"
        }
    }
} catch {
    Write-Warning "Could not enumerate scheduled update tasks: $($_.Exception.Message)"
}
