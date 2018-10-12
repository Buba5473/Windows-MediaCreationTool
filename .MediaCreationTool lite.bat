<# :: Ninja edits = https://pastebin.com/bBw0Avc4                             Gist mirror = https://git.io/MediaCreationTool.bat
@echo off &title MediaCreationTool.bat by AveYo v2018.10.12
:: Universal MediaCreationTool wrapper for all "RedStone" Windows 10 MCT versions: 1607, 1703, 1709, 1803 and 1809
:: Using as source nothing but microsoft-hosted original files for the current and past Windows 10 MCT releases
:: Ingenious full support for business editions (Enterprise / VL) selecting language, x86, x64 or AIO inside MCT GUI
:: Changelog:
:: - native xml patching so no editions spam: just combined client and combined business (individual business in 1607, 1703)
:: - patching all eula links to use http as MCT can fail at downloading - specially under naked Windows 7 host / outdated TLS
:: - generating products.xml entries for business editions in 1607 and 1703 that never had them included so far (optional)
:: - 50KB increase in script size is well worth above feature imho but you can skip it by copy/pasting until the NOTICE marker
:: - reinstated 1809 [RS5] with native xml patching of products.xml for MCT; fixed exit/b on the same line with condition
:: - added data loss warning for RS5

:: Comment to not unhide combined business editions in products.xml that include them: 1709, 1803, 1809
set "UNHIDE_BUSINESS=yes"

:: Comment to not create individual business editions in products.xml that never included them: 1607, 1703
set "CREATE_BUSINESS=yes"

:: Add / remove launch parameters below if needed - it is preset for least amount of issues when doing upgrades
set "OPTIONS=/Telemetry Disable /DynamicUpdate Disable /MigrateDrivers all /ResizeRecoveryPartition disable /ShowOOBE none"

:: Uncomment to show live mct console log for debugging
rem set "OPTIONS=%OPTIONS% /Console"

:: Uncomment to bypass gui dialog choice and hardcode the target version: 1=1607, 2=1703, 3=1709, 4=1803, 5=1809
rem set/a MCT_VERSION=5

:: Available MCT versions
set versions= 1 8 0 9  [ R S 5 ], 1 8 0 3  [ R S 4 ], 1 7 0 9  [ R S 3 ], 1 7 0 3  [ R S 2 ], 1 6 0 7  [ R S 1 ]

:: Show gui dialog 1:title 2:choices 3:output_variable
if not defined MCT_VERSION call :choice "Choose MCT Windows 10 Version:" "%versions%" MCT_VERSION
if not defined MCT_VERSION echo No MCT_VERSION selected, exiting.. & timeout /t 5 & exit/b
goto version-RS%MCT_VERSION%

:version-RS5
set "V=1809"
set "D=20181002"
set "CAB=" &rem "http://download.microsoft.com/download/6/F/B/6FB97F08-E010-48A4-A9DC-18FCA920CEB4/products_20180924.cab"
set "XML=https://download.microsoft.com/download/8/D/F/8DF0EA49-0A7B-4F4D-A6DE-4DF7FA00FB7B/products.xml" &set "CAT=1.3"
set "MCT=http://software-download.microsoft.com/download/pr/MediaCreationTool1809.exe"
goto process

:version-RS4
set "V=1803"
set "D=20180705"
set "CAB=http://download.microsoft.com/download/5/C/B/5CB83D2A-2D7E-4129-9AFE-353F8459AA8B/products_20180705.cab"
set "MCT=http://software-download.microsoft.com/download/pr/MediaCreationTool1803.exe"
goto process

:version-RS3
set "V=1709"
set "D=20180105"
set "CAB=http://download.microsoft.com/download/3/2/3/323D0F94-95D2-47DE-BB83-1D4AC3331190/products_20180105.cab"
set "MCT=http://download.microsoft.com/download/A/B/E/ABEE70FE-7DE8-472A-8893-5F69947DE0B1/MediaCreationTool.exe"
goto process

:version-RS2
set "V=1703"
set "D=20170317"
set "CAB=http://download.microsoft.com/download/9/5/4/954415FD-D9D7-4E1F-8161-41B3A4E03D5E/products_20170317.cab"
set "MCT=http://download.microsoft.com/download/1/C/4/1C41BC6B-F8AB-403B-B04E-C96ED6047488/MediaCreationTool.exe"
:: 1703 MCT is also bugged so use 1607 instead
set "MCT=http://download.microsoft.com/download/C/F/9/CF9862F9-3D22-4811-99E7-68CE3327DAE6/MediaCreationTool.exe"
goto process

:version-RS1
set "V=1607"
set "D=20170116"
set "CAB=http://wscont.apps.microsoft.com/winstore/OSUpgradeNotification/MediaCreationTool/prod/Products_20170116.cab"
set "MCT=http://download.microsoft.com/download/C/F/9/CF9862F9-3D22-4811-99E7-68CE3327DAE6/MediaCreationTool.exe"
goto process

:process
echo.
echo  Selected MediaCreationTool.exe for Windows 10 Version %V% - %D%
echo.
echo  "Windows 10" default MCT choice is usually combined consumer: Pro + Edu + Home
echo  "Windows 10 Enterprise"  is usually combined business: Pro VL +  Edu VL +  Ent
echo   RS1 and RS2 for business only come as individual idx: Pro VL or Edu VL or Ent
echo.


set "w1= WARNING! RS5 bug still present. Just to be safe and prevent data-loss"
set "w2= move all personal files: Documents, Pictures, Videos, Downloads, etc."
set "w3= from inside your profile folder  %USERPROFILE%"
set "w4= to other partition or folder in  %SYSTEMDRIVE%"
set "WARN=@('%w1%','%w2%','%w3%','%w4%') | foreach{ write-host $_.PadRight(79,[char]160)"
if %V% EQU 1809 (
 set "OPTIONS=%OPTIONS:Telemetry Disable=Telemetry Enable%"
 powershell -noprofile -c "%WARN% -ForegroundColor Yellow -BackgroundColor DarkMagenta }"
 echo.
 timeout /t 3 >nul
)


echo  Info: MCT depends on BITS service! If any issues, run script as Admin..
bitsadmin.exe /reset /allusers >nul 2>nul
net stop bits /y 2>nul
net start bits /y 2>nul
:: cleanup - can include temporary files too but not recommended as you can't resume via C:\$Windows.~WS\Sources\setuphost
pushd "%~dp0"
del /f /q products.* 2>nul &rem rd /s/q C:\$Windows.~WS 2>nul & rd /s/q C:\$WINDOWS.~BT 2>nul
:: download MCT
set "DOWNLOAD=(new-object System.Net.WebClient).DownloadFile"
if not exist MediaCreationTool%V%.exe powershell -noprofile -c "%DOWNLOAD%('%MCT%','MediaCreationTool%V%.exe');"
if not exist MediaCreationTool%V%.exe color 0e & echo Warning! missing MediaCreationTool%V%.exe
:: download and expand CAB
if defined CAB if not exist products_%D%.cab powershell -noprofile -c "%DOWNLOAD%('%CAB%','products_%D%.cab');"
if defined CAB if not exist products_%D%.cab color 0e & echo Warning! cannot download products_%D%.cab & set "CAB="
if defined CAB if exist products_%D%.cab expand.exe -R products_%D%.cab -F:* . >nul 2>nul
:: download fallback XML
if defined XML if not exist products_%D%.xml powershell -noprofile -c "%DOWNLOAD%('%XML%','products_%D%.xml');"
if defined XML if not exist products_%D%.xml color 0e & echo Warning! cannot download products_%D%.xml & set "XML="
if defined XML if not exist products.xml copy /y products_%D%.xml products.xml >nul 2>nul
:: got products.xml?
if not exist products.xml color 0c & echo Error! products_%D%.cab or products_%D%.xml are not available atm & pause & exit /b
:: patch fallback XML for MCT
if not defined CAT set "CAT=1.3"
set "p1=[xml]$r=New-Object System.Xml.XmlDocument; $d=$r.CreateXmlDeclaration('1.0','UTF-8',$null); $null=$r.AppendChild($d);"
set "p2=$tmp=$r; foreach($n in @('MCT','Catalogs','Catalog')){ $e=$r.CreateElement($n); $null=$tmp.AppendChild($e); $tmp=$e; };"
set "p3=$h=$r.SelectNodes('/MCT/Catalogs/Catalog')[0];$h.SetAttribute('version','%CAT%'); [xml]$p=Get-Content './products.xml';"
set "p4=$null=$h.AppendChild($r.ImportNode($p.PublishedMedia,$true)); $r.Save('./products.xml')"
if defined XML powershell -noprofile -c "%p1% %p2% %p3% %p4%"
:: patch XML url for EULAs as older MCT has issues downloading them specially under naked Windows 7 host (likely TLS issue)
set "EULA_FIX=http://download.microsoft.com/download/C/0/3/C036B882-9F99-4BC9-A4B5-69370C4E17E9"
set "p5=foreach ($e in $p.MCT.Catalogs.Catalog.PublishedMedia.EULAS.EULA){$e.URL='%EULA_FIX%/EULA'+($e.URL -split '/EULA')[1]}"
powershell -noprofile -c "[xml]$p = Get-Content './products.xml'; %p5%; $p.Save('./products.xml')"
:: patch XML to unhide combined business editions in products.xml that include them: 1709, 1803, 1809
set "p6=foreach ($e in $p.MCT.Catalogs.Catalog.PublishedMedia.Files.File){ if ($e.Edition -eq 'Enterprise'){"
set "p7= $e.IsRetailOnly = 'False'; $e.Edition_Loc = 'Windows 10 ' + $e.Edition } }"
if "%UNHIDE_BUSINESS%"=="yes" powershell -noprofile -c "[xml]$p=Get-Content './products.xml';%p6%%p7%;$p.Save('./products.xml')"
:: patch XML to create individual business editions in products.xml that never included them: 1607, 1703
call :create_business >nul 2>nul
:: repack XML into CAB
makecab products.xml products.cab >nul
:: finally launch MCT with local configuration and optional launch parameters
start "" MediaCreationTool%V%.exe /Selfhost %OPTIONS%
exit/b

:choice 1=title 2=choices 3=output_variable [button number]       GUI buttons dialog snippet by AveYo released under MIT License
setlocal & set "ps_Choice=$title='%~1'; $choices='%~2,Cancel'.split(','); $n=$choices.length; $global:c=''; $i=1; "
set "s1=[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms');$f=New-Object System.Windows.Forms.Form"
set "s2=;$f.Text=$title; $f.BackColor=0xff180052; $f.Forecolor='Snow'; $f.StartPosition=4; $f.AutoSize=1; $f.FormBorderStyle=3;"
set "s3=foreach($l in $choices){ $b=New-Object System.Windows.Forms.Button; $b.Text=$l; $b.Name=$n-$i; $b.cursor='Hand';"
set "s4= $b.Location='8,'+(32*$i);$b.Margin='8,4,8,4';$b.MinimumSize='320,20';$b.add_Click({$global:c=$this.Name;$f.Close()});"
set "s5= $f.Controls.Add($b); $i++ }; $f.AcceptButton=$f.Controls[0]; $f.CancelButton=$f.Controls[-1]; $f.MaximizeBox=0; "
set "s6=$f.Add_Shown({$f.Activate()}); $null=$f.ShowDialog(); if($global:c -ne 0){write-host $global:c}"
for /l %%i in (1,1,6) do call set "ps_Choice=%%ps_Choice%%%%s%%i:"=\"%%"
endlocal & for /f "tokens=* delims=" %%s in ('powershell -noprofile -c "%ps_Choice%"') do set "%~3=%%s"
exit/b

::==============================================================================================================================
:NOTICE: IF INTERESTED IN BUSINESS EDITIONS FOR 1607 AND 1703 TOO, GET THE FULL SCRIPT FROM THE LINKS AT THE TOP
::==============================================================================================================================
