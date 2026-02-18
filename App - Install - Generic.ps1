#Last changed here: 2025-08-22
#Application installer.  Works with .msi files and .exes that have a silent install option.

$applicationName = "Application Name"
$installerFilename = "ApplicationInstaller.exe"
$installerArguments = "/silent /noreboot /WhateverOtherSwitches"

if (!(get-package "$applicationName*"))
{
    Write-Host "$applicationName is not installed"
    Write-Host "Downloading installer for $applicationName"

    $localInstallerFolder = "c:\itsupport\installers"
    $localInstallerPath = -join($localInstallerFolder,'\',$installerFilename)
	
	if(!(test-path $localInstallerPath -PathType Leaf))
	{
		Write-Host "Installer file missing, not able to install $applicationName"
		exit 1
	}
	else
	{
		Start-Process $localInstallerPath -Wait -ArgumentList $installerArguments
		Write-Host "$applicationName has been installed"
	}

}
else
{
	Write-Host "$applicationName is already installed"
}
