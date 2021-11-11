
$LocalPathFiles="C:\temp\"
$SpoLibraryPath ="SPO Library/Childe Folerder Name"

### SMTP Parameters
$SMTPUsCredential="email address"
$SMTPPwCredential="pass word"

$emailfrom="Name <email>"
$emailto  ="Name <email>"
$port=25
$smtpserver="smtp url"

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


$rowNumber=0
$rowContents =""
#Get all SPO file
$tmpRow = GenerateRow -rowNo $rowNumber -fileName "File Name" -spoPath "SPO" -status "Status"
$rowContents = $rowContents + $tmpRow
Foreach ($File in  (dir $LocalPathFiles -File))
{
	$rowNumber++;	
	$tmpRow = GenerateRow -rowNo $rowNumber -fileName $File.FullName -spoPath $SpoLibraryPath -status "SUCCEED"
	$rowContents = $rowContents + $tmpRow	
}

$emailTitleDate =(Get-Date).toString("yyyy/MM/dd HH:mm:ss")
$htmlBody ="Hi All,
			<br/>
			This is the Reports:
			<br/>
			<ul> 
				<li>Job on Server: $env:ComputerName.$env:USERDNSDOMAIN</li>
				<li>Runing at: $emailTitleDate</li>
				<li>Local Sharing Folder: </li>
				<li>SPO Library Folder: </li>				
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
$emailTitleDate =(Get-Date).toString("yyyy/MM/dd")
EmailNotification -Subject "Email Title $($emailTitleDate)"  -Body $htmlBody -Priority 2		

#PowerShell.exe -ExecutionPolicy Bypass -File "SendEmails.ps1"
