#Last changed here: 2025-04-27
#Puts a .bat file on the All Users desktop to kill a running task.  The idea is that if you have a flaky program that locks up, the user can kill it easily by double-clicking the .bat.

Import-Module $env:SyncroModule

$batchFilename = "Kill Some Task.bat"
$batchContents = 'taskkill /F /IM task_file_name.exe'
$publicDesktopFolder = [Environment]::GetFolderPath('CommonDesktopDirectory')
$publicDesktopPathToFile = -join($publicDesktopFolder,'\',$batchFilename)

if(!(test-path $publicDesktopPathToFile -PathType Leaf))
{
    Write-Host "INFO: $publicDesktopPathToFile does not exist"
	
	New-Item $publicDesktopPathToFile -ItemType File -Value $batchContents

	if(test-path $publicDesktopPathToFile -PathType Leaf)
	{
		Write-Host "INFO: $publicDesktopPathToFile has been created"
	}
	else
	{
		Write-Host "ERROR: $publicDesktopPathToFile failed to be created"
		Rmm-Alert -Category 'Application' -Body 'Kill Some Task.bat failed to be created'
	}
	
}
else
{
	Write-Host "INFO: $publicDesktopPathToFile exists"
}
