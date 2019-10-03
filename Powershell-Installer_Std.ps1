#Set Execution Policy for the script
Set-ExecutionPolicy Bypass -Scope Process -Force

#Variable Declaration
$User = $env:UserName
$ComputerName = $env:COMPUTERNAME
$OriginalRunTime = Get-Date
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$UserAsAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$PowerShellAsAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
$NetAdapters = Get-NetAdapter | Select -ExpandProperty Name

#SOFTWARE VARIABLE INSTALL LOCATION
$VC = "\\vc-manchester\InstallSet\2.Client\CabiBond Setup.msi"
$proaudit = "\\sqlserver\Proacc\CCH Proaudit V 4.4 full install\CCH_Audit_Automation_4-4_CCH_V7.exe"
$SAPA = "\\appserver\Sage\updates\18.01.00.94\SageAPA2018Update1\SageAPA\setup.exe"
$DAPA = "\\digita\Digita\Accounts Production Advanced\Nodeins\MSI\Installer.msi"
$VS2010x64 = "\\digita\Digita\Accounts Production Advanced\Nodeins\Updates\VS2010_x86\vc_red.msi"
$DDMS = "\\digita\Digita\Accounts Production Advanced\Nodeins\Document Management\DMS.msi"
$DAP = "\\digita\Digita\Accounts Production\Nodeins\setup.exe"
$DCT = "\\digita\Digita\Corporation Tax\Nodeins\setup.exe"
$DPT = "\\digita\Digita\Personal Tax\Nodeins\setup.exe"
$DCS = "\\digita\Digita\Company Secretarial\Nodeins\setup.exe"
$DPM = "\\digita\Digita\Practice Management\Nodeins\setup.exe"
$Star = "\\star\Star PDM - New\Disk1\setup.exe"

#CHECKING IF POWERSHALL HAS ADMIN ESCALATION
if($PowerShellAsAdmin -eq $false)

    {
        Write-Warning “The script is not currently being run as Admin, Please re-run this script as an Administrator!”
        break
    }

foreach($adapter in $NetAdapters)
	{
            Disable-NetAdapterBinding –InterfaceAlias $adapter –ComponentID ms_tcpip6
    }

#BASE_CONFIG
Enable-WindowsOptionalFeature -Online -FeatureName 'NetFx3' -NoRestart
Get-AppxPackage -AllUsers | Remove-AppxPackage
Get-AppxPackage -Allusers Microsoft.WindowsStore | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
Get-AppxPackage -Allusers *calculator* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
Get-AppxPackage -Allusers *paint* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
Get-AppxPackage -Allusers *photos* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
Enable-WindowsOptionalFeature -Online -FeatureName 'NetFx3' -NoRestart
msiexec.exe /i $VC /quiet /norestart /qn

#SOFTWARE_INSTALLS
#CCH
#PROAUDIT
start-process $proaudit
Start-Sleep -s 2
$proauditproc = (Get-Process CCH_Audit_Automation_4-4_CCH_V7).Id
Wait-Process $proauditproc
Copy-Item -Path "\\sqlserver\Proacc\Proacc\ProauditV3\licence.ini" -Destination "C:\proacc\proauditv3\" -Force

#SAGE
#SAPA
start-process $SAPA
Start-Sleep -s 2
$SAPAPROC = (Get-Process setup).Id
Wait-Process $SAPAPROC

#DIGITA
#DPM
Start-Process $DPM
Start-Sleep -s 2
$DPMPROC = (Get-Process setup).Id
Wait-Process $DPMPROC
#DCS
Start-Process $DCS
Start-Sleep -s 2
$DCSPROC = (Get-Process setup).Id
Wait-Process $DCSPROC
#DAPA
msiexec.exe /i $VS2010x64 /quiet /norestart /qn
msiexec.exe /i $DDMS /quiet /norestart /qn
msiexec.exe /i $DAPA ACCEPT=YES /qr+ ADDLOCAL=Platform,AmyuniPDFPrinter,DigitaIntegration SQLSERVERDATABASE="AccountsProduction" SQLSERVERADDRESS="DIGITA" RUNDBUPGRADE="0"
Start-Sleep -s 2
$DAPAPROC = $null
$DAPAPROC = (Get-Process msiexec).Id
Wait-Process $DAPAPROC -Timeout 120
#DAP
Start-Process $DAP
Start-Sleep -s 2
$DAPPROC = (Get-Process setup).Id
Wait-Process $DAPPROC
#DCT
Start-Process $DCT
Start-Sleep -s 2
$DCTPROC = (Get-Process setup).Id
Wait-Process $DCTPROC
#DPT
Start-Process $DPT
Start-Sleep -s 2
$DPTPROC = (Get-Process setup).Id
Wait-Process $DPTPROC

#STARAMERICAS
#STAR
Start-Process $Star
Start-Sleep -s 2
$StarProc = (Get-Process setup).Id
Wait-Process $StarProc
Copy-Item -Path "\\star\Star PDM - New\Disk1\StarPDM.exe.config" -Destination "C:\Program Files (x86)\Star Americas\StarPDM\" -Force

#MICROSOFT
#OFFICE365
cd "$env:USERPROFILE\Desktop\odt"
$365 = .\setup.exe /configure .\Configuration_x86.xml
Start-Process $365
Start-Sleep -s 2
$365Proc = (Get-Process setup).Id
Wait-Process $365Proc

#CLEANUP_VARIABLES
$proauditproc = $null
$SAPAPROC = $null
$DPMPROC = $null
$DCSPROC = $null
$DAPAPROC = $null
$DAPPROC = $null
$DCTPROC = $null
$DPTPROC = $null