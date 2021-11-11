

#######################################
####		 NLog Substitution 	   ####
#######################################
# Assume that, we will replace the AppInsights InstrumentationKey for NLog.Config when releasing
# The agent is running on Deployment Group Job.
# We add the Powershell Task after the Deployment Task in Release Stage
#$env:InstrumentationKey is the variables: EX: ApplicationInsights.InstrumentationKey or InstrumentationKey

Write-Output "Config Transform Substitution";
$serviceDir=$Env:SYSTEM_DEFAULTWORKINGDIRECTORY + "FolderApp";  # Point to the Folder running in Webserver

$nlogFileName="NLog.Config";
$originText='Your_Resource_Key' #It mentions in the file NLog.Config

$file = Get-ChildItem -Path "$serviceDir" -Filter "$nlogFileName" -recurse
IF( $file -ne "" -and $file.Count  -ne 0)
{
	 (Get-Content $file.FullName -Raw).Replace($originText,$env:InstrumentationKey) | 
	 Set-Content $file.FullName
}Else
{
	Write-Host "Did not exists file: $nlogFileName in folder: $serviceDir"
}
