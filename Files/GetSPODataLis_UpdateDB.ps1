
###############################################################################################
#user power shell PnP interact with SharePoint Online

#installtion
#	https://docs.microsoft.com/en-us/powershell/sharepoint/sharepoint-pnp/sharepoint-pnp-cmdlets
#	https://www.sharepointdiary.com/2018/03/connect-to-sharepoint-online-using-pnp-powershell.html

#connect
#	https://www.alanps1.io/powershell/connect-pnponline-unattended-using-azure-app-only-tokens/
# create certificate 
#	https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal
###############################################################################################

#Install SQL PowerShell
#https://www.powershellgallery.com/packages/SqlServer/21.1.18256


Function Execute-Procedure {
    Param(
        [Parameter(Mandatory=$true)][int]$id
        , [Parameter(Mandatory=$true)][string]$name
		, [Parameter(Mandatory=$true)][string]$description
		, [Parameter(Mandatory=$true)][string]$version
    )
    Process
    {
        $scon = New-Object System.Data.SqlClient.SqlConnection
        $scon.ConnectionString = "Data Source=localhost;Initial Catalog=DB_Name;User Id=sa;Password=password of this use;Integrated Security=false;MultipleActiveResultSets=True;"
        
        $cmd = New-Object System.Data.SqlClient.SqlCommand
        $cmd.Connection = $scon
        $cmd.CommandTimeout = 0
        $cmd.CommandText = "EXEC CRUD_Country $id, '$name', '$description', '$version'"

        try
        {
            $scon.Open()
            $cmd.ExecuteNonQuery() | Out-Null
			write-host "CRUD_Country $id, $name, $description, $version"
        }
        catch [Exception]
        {
            Write-Warning $_.Exception.Message
        }
        finally
        {
            $scon.Dispose()
            $cmd.Dispose()
        }
    }
}

#*************VHP*************
$ClientID = "app registration client id"
$CertPath = "file.pfx"
$CertPass = "pasword of file.pfx"
$Password = (ConvertTo-SecureString -AsPlainText $CertPass -Force)
$SiteUrl  = "https://tanent-name.sharepoint.com/sites/site-name"
$AadDomain = "Application tenent id"


$Params = @{
    ClientId            = $ClientID
    CertificatePath     = $CertPath
    CertificatePassword = $Password
    Url                 = $SiteUrl
    Tenant              = $AadDomain
}

Connect-PnPOnline @Params


$i=0;
$listItems= (Get-PnPListItem -List Country -Fields "ID", "Title","Name", "Code","Description","Version")  
foreach($listItem in $listItems){  	
   Write-Host "ID" : $listItem["ID"]  
   $version_XX = Get-PnPProperty -ClientObject $listItem -Property Versions | Select-Object -Last 1   
	Write-Host "Version" : $version_XX.VersionLabel.Split(' ')[0] 
	
	foreach($version in $listItem.Versions)  
    {  
        if($version.IsCurrentVersion)  
        {  
            Write-Host -ForegroundColor Yellow $version["Title"] " - Current Version: " $version.VersionLabel  
        }  
    }     
	
	If ($i -eq 0)
	{
		Execute-Procedure -id $listItem["ID"] -name $listItem["Name"] -description "$($listItem[""Description""])..."  -version $version_XX.VersionLabel.Split(' ')[0]	
	}
   $i++;
}  

#PowerShell.exe -ExecutionPolicy Bypass -File "GetSPODataLis_UpdateDB.ps1"
#select * from [dbo].[Country]
#-- EXEC CRUD_Country 1, 'Afghanistan', 'Asia', '10.0'	