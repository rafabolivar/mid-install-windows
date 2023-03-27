# MID Server and Instance values

$MID_NAME = "midrafahome"
$MID_USERNAME= "miduser"
$MID_PASSWORD = 'Txexperts$23'
$INSTANCE_URL = 'https://rafautahdemo.service-now.com'
$SA_NAME = "miduser"
$SA_PASSWORD = 'Txexperts$23'
$ENC_SA_PWD = ConvertTo-SecureString $SA_PASSWORD -AsPlainText -Force
$INSTALL_LOCATION = "C:\midserver"

mkdir C:\Users\Administrator\Documents\midserver
mkdir $INSTALL_LOCATION

# User Rights Script Download
$scripturl = "https://raw.githubusercontent.com/blakedrumm/SCOM-Scripts-and-SQL/master/Powershell/General%20Functions/Set-UserRights.ps1"
$scriptdest = "C:\Users\Administrator\Documents\midserver\Set-UserRights.ps1"
Invoke-WebRequest -Uri $scripturl -OutFile $scriptdest

# MID Server Download URL
$url = "https://install.service-now.com/glide/distribution/builds/package/app-signed/mid-windows-installer/2023/01/18/mid-windows-installer.utah-12-21-2022__patch0-01-18-2023_01-18-2023_1907.windows.x86-64.msi"
$dest = "C:\Users\Administrator\Documents\midserver\midserver.msi"
Invoke-WebRequest -Uri $url -OutFile $dest

# Create Local Mid User

New-LocalUser $SA_NAME -Password $ENC_SA_PWD -FullName "Mid User" -Description "MID Server User account"
C:\Users\Administrator\Documents\midserver\Set-UserRights.ps1 -AddRight -Username $SA_NAME -UserRight SeServiceLogonRight

$msiexecCMD = "msiexec /i `"" + $dest + "`" ";
$msiexecCMD += "INSTALL_LOCATION=`"" + $INSTALL_LOCATION + "`" ";
$msiexecCMD += "INSTANCE_URL=`"" + $INSTANCE_URL + "`" ";
$msiexecCMD += "MID_USERNAME=`"" + $MID_USERNAME + "`" ";
$msiexecCMD += "MID_PASSWORD=`"" + $MID_PASSWORD + "`" ";
$msiexecCMD += "MID_NAME=`"" + $MID_NAME + "`" ";
$msiexecCMD += "SERVICE_ACCOUNT_NAME=`"" + $SA_NAME + "`" ";
$msiexecCMD += "SERVICE_ACCOUNT_PASSWORD=`"" + $SA_PASSWORD + "`" ";

$msiexecCMD += "AUTH_TYPE=`"BASIC_AUTH`" ";

$msiexecCMD += "SERVICE_NAME=`"snc_mid_" + $MID_NAME + "`" ";
$msiexecCMD += "SERVICE_DISPLAY_NAME=`"ServiceNow MID Server_" + $MID_NAME + "`" ";

$msiexecCMD += "START_MID=`"1`" ";

$msiexecCMD += "/qn ";

cmd.exe /c $msiexecCMD;

# Validating MID Server

$mid_auth = "$MID_USERNAME" + ":" + "$MID_PASSWORD";
$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($mid_auth))
$basicAuthValue = "Basic $encodedCreds"

 $headers = @{
	'Accept' = 'application/json'
	'Content-Type' = 'application/json'
	'Authorization' = $basicAuthValue
}

Invoke-WebRequest -Uri $INSTANCE_URL/api/snc/midvalidate/$MID_NAME -Method POST -Headers $headers

