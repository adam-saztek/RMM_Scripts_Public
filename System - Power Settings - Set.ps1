#Last changed here: 2024-12-19
#Description: Sets workstations to not sleep and to turn off the monitor in 15 minutes

if ((Get-WmiObject Win32_ComputerSystem).PartOfDomain)
{
    Write-Host "Workstation is on Active Directory, will not set power settings"
}
else
{
    Write-Host "Setting workstation to not sleep"
    powercfg -change -standby-timeout-ac 0
    Write-Host "Setting workstation to not shut off monitor for 15 minutes"
    powercfg -change -monitor-timeout-ac 15

}
