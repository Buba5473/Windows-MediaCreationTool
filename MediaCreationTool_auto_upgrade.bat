@echo off &title MediaCreationTool.bat by AveYo v2019.05.22  ||  pastebin.com/bBw0Avc4  or  git.io/MediaCreationTool.bat
:: Universal MediaCreationTool wrapper for all "RedStone" Windows 10 MCT versions: 1607, 1703, 1709, 1803 and 1809
:: Using as source nothing but microsoft-hosted original files for the current and past Windows 10 MCT releases
:: Ingenious full support for business editions (Enterprise / VL) selecting language, x86, x64 or AIO inside MCT GUI
:: Changelog:
:: - native xml patching so no editions spam: just combined client and combined business (individual business in 1607, 1703)
:: - patching all eula links to use http as MCT can fail at downloading - specially under naked Windows 7 host / outdated TLS
:: - generating products.xml entries for business editions in 1607 and 1703 that never had them included so far (optional)
:: - 50KB increase in script size is well worth above feature imho but you can skip it by copy/pasting until the NOTICE marker
:: - reinstated 1809 [RS5] with native xml patching of products.xml for MCT; added data loss warning for RS5
:: - RS5 is officially back! And a greatly improved choices dialog - feel free to use the small snippet in your own scripts
:: - added Auto Upgrade launch options preset with support for a setupcomplete.cmd in the current folder
:: - 1903 [19H1] release

:: Comment to not unhide combined business editions in products.xml that include them: 1709, 1803, 1809
set "UNHIDE_BUSINESS=yes"

:: Comment to not create individual business editions in products.xml that never included them: 1607, 1703
set "CREATE_BUSINESS=yes"

:: Add / remove launch parameters below if needed - it is preset for least amount of issues when doing upgrades
set OPTIONS=/Telemetry Disable /DynamicUpdate Disable /MigrateDrivers all /ResizeRecoveryPartition disable /ShowOOBE none

:: Uncomment to force a specific Edition, Architecture and Language - if enabled, all 3 must be used
rem set OPTIONS=%OPTIONS% /MediaEdition Enterprise /MediaArch x64 /MediaLangCode en-us

:: Uncomment to force Auto Upgrade - no user intervention needed
set OPTIONS=%OPTIONS% /Eula Accept /MigChoice Upgrade /Auto Upgrade

:: Uncomment to show live mct console log for debugging
rem set "OPTIONS=%OPTIONS% /Console /DiagnosticPrompt enable /NoReboot"

:: Uncomment to bypass gui dialog choice and hardcode the target version: 1=1607, 2=1703, 3=1709, 4=1803, 5=1809
set/a MCT_VERSION=6

:: Available MCT versions
set versions=  1607 [RS1], 1703 [RS2], 1709 [RS3], 1803 [RS4], 1809 [RS5], 1903 [19H1]

:: Show dialog w buttons: 1=outvar 2="choices" 3=selected [optional] 4="caption" 5=textsize 6=backcolor 7=textcolor 8=minsize
if not defined MCT_VERSION call :choices MCT_VERSION "%versions%" 6 "Choose MCT Windows 10 Version:" 15 0xff180052 Snow 400
if not defined MCT_VERSION echo No MCT_VERSION selected, exiting.. & timeout /t 5 & exit/b
goto version-RS%MCT_VERSION%

:version-RS6
set "V=1903"
set "D=20190502"
set "CAB=https://download.microsoft.com/download/5/8/4/584230EE-70C4-46D6-B992-FDAE62820615/products_20190502.cab"
set "MCT=https://software-download.microsoft.com/download/pr/MediaCreationTool1903.exe"
goto process

:version-RS5
set "V=1809"
set "D=20181105"
set "CAB=http://download.microsoft.com/download/B/6/E/B6E8893F-ECE0-42E5-A9ED-69A13DD0BA95/products_20181105.cab"
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
echo  If any issues, run script as Admin / check BITS service!
echo  Please wait while preparing products_%D%.cab and MediaCreationTool%V%.exe ...
echo.
bitsadmin.exe /reset /allusers >nul 2>nul
net stop bits /y 2>nul
net start bits /y 2>nul

::if %V% EQU 1809 set "OPTIONS=%OPTIONS:Telemetry Disable=Telemetry Enable%" &rem Just in case MS screwed up again..

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
if /i "%OPTIONS:/MigChoice Upgrade=%"=="%OPTIONS%" start "" MediaCreationTool%V%.exe /Selfhost %OPTIONS% & exit/b
:: if Upgrade selected, wait for MCT to finish then run setupprep with parameteres directly to overcome MCT limitations
set OPTIONS=/Selfhost %OPTIONS% /PostOOBE "%~dp0setupcomplete.cmd" & if not exist setupcomplete.cmd cd.>setupcomplete.cmd
set "p1=MediaCreationTool%V%.exe /Selfhost %OPTIONS% /Action CreateUpgradeMedia /NoFinalize"
set "p2=(if not exist C:\ESD\Windows\sources\setupprep.exe exit)"
set "p3=echo start \"setup\" \"%%~dp0sources\setupprep.exe\" %OPTIONS% > C:\ESD\Windows\auto.bat"
set "p4=start \"setup\" /min cmd.exe /c C:\ESD\Windows\auto.bat"
powershell -c "Start-Process cmd.exe -ArgumentList '/c %p1% & %p2% & %p3% & %p4%' -WindowStyle Hidden"
exit/b

:choices dialog w buttons: 1=outvar 2="choices" 3=selected [optional] 4="caption" 5=textsize 6=backcolor 7=textcolor 8=minsize
set "snippet=iex(([io.file]::ReadAllText('%~f0')-split':PS_CHOICE\:.*')[1]); Choices %*"
(for /f "usebackq" %%s in (`powershell -noprofile -c "%snippet:"='%"`) do set "%~1=%%s") &exit/b :PS_CHOICE:
function Choices($outputvar,$choices,$sel=1,$caption='Choose',[byte]$sz=12,$bc='MidnightBlue',$fc='Snow',[string]$min='400') {
 [void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); $f=New-Object System.Windows.Forms.Form;
 $bt=@(); $i=1; $global:rez=''; $ch=($choices+',Cancel').split(','); $ch | foreach { $b=New-Object System.Windows.Forms.Button;
 $b.Name=$i; $b.Text=$_; $b.Font='Tahoma,'+$sz; $b.Margin='0,0,9,9'; $b.Location='9,'+($sz*3*$i-$sz); $b.MinimumSize=$min+',18';
 $b.AutoSize=1; $b.cursor='Hand'; $b.add_Click({$global:rez=$this.Name;$f.Close()}); $f.Controls.Add($b); $bt+=$b; $i++ }
 $f.Text=$caption; $f.BackColor=$bc; $f.ForeColor=$fc; $f.StartPosition=4; $f.AutoSize=1; $f.AutoSizeMode=0; $f.MaximizeBox=0;
 $f.AcceptButton=$bt[$sel-1]; $f.CancelButton=$bt[-1]; $f.Add_Shown({$f.Activate();$bt[$sel-1].focus()}); $null=$f.ShowDialog();
 if($global:rez -ne $ch.length){ return $global:rez }else{ return $null } }  :PS_CHOICE:
:: Let's Make Console Scripts Friendlier Initiative by AveYo - MIT License -     call :choices rez "one, 2 two, three" 3 'Usage'

::==============================================================================================================================
:NOTICE: IF INTERESTED IN BUSINESS EDITIONS FOR 1607 AND 1703 TOO, GET THE FULL SCRIPT FROM THE LINKS AT THE TOP
::==============================================================================================================================
