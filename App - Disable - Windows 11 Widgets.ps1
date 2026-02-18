#Last changed here: 2025-10-07
#Description: Disabled Widgets in Windows 11.  This removes the Widgets button and flyout from the left side of the taskbar and removes the widgets that appear on the Windows login screen.

#Check if it is a valid computer (Win 11)
if ((Get-WmiObject Win32_OperatingSystem).Caption -Match "Windows 11") {
    Write-Host "INFO: Windows 11"
} else {
    Write-Host "STATUS: Not Windows 11 - Exiting Script"
    exit
}

#Check if registry keys exist, if not create them to disable Windows 11 Widgets
#Reference: https://www.itechtics.com/disable-windows-11-widgets/

if (-not (Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh")) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Force
}

#Check if the value already exists and is set to 0
$existingValue = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests" -ErrorAction SilentlyContinue

if ($existingValue -eq 0) {
    Write-Host "INFO: Windows 11 Widgets are already disabled"
} else {
    New-Itemproperty -path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests" -Value 0 -Type DWord -Force
    Write-Host "STATUS: Windows 11 Widgets have been disabled"

}
