#Last changed here: 2025-12-15
#Description: Creates a URL shortcut on the All User desktop.  Assumes you have a .ico icon file copied over by Syncro to apply to it so it doesn't use a generic Windows icon.

$shotcutURLDestination = "https:/somewebsite.com"
$shortcutFilename = "Somewebsite.url"
$iconFilename = "custom_icon_file.ico"
$localIconsFolder = "c:\itsupport\icons"
$localIconPath = -join("c:\itsupport\icons",'\',$iconFilename)
$publicDesktopFolder = [Environment]::GetFolderPath('CommonDesktopDirectory')
$publicDesktopPathToIcon = -join($publicDesktopFolder,'\',$shortcutFilename)

if(!(test-path $publicDesktopPathToIcon -PathType Leaf))
{
    Write-Host "$publicDesktopPathToIcon does not exist"
	
	if(!(test-path -PathType container $localIconsFolder))
	{
		Write-Host "$localIconsFolder does not exist"
		exit 1
	}
	
	if(!(test-path $localIconPath -PathType Leaf))
	{
		Write-Host "Icon file missing, not able to create $shortcutFilename shortcut"
		exit 1
	}
	
	$shell = New-Object -ComObject WScript.Shell
	$destination  = $shell.SpecialFolders.Item("AllUsersDesktop")
	$shortcutPath = Join-Path -Path $destination -ChildPath $shortcutFilename
	# create the shortcut
	$shortcut = $shell.CreateShortcut($shortcutPath)
	# for a .url shortcut only set the TargetPath
	$shortcut.TargetPath = $shotcutURLDestination
	$shortcut.Save()
	Add-Content -Path $shortcutPath -Value "IconFile=$localIconPath"
	Add-Content -Path $shortcutPath -Value "IconIndex=0"
	
	[System.Runtime.Interopservices.Marshal]::ReleaseComObject($shortcut) | Out-Null
	[System.Runtime.Interopservices.Marshal]::ReleaseComObject($shell) | Out-Null
	[System.GC]::Collect()
	[System.GC]::WaitForPendingFinalizers()
	
	Write-Host "$publicDesktopPathToIcon has been created"
}
else
{
	Write-Host "$publicDesktopPathToIcon exists"
}
