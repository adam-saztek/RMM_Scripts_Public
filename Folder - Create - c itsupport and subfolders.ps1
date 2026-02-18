#Last changed here: 2025-08-03
#Description: It's not uncommon for a MSP to have their own folder in c:\ for RMM management purposes.  This script creates the basic folder structure.

$itsupportFolders = @(
'C:\itsupport'
'C:\itsupport\apps'
'C:\itsupport\icons'
'C:\itsupport\installers'
'C:\itsupport\printers'
)

foreach ($currentFolder in $itsupportFolders)
{
    if(!(test-path -PathType container $currentFolder))
	{
		Write-Host "INFO: $currentFolder does not exist"
		New-Item -ItemType Directory -Path $currentFolder
		Write-Host "INFO: $currentFolder created"
	}
	else
	{
		Write-Host "INFO $currentFolder folder exists"
	}

}
