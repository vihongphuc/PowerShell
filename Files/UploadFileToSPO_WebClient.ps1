#Load SharePoint CSOM Assemblies
# Installation LINK: https://www.microsoft.com/en-us/download/details.aspx?id=42038
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

$CurrentDate = (Get-Date).toString("yyyyMMdd")
$LogsFolder= "Logs"
If(!(test-path $LogsFolder))
{
      New-Item -ItemType Directory -Force -Path $LogsFolder
}

$Logfile = "$LogsFolder\PDFsToSpoHistory_$env:computername_$CurrentDate.log"
Write-Host "Logfile: $Logfile" 

Function WriteLog
{
	Param ([string]$LogString)
	$Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
	$LogMessage = "$Stamp $LogString"
	Add-content $LogFile -value $LogMessage
}


Function SharePoint_GetChildForder()
 { 
    param
    (	
		[Parameter(Mandatory=$true)] [Microsoft.SharePoint.Client.ClientContext] $Ctx,
        [Parameter(Mandatory=$true)] [Microsoft.SharePoint.Client.Folder] $SourceFolder,
        [Parameter(Mandatory=$true)] [string] $LibraryName_Child
    )
    Try {
        $ChildFoldes = $SourceFolder.Folders
		$Ctx.Load($ChildFoldes) 
		$Ctx.ExecuteQuery()
		return $ChildFoldes | Where { $_.Name -eq $LibraryName_Child}
    }
    Catch {
         write-host -f Red "Error SharePoint_GetChildForder from Library!" $_.Exception.Message
		 WriteLog "Error SharePoint_GetChildForder from Library! $_.Exception.Message" 
    }
 } 
 
Function SharePoint_AddChildForder()
 { 
    param
    (	
		[Parameter(Mandatory=$true)] [Microsoft.SharePoint.Client.ClientContext] $Ctx,
        [Parameter(Mandatory=$true)] [Microsoft.SharePoint.Client.Folder] $SourceFolder,
        [Parameter(Mandatory=$true)] [string] $LibraryName_Child
    )
    Try {
		$SourceFolder.Folders.Add($LibraryName_Child)
		$Ctx.Load($SourceFolder) 
		$Ctx.ExecuteQuery()
    }
    Catch {
         write-host -f Red "Error SharePoint_AddChildForder from Library!" $_.Exception.Message
		 WriteLog "Error SharePoint_AddChildForder from Library! $_.Exception.Message" 
    }
 }
 
 Function SharePoint_UploadFiles()
 { 
    param
    (	
		[Parameter(Mandatory=$true)] [Microsoft.SharePoint.Client.ClientContext] $Ctx,
        [Parameter(Mandatory=$true)] [Microsoft.SharePoint.Client.Folder] $SourceFolderSharePoint,
		[Parameter(Mandatory=$true)] [string] $SourceFolderLocal
    )
    Try {
		#upload each file from the directory
		Foreach ($File in  (dir $SourceFolderLocal -File))
		{
			#Get the file from disk
			$FileStream = ([System.IO.FileInfo] (Get-Item $File.FullName)).OpenRead()
		   
			#Upload the File to SharePoint Library
			$FileCreationInfo = New-Object Microsoft.SharePoint.Client.FileCreationInformation
			$FileCreationInfo.Overwrite = $true
			$FileCreationInfo.ContentStream = $FileStream
			$FileCreationInfo.URL = $File
			
			#$FileUploaded = $Library.RootFolder.Files.Add($FileCreationInfo)	
			$FileUploaded = $SourceFolderSharePoint.Files.Add($FileCreationInfo)	
			
			#powershell to upload files to sharepoint online
			$Ctx.Load($FileUploaded) 
			$Ctx.ExecuteQuery() 
		 
			#Close file stream
			$FileStream.Close()
		 
			WriteLog "SUCCEED. $($File) ==> $($SourceFolderSharePoint.ServerRelativeUrl)"
			write-host "File: $($File) has been uploaded!"
		} 
		
		return $true
    }
    Catch {
         write-host -f Red "Error SharePoint_UploadFiles from Library!" $_.Exception.Message
		 WriteLog "SharePoint_UploadFiles.FAILED:: $($File) ==> $($SourceFolderSharePoint.ServerRelativeUrl)"
		 return $false
    }
 }
 

### Script Parameters
$SiteUrl  = "https://tanent-name.sharepoint.com/sites/site-name"
$UserName ="email"
$Password ="pass"

$LibraryName ="Library Name"
$LibraryName_Child ="child folder"
$LocalPathFiles="C:\temp\"


#Setup Credentials to connect
$Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName,(ConvertTo-SecureString $Password -AsPlainText -Force))
  
#Set up the context
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteUrl) 
$Context.Credentials = $Credentials

#Get the Library
$Library =  $Context.Web.Lists.GetByTitle($LibraryName)

#Get SharePoint Child Folder
If ([string]::IsNullOrWhitespace($LibraryName_Child)){
	$UploadingFolder = $Library.RootFolder
}Else
{
	$UploadingFolder = SharePoint_GetChildForder -Ctx $Context -SourceFolder $Library.RootFolder -LibraryName_Child $LibraryName_Child 
}

$CurrentDate = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
Write-Host "SPO Root URL: $SiteUrl!" 
WriteLog "################################################################################" 
WriteLog "Uploading files to SPO Document Library"
WriteLog "Starting: 	$CurrentDate"
WriteLog "Local Url:	$LocalPathFiles" 
WriteLog "Spo Root Url: $SiteUrl" 
WriteLog "" 

write-host "SPO Root URL: $SiteUrl!" 
#upload each file from the directory
$UploadedFilesStatus = SharePoint_UploadFiles -Ctx $Context -SourceFolderSharePoint $UploadingFolder -SourceFolderLocal $LocalPathFiles

Write-Host "Upload Files status: $($UploadedFilesStatus)"
WriteLog "################################################################################" 
#PowerShell.exe -ExecutionPolicy Bypass -File "UploadFileToSPO_WebClient.ps1"


