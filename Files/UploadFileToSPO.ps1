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
Function GenerateRow()
{ 
    param
    (	
        [Parameter(Mandatory=$true)] [int] $rowNo,
		[Parameter(Mandatory=$true)] [string] $fileName,
		[Parameter(Mandatory=$true)] [string] $spoPath,
		[Parameter(Mandatory=$true)] [string] $status
    )
	
    Try{
		$stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
		$rowNoValue=$rowNo.ToString();
		$rowStyle=""				
		If($rowNo -eq 0)
		{
			$stamp = "Date";
			$rowNoValue="No.";			
			$rowStyle="style=""background-color:blue; color:white;"""			
		}ElseIf ($rowNo % 2 -ne 0) {
			$rowStyle="style=""background-color:lightgray;"""
			If($status -ne "SUCCEED")
			{
				$rowStyle="style=""background-color:lightgray; color:red; font-weight:bold;"""
			}
		}ElseIf($status -ne "SUCCEED")
		{
			$rowStyle="style=""background-color:lightgray; color:red; font-weight:bold;"""
		}
		
		$rowContent = "<tr $rowStyle>
				<td style=""border: solid 1px black;"">$rowNoValue</td>
				<td style=""border: solid 1px black;"">$fileName</td>
				<td style=""border: solid 1px black;"">$spoPath</td>
				<td style=""border: solid 1px black;"">$stamp</td>
				<td style=""border: solid 1px black;"">$status</td>
			</tr>"
			return $rowContent;
	}
	Catch{
		write-host $_.Exception.Message 
		return "";
	}
}

Function EmailNotification()
{ 
    param
    (	
        [Parameter(Mandatory=$true)] [string] $Subject,
		[Parameter(Mandatory=$true)] [string] $Body,
		[Parameter(Mandatory=$true)] [int] $Priority
    )

	$secpasswd = ConvertTo-SecureString $SMTPPwCredential -AsPlainText -Force
	$mycreds = New-Object System.Management.Automation.PSCredential ($SMTPUsCredential, $secpasswd)

	Try{
		If($Priority -eq 2)
		{
			Send-MailMessage -Credential $mycreds -SmtpServer $smtpserver -Port $port -From $emailfrom -To $emailto -Subject $Subject -Body $Body -BodyAsHtml -Priority High -DeliveryNotificationOption OnFailure
		}Else{
			Send-MailMessage -Credential $mycreds -SmtpServer $smtpserver -Port $port -From $emailfrom -To $emailto -Subject $Subject -Body $Body -BodyAsHtml
		}
		
	}
	Catch{
		$_.Exception.Message | out-file C:\temp\error_smtp.log
		write-host -f Red "Error in EmailNotification:" $_.Exception.Message
	}
}

### SMTP Parameters
$SMTPUsCredential="email address"
$SMTPPwCredential="pass word"

$emailfrom="Name <email>"
$emailto  ="Name <email>"
$port=25
$smtpserver="smtp url"

### Script Parameters
$ClientID = "app registration client id"
$CertPath = "file.pfx"
$CertPass = "pasword of file.pfx"
$Password = (ConvertTo-SecureString -AsPlainText $CertPass -Force)
$SiteUrl  = "https://tanent-name.sharepoint.com/sites/site-name"
$AadDomain = "Application tenent id"

$LocalSourceFolder="C:\temp\"
$SpoLibraryPath ="SPO Library/Childe Folerder Name"


$Params = @{
    ClientId            = $ClientID
    CertificatePath     = $CertPath
    CertificatePassword = $Password
    Url                 = $SiteUrl
    Tenant              = $AadDomain
}

Connect-PnPOnline @Params

$CurrentDate = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
Write-Host "SPO Root URL: $SiteUrl!" 
WriteLog "################################################################################" 
WriteLog "Uploading Files to SPO Document Library"
WriteLog "Starting: 	$CurrentDate"
WriteLog "Local Url:	$LocalSourceFolder" 
WriteLog "Spo Root Url: $SiteUrl" 
WriteLog "" 

$EmailPriority=1
$rowNumber=0
$rowContents =""
$tmpRow = GenerateRow -rowNo $rowNumber -fileName "File Name" -spoPath "SPO" -status "Status"
$rowContents = $rowContents + $tmpRow

$loopTime=0
$succeed=$False
Foreach ($File in  (dir $LocalSourceFolder -File))
{
	$rowNumber++;	
		
	$loopTime=0
	$succeed=$False
	While (-NOT  $succeed -AND $loopTime -ne 3){
		Write-Host "$($loopTime) - $($succeed): Uploading Files: $($File.FullName) ==> $($SpoLibraryPath)"
		Try {
			Add-PnPFile -Path $File.FullName -Folder $SpoLibraryPath 
			$succeed=$True
			Write-Host "File: $($File) has been uploaded!"
			WriteLog "SUCCEED. $($File) ==> $($SpoLibraryPath)"
		}
		Catch {
			Write-Host -f Red "FALIED. " $_.Exception.Message
			WriteLog "FALIED. $($_.Exception.Message)"
			$loopTime++
			Start-Sleep -Seconds 60
		}
	}
	
	IF ($succeed){
		$tmpRow = GenerateRow -rowNo $rowNumber -fileName $File.Name -spoPath $SpoLibraryPath -status "SUCCEED"		
	}Else{
		$tmpRow = GenerateRow -rowNo $rowNumber -fileName $File.Name -spoPath $SpoLibraryPath -status "FAILED"
		$EmailPriority=2
	}
	
	$rowContents = $rowContents + $tmpRow
}

Disconnect-PnPOnline

$CurrentDate = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
$htmlBody ="Hi All,
			<br/>
			This is the reports:
			<br/>
			<ul> 
				<li>Job on Server: 			$env:ComputerName.$env:USERDNSDOMAIN</li>
				<li>Runing at: 				$CurrentDate</li>
				<li>Local Sharing Folder: 	$LocalSourceFolder</li>
				<li>SPO Library Folder: 	$SiteUrl</li>				
				<li> Details
					<table width=""100%;"" CELLSPACING=0 CELLPADDING=5 style=""border-collapse: collapse;"">
						$rowContents
					</table>
				</li>
			</ul>
			
			<br/>
			Thanks,
			<br/>
			Tech Department."	
#write-host "$htmlBody"
$CurrentDate =(Get-Date).toString("yyyy/MM/dd")
EmailNotification -Subject "Email Title $($CurrentDate)"  -Body $htmlBody -Priority $EmailPriority

Write-Host "################################################################################" 
WriteLog "################################################################################" 
#PowerShell.exe -ExecutionPolicy Bypass -File "UploadFileToSPO.ps1"

