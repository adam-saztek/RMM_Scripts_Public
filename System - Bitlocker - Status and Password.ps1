#Last changed here: 2025-03-07
#Description: Gets the status and recovery password for the C drive of a workstation and populates that information to Syncro assess fields, so they appear in the workstation's page in Syncro.
#Also creates a Syncro alert if Bitlocker is not enabled.

Import-Module $env:SyncroModule

$BitlockerStatus = Get-BitLockerVolume -MountPoint C: | Select-Object VolumeStatus

if ($BitlockerStatus.VolumeStatus -eq "FullyDecrypted")
{
    $BitlockerPassword = "Not Applicable"
}
else 
{
    $BitlockerPassword = (Get-BitLockerVolume -MountPoint C:).KeyProtector.RecoveryPassword
}

Set-Asset-Field -Name "BitLocker - Status" -Value $BitlockerStatus.VolumeStatus

Set-Asset-Field -Name "BitLocker - C Drive Recovery Password" -Value $BitlockerPassword

#Alert if laptop or remote desktop is not BitLocked
if ($BitlockerStatus.VolumeStatus -ne "FullyEncrypted")
{
    if ((Get-Computerinfo).CsPCSystemType -eq 'mobile')
    {
        Rmm-Alert -Category 'Bitlocker' -Body 'BitLocker not enabled on laptop'
    }
    elseif ($env:computerName.StartsWith("REMOTE-"))
    {
        Rmm-Alert -Category 'Bitlocker' -Body 'BitLocker not enabled on remote computer (probably a desktop)'
    }
}
