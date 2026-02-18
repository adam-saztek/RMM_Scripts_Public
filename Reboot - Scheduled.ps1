#Last changed here: 2025-06-30
#Description: Can be used to reboot devices based off of certain criteria, such as name, number of days since last reboot, type of device

#Workstation name
$workstationName = $env:computerName

#Workstations to ignore
$ignoreWorkstations = @(
    "Worstation1",
    "Workstation32"
)

#Calculate last boot time
$lastBootTime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
$timeSinceBoot = (Get-Date) - $lastBootTime

$rebootWorkstation = $false

$skipWorkstation = $false

#Is workstation on the ignore list
Write-Host "INFO: Checking if workstation $workstationName is on ignore list"
foreach ($ignoreWorkstation in $ignoreWorkstations)
{
    if ($workstationName.StartsWith($ignoreWorkstation))
    {
        $skipWorkstation = $true
        break
    }
}

#If the workstation restarted within a day
$rebootedInLastOneDays = $timeSinceBoot.TotalDays -lt 1

if ($rebootedInLastOneDays)
{
    Write-Host "INFO: Workstation has rebooted in the last 1 days"
    $rebootWorkstation = $false
}
else
{
    Write-Host "INFO: Workstation has not rebooted in the last 1 days"
    $rebootWorkstation = $true
}

#If workstation is a laptop
if ((Get-Computerinfo).CsPCSystemType -eq 'mobile')
{
    Write-Host "INFO: Workstation $workstationName is laptop"
    $rebootedInLastTwoDays = $timeSinceBoot.TotalDays -lt 2
    $daysSinceLastBoot = $timeSinceBoot.TotalDays

    if ($rebootedInLastTwoDays)
    {
        Write-Host "INFO: Laptop has rebooted in the last 2 days"
        $rebootWorkstation = $false
    }
    else
    {
        Write-Host "INFO: Laptop has not rebooted in the last 2 days"
        Write-Host "INFO: Laptop last rebooted $daysSinceLastBoot days ago"
        $rebootWorkstation = $true
    }
    
    $rebootWorkstation = $false

}

#If workstation is for some department or group that should alway be restarted
if ($workstationName -like '*departmentx*')
{
    Write-Host "INFO: Workstation $workstationName is whatever department workstation, rebooting"
    $rebootWorkstation = $true
}

#If workstation is on ignore list
if ($skipWorkstation)
{
    Write-Host "INFO: Workstation $workstationName is on ignore list"
    $rebootWorkstation = $false
}

if ($rebootWorkstation)
{
    Write-Host "INFO: Rebooting workstation"
    Restart-Computer -Force
}
else {
    Write-Host "INFO: Skipping Reboot"
}
