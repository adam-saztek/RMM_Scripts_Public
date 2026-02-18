#Last changed here: 2025-10-07

#Check if it is a valid computer (Win 11)
if ((Get-WmiObject Win32_OperatingSystem).Caption -Match "Windows 11") {
    Write-Host "INFO: Windows 11"
} else {
    Write-Host "STATUS: Not Windows 11 - Exiting Script"
    exit
}

#Check if registry keys exist, if not create them to disable Windows 11 Task View

if (-not (Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced")) {
    New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Force
}

#Check if the value already exists and is set to 0
$existingValue = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -ErrorAction SilentlyContinue

if ($existingValue -eq 0) {
    Write-Host "INFO: Windows 11 Task View is already disabled"
} else {
    New-Itemproperty -path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0 -Type DWord -Force
    Write-Host "STATUS: Windows 11 Task View has been disabled"
}