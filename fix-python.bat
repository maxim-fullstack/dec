@echo off
echo DEC Python Installation Fix
echo ============================

:: Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Warning: Not running as administrator. Some fixes may not work.
    echo.
)

:: Disable Windows Store Python aliases via registry
echo Disabling Windows Store Python aliases...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\AliasData\python.exe" /v State /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\AliasData\python3.exe" /v State /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\AliasData\pip.exe" /v State /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\AliasData\pip3.exe" /v State /t REG_DWORD /d 3 /f >nul 2>&1

echo Installing Python via winget...
winget install Python.Python.3.12 --accept-source-agreements --accept-package-agreements --silent

echo Waiting for installation to complete...
timeout /t 10 /nobreak >nul

echo Testing Python installation...
python --version >nul 2>&1
if %errorLevel% equ 0 (
    echo Python installation successful!
    python --version
    
    echo Installing Ansible...
    python -m pip install --upgrade pip
    python -m pip install ansible
    
    echo.
    echo Setup complete! You can now run setup.ps1
) else (
    echo Python installation failed or not in PATH.
    echo Please install Python manually from https://python.org
    echo Make sure to check "Add Python to PATH" during installation.
)

echo.
echo Press any key to continue...
pause >nul
