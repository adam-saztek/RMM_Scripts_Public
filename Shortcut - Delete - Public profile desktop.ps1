#Last changed here: 2025-12-15

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
