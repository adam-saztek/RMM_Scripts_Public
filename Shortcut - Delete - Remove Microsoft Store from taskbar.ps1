#Last changed here: 2025-04-27

Import-Module $env:SyncroModule

#Remove Microsoft Store from taskbar
$registryKeyName = 'HKLM:\Software\Policies\Microsoft\Windows\Explorer'
$registryValueName = 'NoPinningStoreToTaskbar'
$registryValueData = '1'
$registryValueType = 'DWORD'

#If registry key exists
if (Test-Path -Path $registryKeyName)
{
    Write-Host "INFO: Registry key $registryKeyName already exists"
}
#If not, create it
else
{
    Write-Host "INFO: Registry key $registryKeyName does not exist, creating..."
    New-Item -Path $registryKeyName

    if (Test-Path -Path $registryKeyName)
    {
        Write-Host "INFO: Registry key successfully created"
    }
    else
    {
        Write-Host "ERROR: Registry key failed to create"
        Rmm-Alert -Category 'Application' -Body 'Failed to create registry key'
        exit 1
    }
}

#if registry value exists
$registryValueExists = Get-ItemProperty -Path $registryKeyName -Name $registryValueName -ErrorAction Ignore
if (-not $registryValueExists)
{
    New-ItemProperty -Path $registryKeyName -Name $registryValueName -Value $registryValueData -PropertyType $registryValueType
}
else
{
    Set-ItemProperty -Path $registryKeyName -Name $registryValueName -Value $registryValueData
}