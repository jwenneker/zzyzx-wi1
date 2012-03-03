@echo off

rem RUN or STOP openCRX Server
rem ----------------------------

if ""%1"" == ""run"" goto run
if ""%1"" == ""stop"" goto stop
if ""%1"" == ""run-tomcat"" goto run-opencrx
goto end

:run
start "openCRX Server 2.9.0 (8080)" "/home/crxnsink/opencrx-2.9.0/\apache-tomee-webprofile-1.0.0\bin\opencrx.bat" run-tomcat
goto end

:run-opencrx
set JAVA_HOME=/usr/java/jdk1.6.0_29
set JAVA_HOME=%JAVA_HOME:/=\%

rem Start HSQLDB
if exist "/home/crxnsink/opencrx-2.9.0/\data\crx\startdb.bat" (
  start "HSQLDB" "/home/crxnsink/opencrx-2.9.0/\data\crx\startdb.bat" START
  ping 127.0.0.1 > nul  
)

rem Start TomEE
cd "/home/crxnsink/opencrx-2.9.0/\apache-tomee-webprofile-1.0.0"
rmdir /s /q temp
rmdir /s /q work
mkdir temp
.\bin\catalina.bat run
goto end

:stop
set JAVA_HOME=/usr/java/jdk1.6.0_29
set JAVA_HOME=%JAVA_HOME:/=\%

rem Stop HSQLDB
if exist "/home/crxnsink/opencrx-2.9.0/\data\crx\startdb.bat" (
	start "HSQLDB" "/home/crxnsink/opencrx-2.9.0/\data\crx\startdb.bat" STOP
  	ping 127.0.0.1 > nul  
)

rem Stop TomEE
cd "/home/crxnsink/opencrx-2.9.0/\apache-tomee-webprofile-1.0.0"
.\bin\catalina.bat stop
goto end

:end

exit
