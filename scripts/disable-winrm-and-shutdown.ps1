# Uncomment for debugging
#Start-Transcript C:/debug.log -Append

Param(
    [Switch]$DisableWinRM
)

Start-Sleep -Seconds 15

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