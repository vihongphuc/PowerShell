Param (
    [string]$userLogin,
    [string]$userPassword,
	[string]$computerName,
	[string]$dacpacFile,
    [string]$connectionString,
	[string]$likedSvrName,
	[string]$likedDbName
)
Write-Host "===== DACPAC Remote Deployer ====="
Write-Host "computerName			$computerName"
Write-Host "dacpacFile				$dacpacFile"
Write-Host "connectionString		$connectionString"

$guidObject = [guid]::NewGuid()
$guid = $guidObject.Guid
$temporaryDirectory = "C:\Deployment\APP\BikeStore_DEV\" + $guid

#Create Temporary releasing folder
New-Item -ItemType directory -Path $temporaryDirectory

# 2. Copy files used for deployment (artifact from build)
$workingDirectory = $env:AGENT_RELEASEDIRECTORY
Write-Host "Copying dacpac in working directory on " $computerName "..."
$dacpac = Get-ChildItem -Path "$workingDirectory" -Filter "*.dacpac" -recurse | Select -ExpandProperty FullName 

$sourcePath = $env:AGENT_RELEASEDIRECTORY + "\*"
Copy-Item -Path $dacpac -destination "$temporaryDirectory" -Recurse

# 2bis. Copy MS tools for deployment
$sqlPackageToolPath = "C:\Deployment\SqlPackage"
Write-Host "Copying MS tools in working directory on " $computerName "..."
$sourcePath = "$sqlPackageToolPath\*"
Copy-Item -Path "$sourcePath" -destination "$temporaryDirectory" -Recurse

Try {
	#3 deployDacpac
	Write-Host "Deploying dacpac on " $computerName "..."
	
	$workingDirectory = $temporaryDirectory
	Write-Host "Searching dacpac in " $workingDirectory

	if ($dacpacFile -eq "") {
		$file = Get-ChildItem -Path "$workingDirectory" -Filter "*.dacpac" -recurse
	}
	else {
		$file = Get-ChildItem -Path "$workingDirectory" -Filter $dacpacFile -recurse
	}

	Write-Host "DACPAC File: " $file
	if ($file.Length -eq 0) {
		Write-Error "No dacpac found"
		exit
	}
	elseIf ($file.GetType().ToString() -eq "System.Object[]") {
		Write-Error "Multiple dacpac found"
		exit
	}
	$fullDacpacPath = $file.FullName

	$spExe = Get-ChildItem -Path "$workingDirectory" -Filter "sqlpackage.exe" -recurse
	$sqlPackage = $spExe.FullName

	Write-Host "===== CALLING SQLPackage ====="
	Write-Host "$sqlPackage  /Action:Publish /SourceFile:$fullDacpacPath /TargetConnectionString:$connectionString /p:BlockOnPossibleDataLoss=False /p:GenerateSmartDefaults=True /v:LinkedDBName=$likedDbName /v:LinkedServerName=$likedSvrName"
	. $sqlPackage /Action:Publish /SourceFile:$fullDacpacPath /TargetConnectionString:"$connectionString" /p:BlockOnPossibleDataLoss=False /p:GenerateSmartDefaults=True /v:LinkedDBName=$likedDbName /v:LinkedServerName=$likedSvrName
}
Catch {
	Write-Error $Error[0]
}

# 4. Clean working folder
Write-Host "Cleaning working directory on " $computerName  "..."
Get-ChildItem -Path $temporaryDirectory -Include * | remove-Item -recurse
#Get-ChildItem -Path "C:\Deployment\APP\BikeStore_DEV\" -Include * | remove-Item -recurse

