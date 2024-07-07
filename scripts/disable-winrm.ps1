Write-Host "Disabling WinRM"
Disable-PSRemoting -Force
#Stop-Service WinRM -PassThru
Set-Service WinRM -StartupType Disabled -PassThru
Remove-Item -Path WSMan:\Localhost\listener\listener* -Recurse
Set-NetFirewallRule -DisplayName 'Windows Remote Management (HTTP-In)' -Enabled False -PassThru | Select -Property DisplayName, Profile, Enabled