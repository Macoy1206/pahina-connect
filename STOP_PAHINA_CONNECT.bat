@echo off
title Stop Pahina Connect
color 0C

echo.
echo  Stopping Pahina Connect server...
echo.

set JAVA_HOME=C:\Program Files\Java\jdk-25
set CATALINA_HOME=C:\tomcat10\apache-tomcat-10.1.28

call "%CATALINA_HOME%\bin\shutdown.bat"

echo.
echo  [OK] Server stopped.
echo.
pause
