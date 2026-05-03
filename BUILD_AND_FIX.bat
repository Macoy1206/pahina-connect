@echo off
title Pahina Connect - Build and Fix
color 0A

echo.
echo  ==========================================
echo   PAHINA CONNECT - Build and Deploy
echo  ==========================================
echo.

:: Stop Tomcat first
echo  [1/6] Stopping Tomcat...
taskkill /F /IM java.exe >nul 2>&1
timeout /t 3 >nul
echo  [OK] Tomcat stopped

:: Check for Maven
echo.
echo  [2/6] Looking for Maven...

set MAVEN_HOME=
if exist "C:\apache-maven\bin\mvn.cmd" set MAVEN_HOME=C:\apache-maven
if exist "C:\apache-maven-3.9.9\bin\mvn.cmd" set MAVEN_HOME=C:\apache-maven-3.9.9
if exist "C:\Program Files\Apache\Maven\bin\mvn.cmd" set "MAVEN_HOME=C:\Program Files\Apache\Maven"
if exist "%USERPROFILE%\apache-maven\bin\mvn.cmd" set "MAVEN_HOME=%USERPROFILE%\apache-maven"

if "%MAVEN_HOME%"=="" (
    echo  [!] Maven not found!
    echo.
    echo  Please extract Maven to one of these locations:
    echo  - C:\apache-maven
    echo  - C:\apache-maven-3.9.9
    echo  - %USERPROFILE%\apache-maven
    echo.
    echo  Or tell me where you extracted it.
    pause
    exit /b 1
)

echo  [OK] Found Maven at: %MAVEN_HOME%

:: Set environment
set JAVA_HOME=C:\Program Files\Java\jdk-25
set PATH=%MAVEN_HOME%\bin;%JAVA_HOME%\bin;%PATH%

:: Verify Maven works
echo.
echo  [3/6] Verifying Maven...
"%MAVEN_HOME%\bin\mvn.cmd" -version
if %errorlevel% neq 0 (
    echo  [!] Maven verification failed!
    pause
    exit /b 1
)
echo  [OK] Maven is working

:: Build project
echo.
echo  [4/6] Building project...
cd PahinaConnect
"%MAVEN_HOME%\bin\mvn.cmd" clean package -DskipTests
if %errorlevel% neq 0 (
    echo  [!] Build failed!
    cd ..
    pause
    exit /b 1
)
cd ..
echo  [OK] Build successful!

:: Deploy WAR file
echo.
echo  [5/6] Deploying to Tomcat...
if exist "C:\tomcat10\apache-tomcat-10.1.28\webapps\PahinaConnect.war" (
    del "C:\tomcat10\apache-tomcat-10.1.28\webapps\PahinaConnect.war"
)
if exist "C:\tomcat10\apache-tomcat-10.1.28\webapps\PahinaConnect" (
    rmdir /S /Q "C:\tomcat10\apache-tomcat-10.1.28\webapps\PahinaConnect"
)
copy "PahinaConnect\target\PahinaConnect.war" "C:\tomcat10\apache-tomcat-10.1.28\webapps\"
echo  [OK] WAR file deployed!

:: Start Tomcat
echo.
echo  [6/6] Starting Tomcat...
set CATALINA_HOME=C:\tomcat10\apache-tomcat-10.1.28
start "Tomcat - Pahina Connect" "%CATALINA_HOME%\bin\startup.bat"
timeout /t 15 >nul
echo  [OK] Tomcat started!

echo.
echo  ==========================================
echo   BUILD AND DEPLOYMENT COMPLETE!
echo  ==========================================
echo.
echo  Wait 30 seconds for Tomcat to fully start, then:
echo.
echo  Open: http://localhost:8080/PahinaConnect
echo.
echo  Login:
echo  - Admin: admin@pahinaconnect.com / Admin@123
echo  - Student: juan.delacruz@student.com / Student@123
echo.
echo  Press any key to open browser...
pause >nul
start http://localhost:8080/PahinaConnect
