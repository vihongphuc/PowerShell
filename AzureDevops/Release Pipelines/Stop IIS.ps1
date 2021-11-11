
#$env:IISWebSiteName ==> the Website Name managing in the AzureDevOps Variables
# You can replace it by the variabe below to test
#IISWebSiteName = "FlaskWeb" ==> This is the Website name in the IIS.
Write-Host $env:IISWebSiteName

$Site = Get-IISSite $env:IISWebSiteName
If ($Site) {
    Write-Host "Stop Site: $Site.Name"
    Stop-IISSite -Name $Site.Name -Confirm:$False
}