try {
    . e:\vars.ps1
    iex ((new-object net.webclient).DownloadString('https://www.boxstarter.org/bootstrapper.ps1'))
    Get-Boxstarter -Force

    $secpasswd = ConvertTo-SecureString "password" -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential ("ed", $secpasswd)

    $PackageName = if ($BoxstarterPackage) { $BoxstarterPackage } else { 'e:\vm.boxstarter' }
    Install-BoxstarterPackage -PackageName $PackageName -Credential $cred
} catch {
    $errMsg = "An error occurred: $_"
    New-Item -Path "C:\error.log" -ItemType "File" -Value $errMsg -Force
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show($errMsg, "Boxstarter Error", "OK", "Error")
    Start-Sleep -Seconds 300
    shutdown /s /f /t 0 /c "Boxstarter installation failed"
    exit 1
}