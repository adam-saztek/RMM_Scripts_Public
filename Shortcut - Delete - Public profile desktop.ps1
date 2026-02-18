#Last changed here: 2025-12-15
#Description: Deletes files, shortcuts, links off of the All Users desktop.  Used to clean up desktops cluttered up with legacy shortcuts.

$FilenamesToDelete = @(
'SomeFile.lnk',
'AnotherFile.url'
)

$publicDesktopFolder = [Environment]::GetFolderPath('CommonDesktopDirectory')

foreach ($filename in $FilenamesToDelete)
{
    $pathToFile = -join($publicDesktopFolder,'\',$filename)
	
	if(test-path $pathToFile -PathType Leaf)
		{
			Write-Host "$pathToFile exists"
			Remove-Item $pathToFile
			Write-Host "$pathToFile has been deleted"
		}
}
