
Param(
    [string]$CsvPathFile,
    [string]$DownloadFolder
)

Write-Host " CsvPathFile: $CsvPathFile"
Write-Host " DownloadFolder: $DownloadFolder"

Function Download()
{ 
    param
    (	
        [Parameter(Mandatory=$true)] [string] $SourceUrl,
		[Parameter(Mandatory=$true)] [string] $DestinationFolder
    )

	Try{
		#Solution 1 - WebClient
		$wc = New-Object System.Net.WebClient
		$wc.DownloadFile($SourceUrl, $DestinationFolder)		

		#Solution 2- WebRequest
		#Invoke-WebRequest -Uri $SourceUrl -OutFile $DestinationFolder
		
		write-host -f Green " Succeed..."
	}
	Catch{
		$_.Exception.Message | out-file C:\temp\error_smtp.log
		write-host -f Red " Error in Download:" $_.Exception.Message
	}
}

$PicContents = import-csv $CsvPathFile
Foreach ($Pic in $PicContents)
{
	$DesFolder="$($DownloadFolder)\$($Pic.Name)"
	Write-Host " ID: $($Pic.ID);Name: $($Pic.Name); Folder: $($DesFolder); URL: $($Pic.URL)"
	Download -SourceUrl $($Pic.URL) -DestinationFolder $DesFolder
}
