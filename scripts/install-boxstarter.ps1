#$WinlogonPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"
#Remove-ItemProperty -Path $WinlogonPath -Name AutoAdminLogon
#Remove-ItemProperty -Path $WinlogonPath -Name DefaultUserName

iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/mwrock/boxstarter/master/BuildScripts/bootstrapper.ps1'))
Get-Boxstarter -Force

$secpasswd = ConvertTo-SecureString "password" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("ed", $secpasswd)

# Can't we use this from the boxstarter.org docs?
Import-Module Boxstarter.Chocolatey
#Import-Module $env:appdata\boxstarter\boxstarter.chocolatey\boxstarter.chocolatey.psd1

Install-BoxstarterPackage -PackageName a:\vm.boxstarter -Credential $cred
