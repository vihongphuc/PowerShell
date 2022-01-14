
# PowerShell Scripts
- We do the demo on features on PowerShell
- We are only have one main branch included many folder on each prject on one feature demo.

## I. AzureDevops 
- Working with AzureDevops pipeline
- All features are included:
- [ ] Release Pipelines\AppInsightSubstitustionNLogConfig.ps1 ==> replace Instrument Key in NLog.Config file when release.
- [ ] Release Pipelines\Extract file.ps1	==> extract file when release.
- [ ] Release Pipelines\remote-dacpac-deployer.ps1
- [ ] Release Pipelines\Start IIS.ps1	==> Start IIS 
- [ ] Release Pipelines\Stop IIS.ps1	==> Stop IIS 
> .

## II. Files 
- ==> Working with files in Local and SharePoing Online (SPO) Library
- Those main tasks are focusing for our demostration:
- [ ] DonwloadFileFromSPO.ps1 ==> Download files in SPO by Pnp.PowerShell
- [ ] SendEmails.ps1	==> Get list file in Local Folder and Send Email.
- [ ] UploadFileToSPO.ps1	==> Upload files to SPO by Pnp.PowerShell
- [ ] UploadFileToSPO_WebClient.ps1 ==> Upload files to SPO by Microsoft.SharePoint.Client.dll
- [ ] GetSPODataLis_UpdateDB.ps1 ==> Download Datalist in SPO and CRUD to MSSQL DB (CRUD_Country.sql)
- [ ] Download File from the list on CSV files
> - [X] Refer all materials in the folder: DownloadFileFromCSVList
> - [X] pictures.csv ==> The resources file included all download URL.
> - [X] DownloadImageOnCSV.ps1 ==> The main PowerShell Script to get list URL in CSV and downsload them.
> - [X] DownloadImageOnCSV.bat ==> The execution file. We can downliclick on it to run of setting it by Windows schedule. In this, we have the 03 main configs setting: Csv Path file, Downloaded folder and PS1 path which are hard config in this or we can pass them in Schedule.

