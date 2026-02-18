#Last changed here: 2024-12-19

$currentTimeZone = (Get-TimeZone).Id

if ($currentTimeZone -ne "US Mountain Standard Time")
{
    Write-Host "Time Zone is not US Mountain Standard Time"
	Write-Host "Time Zone is set to $currentTimeZone"
	Set-TimeZone -Id "US Mountain Standard Time"
	Write-Host "Time Zone has been set to US Mountain Standard Time"
}
else {
	Write-Host "Time Zone is set to US Mountain Standard Time"
}
