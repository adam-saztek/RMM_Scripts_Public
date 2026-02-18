#Last changed here: 2026-02-11
#Installs network printers and deletes old ones.  This script gets the print drivers from a web server.  Print drivers can be bigger than the size allowed by Syncro, and this script
#only downloads the drivers needed.  You will have to specify the .inf file for the print driver (usually only one, easy to find) and the name of the printer driver in the .inf, usually listed
#at the top of the .inf.  The driver files should be saved on the web server as the same name as the printName variable + .zip, so "Some Printer Name.zip".  If the printer has more complex
#settings than duplex, paper size and drawer settings, for instance, you can set up the printer on an initial PC, make all of the settings changes to the printer, then export out the printer
#setting .xml file to also put on the web server to be downloaded and applied during the printer install.  The allowedWorstations variable actually matches the first part of the workstation name
#so if you prefix your workstation names, such as "LAB-" or "FLOOR1-" you can just put that in the allowedWorkstations variable and it will install that printer on every workstation that
#starts with those letters.

$activePrinters = @(
    [pscustomobject]@{
        printerName='Some Printer Name';
        IPAddress='192.168.1.21';
        driverInfFile='printer_driver_inf_file.inf';
        driverName="Driver Name (from printer_driver_inf_file.inf)";
        duplex="FALSE";
        allowedWorkstations="Workstation1"},
    [pscustomobject]@{
        printerName='Another Printer';
        IPAddress='192.168.1.22';
        driverInfFile='another_printer_driver_inf_file.inf';
        driverName="Driver Name (from another_printer_driver_inf_file.inf)";
        duplex="TRUE";
        allowedWorkstations="Workstation1 Workstation2"}
)

$deletePrinters = @(
    "Old Printer To Delete 1",
    "Old Printer To Delete 2",
    "Another Old Printer To Delete"
)

#NOTE: Format for exporting XML config from printer properties:
#   $PrinterName = "Your Printer Name"
#   $PrintConfig = Get-PrintConfiguration -PrinterName $PrinterName
#   $PrintTicketXml = $PrintConfig.PrintTicketXML
#   $PrintTicketXml | Out-File -FilePath C:\Temp\printsettings.xml


#NOTE: $downloadUsername and $downloadPassword are supplied as Sycro Script Variables

$securePassword = ConvertTo-SecureString $downloadPassword -AsPlainText -Force
$downloadCredentials = New-Object System.Management.Automation.PSCredential ($downloadUsername, $securePassword)

$workstationName = $env:computerName
Write-Host "Workstation Name: $workstationName"

Write-Host "PRINTER INSTALL CHECK"

$localPrintersFolder = "c:\itsupport\printers"
$printerCount = 0

foreach($printer in $activePrinters)
{
    $printerCount++
    
    $allowedWorkstations = -split $printer.allowedWorkstations
    $printerName = $printer.printerName
    $driverName = $printer.driverName
    $printerIP = $printer.IPAddress
    $driverInfFile = $printer.driverInfFile
    $driverName = $printer.driverName

    if ($printer.duplex -eq "TRUE")
    {
        $enableDuplex = $true
    }
    else { $enableDuplex = $false }

    $validWorkstation = $false
    
    Write-Host "Printer ${printerCount}: Checking printer: $printerName"

    foreach ($allowedWorkstation in $allowedWorkstations)
    {
        if ($workstationName.StartsWith($allowedWorkstation))
        {
            $validWorkstation = $true
            break
        }
    }

    if ($validWorkstation)
    {
              
        Write-Host "Printer ${printerCount}: Valid printer for this workstation"

        if (!(get-printer "$printerName*"))
        {
            Write-Host "Printer ${printerCount}: Printer not installed, starting install process"
        
            #Check if the print driver is already installed on the PC, download and install if it is not
            if (!(Get-PrinterDriver "$driverName"))
            {
                Write-Host "Printer ${printerCount}: Print driver `"$driverName`" does not exist on system, installing..."

                $driverZipName = -join($printerName,".zip")
                $localPrinterDriverFolder = -join($localPrintersFolder,'\',$printerName)
                $localDriverPath = -join($localPrintersFolder,'\',$driverZipName)
                $printerDriverURL = -join("https://your.fileserver.com/printers/",$driverZipName)
            
                #Make driver folder
                Write-Host "Printer ${printerCount}: Creating folder `"$localPrinterDriverFolder`""
                New-Item -ItemType Directory -Path $localPrinterDriverFolder
            
                #Download printer driver zip
                Write-Host "Printer ${printerCount}: Downloading driver..."
                Invoke-WebRequest $printerDriverURL -Outfile $localDriverPath -Credential $downloadCredentials
            
                #Unzip driver
                Write-Host "Printer ${printerCount}: Unzipping `"$driverZipName`" to `"$localPrinterDriverFolder`""
                Expand-Archive -Path $localDriverPath -DestinationPath $localPrinterDriverFolder -Force
            
                #Add driver to Windows driver store
                Write-Host "Printer ${printerCount}: Adding driver to Windows driver store"
                $driverInfPath = -join($localPrinterDriverFolder,'\',$driverInfFile)
                Write-Host "Printer ${printerCount}: INF File: ${driverInfPath}"
                Pnputil /add-driver $driverInfPath
            
                #Install printer driver to local print server
                Write-Host "Printer ${printerCount}: Adding driver `"$driverName`" to local print server"
                Add-PrinterDriver -Name $driverName
            }
            else
            {
                Write-Host "Printer ${printerCount}: Print driver for `"$printerName`" is already installed, proceeding to set up the printer..."
            }

            #Make printer port
            $printerPort = -join($printerName,' ',$printerIP)
            Write-Host "Printer ${printerCount}: Creating printer port `"$printerPort`""
            Add-PrinterPort -Name $printerPort -PrinterHostAddress $printerIP
        
            #Create printer
            Write-Host "Printer ${printerCount}: Creating printer `"$printerName`""
            Add-Printer -DriverName $driverName -Name $printerName -PortName $printerPort
        
            #Set Single sided printing
            if ( $enableDuplex )
            {
                Set-PrintConfiguration -PrinterName $printerName -DuplexingMode TwoSidedLongEdge
            }
            else
            {
                Set-PrintConfiguration -PrinterName $printerName -DuplexingMode OneSided
            }

            #Set Black and White printing if name includes BW
            if ($printerName.Contains("BW"))
            {
                Set-PrintConfiguration -PrinterName $printerName -Color $false
            } 
        
            #Apply XML Config, if available for download
            $printerXmlFileName = -join($printerName,".xml")
            $localXmlPath = -join($localPrintersFolder,'\',$printerXmlFileName)
            $printerXmlURL = -join("https://files.saztek.link/printers/",$printerXmlFileName)

            Write-Host "Printer ${printerCount}: Downloading XML config file, if available..."
            Invoke-WebRequest $printerXmlURL -Outfile $localXmlPath -Credential $downloadCredentials
            if(test-path $localXmlPath -PathType Leaf)
            {
                Write-Host "Printer ${printerCount}: XML config file found, installing..."
                Write-Host "Printer ${printerCount}: XML File path: $localXmlPath"
                $XMLA = Get-Content "$localXmlPath" | Out-String
                Set-PrintConfiguration -PrinterName $printerName -PrintTicketXml $XMLA
            }
            else {Write-Host "Printer ${printerCount}: No XML config file available to download"}
            
            #Set Single sided printing
            if ( $enableDuplex )
            {
                Set-PrintConfiguration -PrinterName $printerName -DuplexingMode TwoSidedLongEdge
            }
            else
            {
                Set-PrintConfiguration -PrinterName $printerName -DuplexingMode OneSided
            }

            #Confirming if printer actually installed
            if (get-printer "$printerName*")
            {
                Write-Host "Printer ${printerCount}: Printer `"$printerName`" installed successfully"
            }
            else 
            {
                Write-Host "Printer ${printerCount}: Printer `"$printerName`" install failed"
                Import-Module $env:SyncroModule
                Rmm-Alert -Category 'Printer' -Body "Printer `"$printerName`" install failed"
                exit 1
            }
        }
        else {
            Write-Host "Printer ${printerCount}: Printer already installed"
        }
    }
    else
    {
        Write-Host "Printer ${printerCount}: Not a valid printer for this workstation"
    }

}

Write-Host "PRINTER DELETE CHECK"

foreach ($deletePrinter in $deletePrinters)
{
    if (Get-Printer -Name $deletePrinter -ErrorAction SilentlyContinue)
    {
        Write-Host "Printer `"$deletePrinter`" exists, attempting to delete"
        Remove-Printer -Name $deletePrinter

        #Check if printer actually deleted
        if (Get-Printer -Name $deletePrinter -ErrorAction SilentlyContinue)
        {
            Write-Host "Printer `"$deletePrinter`": Printer removal failed"
            Import-Module $env:SyncroModule
            Rmm-Alert -Category 'Printer' -Body "Printer `"$deletePrinter`": Printer removal failed"
            exit 1
        }

    }
}

Import-Module $env:SyncroModule
Close-Rmm-Alert -Category "Printer" -CloseAlertTicket "true"
