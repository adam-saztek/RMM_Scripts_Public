#Last changed here: 2026-01-22

#Get User Desktop Folder
$userDesktopFolder = [Environment]::GetFolderPath("Desktop")

#List of shortcuts to delete
$FilenamesToDelete = @(
'SomeFile.lnk',
'AnotherFile.rdp'
)

foreach ($filename in $FilenamesToDelete)
{
    $pathToFile = -join($userDesktopFolder,'\',$filename)
	
	if(test-path $pathToFile -PathType Leaf)
		{
			Write-Host "INFO: $pathToFile exists"
			Remove-Item $pathToFile
			Write-Host "INFO: $pathToFile has been deleted"
		}
}
