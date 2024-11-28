try {
    iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/mwrock/boxstarter/master/BuildScripts/bootstrapper.ps1'))
    Get-Boxstarter -Force

    $secpasswd = ConvertTo-SecureString "password" -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential ("ed", $secpasswd)

    Install-BoxstarterPackage -PackageName a:\vm.boxstarter -Credential $cred
} catch {
    New-Item -Path "C:\error.log" -ItemType "File" -Value "An error occurred: $_"
    Start-Sleep -Seconds 10
    shutdown /s /f /t 60 /c "An error occurred when installing Boxstarter"
    exit 1
}