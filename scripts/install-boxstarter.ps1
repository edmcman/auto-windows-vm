try {
    . e:\vars.ps1
    iex ((new-object net.webclient).DownloadString('https://www.boxstarter.org/bootstrapper.ps1'))
    Get-Boxstarter -Force

    $secpasswd = ConvertTo-SecureString "password" -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential ("ed", $secpasswd)

    $PackageName = if ($BoxstarterPackage) { $BoxstarterPackage } else { 'e:\vm.boxstarter' }
    Install-BoxstarterPackage -PackageName $PackageName -Credential $cred
} catch {
    New-Item -Path "C:\error.log" -ItemType "File" -Value "An error occurred: $_"
    Start-Sleep -Seconds 10
    shutdown /s /f /t 60 /c "An error occurred when installing Boxstarter"
    exit 1
}