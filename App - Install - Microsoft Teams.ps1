#Last changed here: 2025-08-22

$applicationName = "MSTeams"
$installerFilename = "MSTeamsSetup.exe"

if ((Get-WmiObject Win32_OperatingSystem).Caption -Match "Windows 11") {
    Write-Host "OS: Windows 11"
    
    $subKey = Get-Item "HKLM:/SYSTEM/CurrentControlSet/Control/CloudDomainJoin/JoinInfo"
    $guids = $subKey.GetSubKeyNames()
    foreach($guid in $guids) {
        $guidSubKey = $subKey.OpenSubKey($guid);
        $tenantId = $guidSubKey.GetValue("TenantId");
    }

    if ($tenantId -match 'AzureTenantID') {
        Write-Host "STATUS: Joined to Azure Tenant"

        if (!(get-appxpackage "$applicationName*"))
        {
            Write-Host "STATUS: $applicationName is not installed"
            
            $localInstallerFolder = "c:\itsupport\installers"
            $localInstallerPath = -join($localInstallerFolder,'\',$installerFilename)
            
            if(!(test-path $localInstallerPath -PathType Leaf))
            {
                Write-Host "ERROR: Installer file missing, not able to install $applicationName"
                exit 1
            }
            else
            {
                Start-Process $localInstallerPath -Wait
                Write-Host "STATUS: $applicationName has been installed"
            }

        }
        else
        {
            Write-Host "STATUS: $applicationName is already installed"
        }
    }

}
