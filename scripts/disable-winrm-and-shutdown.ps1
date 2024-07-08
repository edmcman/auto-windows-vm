Write-Host "Disabling WinRM"
Disable-PSRemoting -Force
Set-Service WinRM -StartupType Disabled -PassThru
Remove-Item -Path WSMan:\Localhost\listener\listener* -Recurse
Set-NetFirewallRule -DisplayName 'Windows Remote Management (HTTP-In)' -Enabled False -PassThru | Select -Property DisplayName, Profile, Enabled
write-Host "Shutting down now"
shutdown /s /c "Packer has finished. Shutting down."