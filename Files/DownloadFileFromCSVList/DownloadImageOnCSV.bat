@ECHO OFF

SET PSScript="C:\temp\PS\PnPPowerShell\CSV\DownloadImageOnCSV.ps1"
SET csvFilePath="C:\temp\PS\PnPPowerShell\CSV\pictures.csv"
SET downloadFolderPath="C:\temp\PS\PnPPowerShell\CSV\download"

IF NOT [%1]==[] SET csvFilePath=%1
IF NOT [%2]==[] SET downloadFolderPath=%2

::echo  CSV Path is: %csvFilePath%
::echo  DOWNLOAD Path is: %downloadFolderPath%

PowerShell.exe -ExecutionPolicy Bypass -File "%PSScript%" -CsvPathFile "%csvFilePath%" -DownloadFolder "%downloadFolderPath%"
EXIT /B