# Uncomment for debugging
#Start-Transcript C:/debug.log -Append

Start-Sleep -Seconds 15

Write-Host "Disabling WinRM"
Disable-PSRemoting -Force
Set-Service WinRM -StartupType Disabled -PassThru
Remove-Item -Path WSMan:\Localhost\listener\listener* -Recurse
Set-NetFirewallRule -DisplayName 'Windows Remote Management (HTTP-In)' -Enabled False -PassThru | Select -Property DisplayName, Profile, Enabled
Write-Host "Shutting down now"
shutdown /s /f /t 0 /c "Packer has finished. Shutting down."