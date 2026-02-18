#Last changed here: 2025-10-07

#Check if it is a valid computer (Win 11)
if ((Get-WmiObject Win32_OperatingSystem).Caption -Match "Windows 11") {
    Write-Host "INFO: Windows 11"
} else {
    Write-Host "STATUS: Not Windows 11 - Exiting Script"
    exit
}

#Check if registry keys exist, if not create them to disable Windows 11 Search Bar

if (-not (Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search")) {
    New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Force
}

#Check if the value already exists and is set to 0
$existingValue = Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchBoxTaskbarMode" -ErrorAction SilentlyContinue

if ($existingValue -eq 0) {
    Write-Host "INFO: Windows 11 Search Bar is already disabled"
} else {
    New-Itemproperty -path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchBoxTaskbarMode" -Value 0 -Type DWord -Force
    Write-Host "STATUS: Windows 11 Search Bar has been disabled"
}