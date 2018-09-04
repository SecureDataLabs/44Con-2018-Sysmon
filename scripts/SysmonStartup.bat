@echo off
:: Author: Ryan Watson
:: Twitter: @gentlemanwatson
:: Version: 1.0
:: Credits: Credit to Syspanda.com and their Sysmon GPO article for the kick off point 
:: https://www.syspanda.com/index.php/2017/02/28/deploying-sysmon-through-gpo/

::
:: Note: It is recommended that the Sysmon binaries and the Sysmon config file
:: be placed in the sysvol folder on the Domain Controller. The goal
:: being that the computers can read from the folder, but no one except for
:: domain admins have the ability to write to the folder hosting the files. 
:: Otherwise this will be a great way for attackers to escalate privs 
:: in the domain. You have been warned. 

:: Enter the FQDN for the domain. 
:: Be EXTREMELY careful of spaces!! 
:: Example: FQDN=corp.local

SET FQDN=44conlab.net
SET VERSION=System Monitor v7.03

:: Determine architecture to set Arch Type for the SYSMON Binary

IF EXIST "C:\Program Files (x86)" (
SET BINARCH=Sysmon64.exe
SET SERVBINARCH=Sysmon64
) ELSE (
SET BINARCH=Sysmon.exe
SET SERVBINARCH=Sysmon
)

SET SYSMONDIR=C:\windows\sysmon
SET SYSMONBIN=%SYSMONDIR%\%BINARCH%
SET SYSMONCONFIG=%SYSMONDIR%\Sysmonv7Config.xml

SET GLBSYSMONBIN=\\%FQDN%\sysvol\%FQDN%\Sysmon\%BINARCH%
SET GLBSYSMONCONFIG=\\%FQDN%\sysvol\%FQDN%\Sysmon\Sysmonv7Config.xml
  
sc query "%SERVBINARCH%" | find "STATE" | find "RUNNING"
If "%ERRORLEVEL%" NEQ "0" (
goto startsysmon
) ELSE (
goto checkversion
)
  
:installsysmon
IF Not EXIST %SYSMONDIR% (
mkdir %SYSMONDIR%
)
xcopy %GLBSYSMONBIN% %SYSMONDIR% /y
xcopy %GLBSYSMONCONFIG% %SYSMONDIR% /y
chdir %SYSMONDIR%
%SYSMONBIN% -i %SYSMONCONFIG% -accepteula -h md5,sha256 -n -l
sc config %SERVBINARCH% start= auto
EXIT /B 0

:updateconfig
xcopy %GLBSYSMONCONFIG% %SYSMONCONFIG% /y
chdir %SYSMONDIR%
%SYSMONBIN% -c %SYSMONCONFIG%
EXIT /B 0

:uninstallsysmon
%SYSMONBIN% -u
goto installsysmon
  
:checkversion
%SYSMONBIN% | Find /c "%VERSION%"
If "%ERRORLEVEL%" NEQ "0" (
goto uninstallsysmon
) ELSE (
goto updateconfig
)
    
:startsysmon
sc start %SERVBINARCH%
If "%ERRORLEVEL%" EQU "1060" (
goto installsysmon
) ELSE (
goto checkversion
)