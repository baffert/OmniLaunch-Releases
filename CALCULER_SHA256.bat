@echo off
setlocal enabledelayedexpansion
title OmniLaunch - Calculateur SHA-256
cd /d "%~dp0"

echo ==============================================================
echo             OMNILAUNCH - VERIFICATION SHA-256                
echo ==============================================================
echo.

set "TARGET=Distribution_MisesAJour\OmniLaunch.zip"
if not exist "!TARGET!" (
    set "TARGET=..\dist\OmniLaunch\OmniLaunch.exe"
)

if not exist "!TARGET!" (
    echo [ERREUR] Fichier cible introuvable (!TARGET!).
    echo Veuillez d'abord executer COMPILER_RELEASE.bat.
    echo.
    pause
    exit /b 1
)

echo Fichier analyse : !TARGET!
for /f "delims=" %%H in ('powershell -NoProfile -Command "(Get-FileHash '!TARGET!' -Algorithm SHA256).Hash"') do (
    set "HASH=%%H"
)
echo.
echo ==============================================================
echo  EMPREINTE SHA-256 :
echo  !HASH!
echo ==============================================================
echo.
echo Ce hash est automatiquement synchronise dans version.json.
echo.
pause
