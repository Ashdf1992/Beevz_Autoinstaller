#Set Execution Policy for the script
Set-ExecutionPolicy Bypass -Scope Process -Force
$ADModuleManagementDIR = "C:\Windows\Microsoft.NET\assembly\GAC_64\Microsoft.ActiveDirectory.Management\"
$ADModuleDIR = "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\ActiveDirectory"
if((Test-Path $ADModuleDIR) -eq 0)
    {
        if((Test-Path $ADModuleManagementDIR) -eq 0)
        {
            Copy-Item -Path "D:\PSInstaller\Modules\ActiveDirectory" -Destination "C:\Windows\System32\WindowsPowerShell\v1.0\Modules" -Force -Recurse
            Copy-Item -Path "D:\PSInstaller\Modules\Microsoft.ActiveDirectory.Management" -Destination "C:\Windows\Microsoft.NET\assembly\GAC_64" -Force -Recurse
            New-PSDrive -Name AD -PSProvider ActiveDirectory -Root "DC=ad,DC=beeverstruthers,DC=co,DC=uk" -Server dc1.ad.beeverstruthers.co.uk:389 -Credential "AD\"
            Set-location AD
            Import-Module -Name ActiveDirectory
        }
        else
        {
            New-PSDrive -Name AD -PSProvider ActiveDirectory -Root "DC=ad,DC=beeverstruthers,DC=co,DC=uk" -Server dc1.ad.beeverstruthers.co.uk:389 -Credential "AD\"
            Set-location AD
            Import-Module -Name ActiveDirectory
        }

    }
else
    {
        if((Test-Path $ADModuleManagementDIR) -eq 0)
        {
            Copy-Item -Path "D:\PSInstaller\Modules\Microsoft.ActiveDirectory.Management" -Destination "C:\Windows\Microsoft.NET\assembly\GAC_64" -Force -Recurse
            New-PSDrive -Name AD -PSProvider ActiveDirectory -Root "DC=ad,DC=beeverstruthers,DC=co,DC=uk" -Server dc1.ad.beeverstruthers.co.uk:389 -Credential "AD\"
            Set-location AD
            Import-Module -Name ActiveDirectory
        }
        else
        {
            New-PSDrive -Name AD -PSProvider ActiveDirectory -Root "DC=ad,DC=beeverstruthers,DC=co,DC=uk" -Server dc1.ad.beeverstruthers.co.uk:389 -Credential "AD\"
            Set-location AD
            Import-Module -Name ActiveDirectory
        }
    }



##Variable Declaration
$User = $env:UserName
$ComputerName = $env:COMPUTERNAME
$OriginalRunTime = Get-Date
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$UserAsAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$recently = [DateTime]::Today.AddDays(-30)
$LastDeviceAddedAD = Get-ADComputer -Filter 'WhenCreated -ge $recently' -Properties whenCreated | Select -ExpandProperty Name -Last 1
$NameOfDevice = Read-Host "The last computer added to AD was" $LastDeviceAddedAD "`n`nPlease Enter the name for this device"
$PowerShellAsAdmin = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
$NetAdapters = Get-NetAdapter | Select -ExpandProperty Name

#Software Variable Installer Location#
#
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
#
#Software Variable Installer Location#

#Check Powershell is being run as admin
if($PowerShellAsAdmin -eq $false)

    {
        Write-Warning “The script is not currently being run as Admin, Please re-run this script as an Administrator!”
        break
    }


function Show-Menu
    {
    	param ([string]$Title = 'Installer Menu')
    	cls
    	Write-Host "================ $Title ================"
    	Write-Host " "
    	Write-Host " "
    	Write-Host "1: Press '1' for the base install configuration (this should be used on all new installs)."
    	Write-Host "2: Press '2' for Audit Applications"
    	Write-Host "3: Press '3' for Tax Applications."
        Write-Host "4: Press '4' for Domain Join."
        Write-Host "5: Press '5' for Software Install Menu."
    	Write-Host "Q: Press 'Q' to quit."
    	Write-Host " "
    	Write-Host " "
    
    }

do
    {
    
    	Show-Menu
    	$input = Read-Host "Please make a selection"
    	switch ($input)
    	{
    		'1' {
    				cls
    				'You chose option #1'
                    # DISM to enable features legacy feature but will leave here as reference
    				#DISM /Online /Enable-Feature /FeatureName:NetFx3 /All
    				# This below command will disable Internet Explorer. To be used when we get rid of star. 
                    #Disable-WindowsOptionalFeature -FeatureName Internet-Explorer-Optional-amd64 –Online -NoRestart
    				foreach($adapter in $NetAdapters)
                    {
                        Disable-NetAdapterBinding –InterfaceAlias $adapter –ComponentID ms_tcpip6
                    }
                    Enable-WindowsOptionalFeature -Online -FeatureName 'NetFx3' -NoRestart
    				Get-AppxPackage -AllUsers | Remove-AppxPackage
    				Get-AppxPackage -Allusers Microsoft.WindowsStore | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
    				Get-AppxPackage -Allusers *calculator* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
                    Get-AppxPackage -Allusers *paint* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
                    Get-AppxPackage -Allusers *photos* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
    				Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
                    Install-Module PSWindowsUpdate -force
                    Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d -Confirm:$false
                    Get-WUInstall –MicrosoftUpdate –AcceptAll –AutoReboot
                    
    			} 
    		'2' {
    				cls
    				'You chose option #2'
                    
                    #Lindenhouse Software
                    #Virtual Cabinet
                    #####.net Core 2 should not be required but if it is just uncomment $dotnetcore2 = \\vc-manchester\InstallSet\2.Client\dotnet-hosting-2.2.6-win.exe /install /passive /norestart
                    #####check Net Framework 2-4 is installed (installed in Step 1)
                    Enable-WindowsOptionalFeature -Online -FeatureName 'NetFx3' -NoRestart
                    msiexec.exe /i $VC /quiet /norestart /qn

                    

                    #CCH
                    #Proaudit
                    start-process $proaudit
                    Start-Sleep -s 2
                    $proauditproc = (Get-Process CCH_Audit_Automation_4-4_CCH_V7).Id
                    Wait-Process $proauditproc
                    Copy-Item -Path "\\sqlserver\Proacc\Proacc\ProauditV3\licence.ini" -Destination "C:\proacc\proauditv3\" -Force



                    #Sage
                    #SAPA
                    start-process $SAPA
                    Start-Sleep -s 2
                    $SAPAPROC = (Get-Process setup).Id
                    Wait-Process $SAPAPROC


                    
                    #Digita
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


                    #StarAmericas
                    #Star
                    Start-Process $Star
                    Start-Sleep -s 2
                    $StarProc = (Get-Process setup).Id
                    Wait-Process $StarProc
                    Copy-Item -Path "\\star\Star PDM - New\Disk1\StarPDM.exe.config" -Destination "C:\Program Files (x86)\Star Americas\StarPDM\" -Force



                    #Microsoft
                    #Office365
                    cd "\\ad.beeverstruthers.co.uk\shared\Software\odt\"
                    $365 = .\setup.exe /configure .\Configuration_x86.xml
                    Start-Process $365
                    Start-Sleep -s 2
                    $365Proc = (Get-Process setup).Id
                    Wait-Process $365Proc


                    #Cleanup Process Variables.
                    $proauditproc = $null
                    $SAPAPROC = $null
                    $DPMPROC = $null
                    $DCSPROC = $null
                    $DAPAPROC = $null
                    $DAPPROC = $null
                    $DCTPROC = $null
                    $DPTPROC = $null

    			} 
    		'3' {
    				cls
    				'You chose option #3'
                    Write-Host "$PSScriptRoot"
    			} 	
    		'4' {
    				cls
    				'You chose option #4'
                    $domain = "AD"
                    $doa = Read-Host "Enter your domain admin username"
                    Add-computer –domainname ad.beeverstruthers.co.uk -Credential $domain\$doa –force
    			}

            '5' {
                    function Show-Menu2
                    {
                         param (
                               [string]$Title2 = 'My Menu'
                         )
                         cls
                         Write-Host "================ $Title ================"
    
                         Write-Host "1: Press '1' for this option."
                         Write-Host "2: Press '2' for this option."
                         Write-Host "3: Press '3' for this option."
                         Write-Host "Q: Press 'Q' to quit."
                    }

                    do
                    {
                         Show-Menu2
                         $input2 = Read-Host "Please make a selection"
                         switch ($input2)
                         {
                               '1' {
                                    cls
                                    'You chose option #1'
                               } '2' {
                                    cls
                                    'You chose option #2'
                               } '3' {
                                    cls
                                    'You chose option #3'
                               } 'q' {
                                    Show-Menu
                               }
                         }
                         pause
                    }
                    until ($input2 -eq 'q')
                }
    		'q' 
    		{
    			return
    		}
    	}
        pause
    }
until ($input -eq 'q')
