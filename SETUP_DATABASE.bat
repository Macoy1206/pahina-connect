@echo off
title Pahina Connect - Database Setup
color 0A

:: Auto-elevate to Administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting Administrator privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo.
echo  ==========================================
echo   PAHINA CONNECT - Database Setup
echo  ==========================================
echo.

set MYSQL_BIN=C:\Program Files\MySQL\MySQL Server 8.0\bin
set SQL_FILE=C:\Users\Admin\OneDrive\Documents\Pahina_connect\PahinaConnect\database\pahina_connect.sql

:: Step 1: Start MySQL80 service
echo  [1/2] Starting MySQL service...
net start MySQL80
if %errorlevel%==0 (
    echo  [OK] MySQL started!
) else (
    echo  [INFO] MySQL may already be running or failed to start.
)
timeout /t 3 >nul

:: Step 2: Run SQL script
echo.
echo  [2/2] Creating database...
"%MYSQL_BIN%\mysql.exe" -u root -proot -h 127.0.0.1 < "%SQL_FILE%"
if %errorlevel%==0 (
    echo.
    echo  [OK] Database created successfully!
    echo.
    echo  You can now run START_PAHINA_CONNECT.bat
) else (
    echo.
    echo  [!] Database setup failed.
    echo.
    echo  Please do it manually in MySQL Workbench:
    echo  1. Open MySQL Workbench
    echo  2. Connect to Local instance MySQL80
    echo  3. Go to File ^> Open SQL Script
    echo  4. Open: %SQL_FILE%
    echo  5. Press Ctrl+Shift+Enter to run all
)

echo.
pause
