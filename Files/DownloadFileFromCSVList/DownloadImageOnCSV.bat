::$args[0] 
@ECHO OFF
SET PSScript="C:\temp\PS\PnPPowerShell\CSV\DownloadImageOnCSV.ps1"
SET csvFilePath="C:\temp\PS\PnPPowerShell\CSV\pictures.csv"
SET downloadFolderPath="C:\temp\PS\PnPPowerShell\CSV\download"

::PowerShell.exe -ExecutionPolicy Bypass -File DownloadImageOnCSV.ps1 "C:\temp\PS\PnPPowerShell\CSV\pictures.csv" "C:\temp\PS\PnPPowerShell\CSV\download"
PowerShell.exe -ExecutionPolicy Bypass -File "%PSScript%" -CsvPathFile "%csvFilePath%" -DownloadFolder "%downloadFolderPath%"
EXIT /B