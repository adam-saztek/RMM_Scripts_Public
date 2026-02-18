#Last changed here: 2025-10-07

#Check if it is a valid computer (Win 11)
if ((Get-WmiObject Win32_OperatingSystem).Caption -Match "Windows 11") {
    Write-Host "INFO: Windows 11"
} else {
    Write-Host "STATUS: Not Windows 11 - Exiting Script"
    exit
}

#Check if registry keys exist, if not create them to disable Explorer Network Icon

if (-not (Test-Path "HKCU:\Software\Classes\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}")) {
    New-Item -Path "HKCU:\Software\Classes\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -Force
}

#Check if the value already exists and is set to 0
$existingValue = Get-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -Name "System.IsPinnedToNameSpaceTree" -ErrorAction SilentlyContinue

if ($existingValue -eq 0) {
    Write-Host "INFO: Windows 11 Explorer Network Icon is already disabled"
} else {
    New-Itemproperty -path "HKCU:\Software\Classes\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" -Name "System.IsPinnedToNameSpaceTree" -Value 0 -Type DWord -Force
    Write-Host "STATUS: Windows 11 Explorer Network Icon has been disabled"
}