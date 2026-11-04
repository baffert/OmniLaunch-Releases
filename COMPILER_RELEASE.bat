@echo off
setlocal enabledelayedexpansion
title OmniLaunch - Compilation Release
cd /d "%~dp0.."

echo ==============================================================
echo       OMNILAUNCH - COMPILATION RELEASE ET PACKAGING
echo ==============================================================
echo.

echo [1/4] Nettoyage des anciens builds...
if exist "dev\build" rmdir /s /q "dev\build"
if exist "dev\dist" rmdir /s /q "dev\dist"

echo.
echo [2/4] Compilation PyInstaller depuis le dossier dev/...
cd dev
pyinstaller OmniLaunch.spec --noconfirm
cd ..

if not exist "dev\dist\OmniLaunch\OmniLaunch.exe" (
    echo [ERREUR] La compilation PyInstaller a echoue.
    pause
    exit /b 1
)

echo.
echo [3/4] Creation de l'archive ZIP distribuable...
set "DIST_DIR=%~dp0"
if exist "!DIST_DIR!OmniLaunch.zip" del /f /q "!DIST_DIR!OmniLaunch.zip"

powershell -NoProfile -Command "Compress-Archive -Path 'dev\dist\OmniLaunch\*' -DestinationPath '!DIST_DIR!OmniLaunch.zip' -Force"
echo       Archive creee : !DIST_DIR!OmniLaunch.zip

echo.
echo [4/4] Calcul de l'empreinte SHA-256 et mise a jour de version.json...
for /f "delims=" %%H in ('powershell -NoProfile -Command "(Get-FileHash '!DIST_DIR!OmniLaunch.zip' -Algorithm SHA256).Hash"') do (
    set "NEW_SHA256=%%H"
)
echo       SHA-256 : !NEW_SHA256!

set "VJ1=!DIST_DIR!version.json"
powershell -NoProfile -Command " = Get-Content '!VJ1!' -Raw | ConvertFrom-Json; .sha256 = '!NEW_SHA256!';  | ConvertTo-Json -Depth 5 | Set-Content '!VJ1!' -Encoding UTF8"

echo.
echo ==============================================================
echo  [SUCCES] Package pret a etre publie dans Distribution_MisesAJour !
echo ==============================================================
echo.
pause
