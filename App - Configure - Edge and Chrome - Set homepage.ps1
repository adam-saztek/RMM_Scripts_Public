#Last changed here: 2025-03-11
#Description: Sets the default startup page for Edge and Chrome.  For a company Intranet, for instance.

#Intranet URL
$homepageURL = "https://somewebsite.com/go/to/this/page"

#List of required registry keys
$requiredChromeKeyList = @(
    'HKLM:\Software\Policies\Microsoft\Edge',
    'HKLM:\Software\Policies\Microsoft\Edge\RestoreOnStartupURLs',
    'HKLM:\SOFTWARE\Policies\Google', 
    'HKLM:\SOFTWARE\Policies\Google\Chrome',
    'HKLM:\SOFTWARE\Policies\Google\Chrome\RestoreOnStartupURLs')

#Add required registry keys if missing
foreach ($key in $requiredChromeKeyList){
    If ( -Not (Test-Path $key)) {
        New-Item -Path $key
    }
}

# Define Registry Key Hash:
$registryValueList = @(
    [PSCustomObject]@{
        'customData'      = $homepageURL;
        'customRegType'   = 'String';
        'customLocation'  = 'HKLM:\Software\Policies\Microsoft\Edge';
        'customValueName' = 'HomepageLocation'
    },
    [PSCustomObject]@{
        'customData'      = $homepageURL;
        'customRegType'   = 'String';
        'customLocation'  = 'HKLM:\Software\Policies\Microsoft\Edge\RestoreOnStartupURLs';
        'customValueName' = '1'
    },
    [PSCustomObject]@{
        'customData'      = $homepageURL;
        'customRegType'   = 'String';
        'customLocation'  = 'HKLM:\SOFTWARE\Policies\Google\Chrome';
        'customValueName' = 'HomepageLocation'
    },
    [PSCustomObject]@{
        'customData'      = '0';
        'customRegType'   = 'DWORD';
        'customLocation'  = 'HKLM:\SOFTWARE\Policies\Google\Chrome';
        'customValueName' = 'HomepageIsNewTabPage'
    },
    [PSCustomObject]@{
        'customData'      = $homepageURL;
        'customRegType'   = 'String';
        'customLocation'  = 'HKLM:\SOFTWARE\Policies\Google\Chrome\RestoreOnStartupURLs';
        'customValueName' = '1'
    }
)


#Create and set regsitry values from list
foreach ($item in $registryValueList){
    $itemExists = Get-ItemProperty -Path $item.customLocation -Name $item.customValueName -ErrorAction Ignore
    if (-not $itemExists){
        New-ItemProperty -Path $item.customLocation -Name $item.customValueName -Value $item.customData -PropertyType $item.customRegType
    } else {
        Set-ItemProperty -Path $item.customLocation -Name $item.customValueName -Value $item.customData
    }
}
