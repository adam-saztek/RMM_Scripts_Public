#Last changed here: 2025-04-22

Import-Module $env:SyncroModule

$userName = "localadminusername"
$fullName = "Local Admin User Name"
#NOTE: $userPassword is supplied as Sycro Script Variable
$securePassword = ConvertTo-SecureString $userPassword -AsPlainText -Force

#If local admin user already exists
if ((Get-LocalUser).Name -contains $userName)
{
    Write-host "INFO: User $userName already exists"
    
    #Set password
    Set-LocalUser -Name $userName -Password $securePassword
    Write-host "INFO: Set password"

    #Is local admin user password set to never expire
    $userProperty = Get-LocalUser -Name $userName
    if ($userProperty.PasswordExpires -eq $false)
    {
        Write-host "ALERT: Password set to expire"
        $userProperty | Set-LocalUser -PasswordNeverExpires $true
        Write-host "INFO: Password expiration removed"
    }
    else { Write-host "INFO: Password set to not expire" }
        
    #Is local admin user a local administrator
    $adminList = net localgroup administrators

    # Check to see if this user is an administrator and act accordingly
    if ($adminList -match $userName)
    {
        Write-host "INFO: User $userName is local administrator"
    } 
    else
    {
        Write-host "ERROR: User $userName is NOT a local administrator"
        #Sycro alert if local admin user is no longer local admin
        Rmm-Alert -Category 'LocalUsers' -Body "Error: $userName no longer local administrator"
        Add-LocalGroupMember -Group "Administrators" -Member "$userName"
        Write-host "INFO: User $userName has been added to local administrators group"
    }

}
#If local admin user does not exist
else
{
    Write-host "INFO: User $userName does not exist"
    New-LocalUser "$userName" -Password $securePassword -FullName "$fullName"
    Add-LocalGroupMember -Group "Administrators" -Member "$userName"
    $userProperty = Get-LocalUser -Name $userName
    $userProperty | Set-LocalUser -PasswordNeverExpires $true

    if ((Get-LocalUser).Name -contains $userName)
    {
        Write-host "INFO: User $userName has been successfully created"
    }
    else
    {
        Write-host "ERROR: User $userName was not successfully created"
        Rmm-Alert -Category 'LocalUsers' -Body "Error creating user $userName"
    }
}
