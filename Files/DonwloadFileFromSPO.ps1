
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



$ClientID = "app registration client id"
$CertPath = "file.pfx"
$CertPass = "pasword of file.pfx"
$Password = (ConvertTo-SecureString -AsPlainText $CertPass -Force)
$SiteUrl  = "https://tanent-name.sharepoint.com/sites/site-name"
$AadDomain = "Application tenent id"

$LocalPathFiles="C:\temp\"
$SpoLibraryPath ="SPO Library/Childe Folerder Name"

$Params = @{
    ClientId            = $ClientID
    CertificatePath     = $CertPath
    CertificatePassword = $Password
    Url                 = $SiteUrl
    Tenant              = $AadDomain
}

$SPOCnn=Connect-PnPOnline @Params

$SpoFiles = Get-PnPFolderItem -FolderSiteRelativeUrl $SpoLibraryPath -ItemType File -Connection $SPOCnn
foreach($File in $SpoFiles) {	
    Get-PnPFile -Url $File.ServerRelativeUrl -Path $LocalPathFiles -FileName $File.Name -AsFile -Connection $SPOCnn
	Write-Host "Downloaded file: $($File.Name)"
}

#PowerShell.exe -ExecutionPolicy Bypass -File "DonwloadFileFromSPO.ps1"