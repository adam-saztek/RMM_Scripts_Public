#Last changed here: 2024-12-19
#Description: Turns on OneDrive and enables the backup feature (desktop, documents, etc).
#It doesn't work correctly if the user has both a company and personal Microsoft account using the same email address.

if ((Get-WmiObject Win32_OperatingSystem).Caption -Match "Windows 11") {
    Write-Host "OS: Windows 11"
    
    $subKey = Get-Item "HKLM:/SYSTEM/CurrentControlSet/Control/CloudDomainJoin/JoinInfo"
    $guids = $subKey.GetSubKeyNames()
    foreach($guid in $guids) {
        $guidSubKey = $subKey.OpenSubKey($guid);
        $tenantId = $guidSubKey.GetValue("TenantId");
        #$userEmail = $guidSubKey.GetValue("UserEmail");
    }

    if ($tenantId -match 'YourAzureTenantID'){
        Write-Host "STATUS: Joined to Azure Tenant"
        Write-Host "STATUS: Applying registry entries to enable OneDrive"

        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive"
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive" -Name "SilentAccountConfig" -PropertyType DWord -Value 1
        New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive" -Name "KFMSilentOptIn" -PropertyType String -Value "YourAzureTenantID"
    }

}
