@echo off
title Pahina Connect - Library Management System
color 0A

echo.
echo  ==========================================
echo   PAHINA CONNECT - Library Management System
echo  ==========================================
echo.

set JAVA_HOME=C:\Program Files\Java\jdk-25
set CATALINA_HOME=C:\tomcat10\apache-tomcat-10.1.28
set MYSQLD=C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqld.exe
set MYSQL=C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe
set DATADIR=C:\MySQL8Data
set SQL_FILE=C:\Users\Admin\OneDrive\Documents\Pahina_connect\PahinaConnect\database\pahina_connect.sql

:: ============================================================
:: Step 1: Start MySQL 8.0
:: ============================================================
echo  [1/3] Starting MySQL 8.0...

netstat -ano | findstr "0.0.0.0:3306" >nul 2>&1
if %errorlevel%==0 (
    echo  [OK] MySQL already running.
    goto db_running
)

:: Kill any stuck mysqld
taskkill /F /IM mysqld.exe >nul 2>&1
timeout /t 2 >nul

start "MySQL 8.0" /min "%MYSQLD%" --datadir="%DATADIR%" --port=3306 --standalone
echo  [INFO] Waiting for MySQL to start...
timeout /t 10 >nul
echo  [OK] MySQL started.

:db_running

:: ============================================================
:: Step 2: Setup Database (first time only)
:: ============================================================
echo.
echo  [2/3] Checking database...

"%MYSQL%" -u root -proot -h 127.0.0.1 -e "SELECT 1 FROM pahina_connect.users LIMIT 1;" >nul 2>&1
if %errorlevel%==0 (
    echo  [OK] Database ready.
    goto tomcat_start
)

echo  [INFO] Setting up database...
"%MYSQL%" -u root -proot -h 127.0.0.1 < "%SQL_FILE%"
echo  [OK] Database created!

:tomcat_start

:: ============================================================
:: Step 3: Start Tomcat
:: ============================================================
echo.
echo  [3/3] Starting Tomcat...

netstat -ano | findstr "0.0.0.0:8080" >nul 2>&1
if %errorlevel%==0 (
    echo  [OK] Tomcat already running.
    goto open_browser
)

start "Tomcat - Pahina Connect" /min "%CATALINA_HOME%\bin\startup.bat"
echo  [INFO] Waiting for Tomcat...
timeout /t 10 >nul
echo  [OK] Tomcat started.

:open_browser
echo.
echo  ==========================================
echo   Pahina Connect is READY!
echo  ==========================================
echo   URL      : http://localhost:8080/PahinaConnect/
echo   Admin    : admin@pahinaconnect.com
echo   Password : Admin@123
echo  ==========================================
echo.
start http://localhost:8080/PahinaConnect/
echo  Press any key to close...
pause >nul
