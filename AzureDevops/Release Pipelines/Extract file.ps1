

#######################################
####		 Deploy Script  	   ####
#######################################


# IISWebSitePath ==> the Website Name managing in the AzureDevOps Variables
# $Env:SYSTEM_DEFAULTWORKINGDIRECTORY ==> Default folder when installed AzureDevOps agent

$pathToZipFile = $Env:SYSTEM_DEFAULTWORKINGDIRECTORY + "\_Folder Name\*\*.zip";

If(Test-Path -Path $pathToZipFile)
{
	Write-Output "#######: Deployement...";		
	if(!(Test-Path -path $(IISWebSitePath)))  
	{  
		 Write-Host "Website did not exists: ($(IISWebSitePath))"; 
	}
	else 
	{ 
		Write-Output "Deploy artifact at ($pathToZipFile) to website ($(IISWebSitePath))";
		Expand-Archive -Force -Path $pathToZipFile $(IISWebSitePath)
	}
}
Else
{
	Write-Output "Artifact File did not exists: ($pathToZipFile)";
}