@echo off
setlocal enabledelayedexpansion
title OmniLaunch - Publication GitHub
cd /d "%~dp0"

echo ======================================================================
echo       OMNILAUNCH - PUBLICATION DE LA MISE A JOUR SUR GITHUB          
echo ======================================================================
echo.

set "RELEASES_DIR=%~dp0"

:: 1. Localisation de Git (PATH Windows ou GitHub Desktop)
set "GIT_EXE=git"
where git >nul 2>nul
if %errorlevel% neq 0 (
    for /d %%D in ("%LOCALAPPDATA%\GitHubDesktoppp-*") do (
        if exist "%%Desourcespp\git\cmd\git.exe" (
            set "GIT_EXE=%%Desourcespp\git\cmd\git.exe"
        )
    )
)

if not exist "!GIT_EXE!" (
    where !GIT_EXE! >nul 2>nul
    if %errorlevel% neq 0 (
        echo [ERREUR] Git ou GitHub Desktop est introuvable sur votre machine.
        echo Veuillez installer Git ou GitHub Desktop.
        pause
        exit /b 1
    )
)

echo [1/3] Verification du package dans Distribution_MisesAJour...
if not exist "!RELEASES_DIR!OmniLaunch.zip" (
    echo [ATTENTION] OmniLaunch.zip introuvable dans Distribution_MisesAJour.
    echo Lancement automatique de la compilation...
    call "%~dp0COMPILER_RELEASE.bat"
)

echo.
echo [2/3] Verification du depot Git local...
if not exist "!RELEASES_DIR!\.git" (
    echo       Initialisation du depot Git dans Distribution_MisesAJour...
    "!GIT_EXE!" init >nul 2>&1
    "!GIT_EXE!" branch -M main >nul 2>&1
    "!GIT_EXE!" remote add origin https://github.com/baffert/OmniLaunch-Releases.git >nul 2>&1
)

"!GIT_EXE!" add version.json OmniLaunch.zip >nul 2>&1

set "STATUS="
"!GIT_EXE!" status --porcelain > "%TEMP%\omni_git_status.tmp"
set /p STATUS=<"%TEMP%\omni_git_status.tmp"
del "%TEMP%\omni_git_status.tmp" >nul 2>nul

if "!STATUS!"=="" (
    echo.
    echo ======================================================================
    echo  [OK] Aucun nouveau changement : le serveur GitHub est deja a jour !
    echo ======================================================================
    echo.
    pause
    exit /b 0
)

echo.
echo [3/3] Envoi de la mise a jour sur GitHub (Commit & Push)...
for /f "delims=" %%V in ('powershell -NoProfile -Command "(Get-Content '%~dp0version.json' -Raw | ConvertFrom-Json).version"') do (
    set "CUR_VER=%%V"
)

"!GIT_EXE!" commit -m "Release OmniLaunch v!CUR_VER! - %date% %time%"
"!GIT_EXE!" push -u origin main

if %errorlevel% equ 0 (
    echo.
    echo ======================================================================
    echo  [SUCCES] La mise a jour v!CUR_VER! est maintenant en ligne sur GitHub !
    echo  Tous les utilisateurs d'OmniLaunch recevront la notification auto.
    echo ======================================================================
) else (
    echo.
    echo [NOTE] Si le depot GitHub n'existe pas encore sur votre compte :
    echo 1. Rendez-vous sur https://github.com/new
    echo 2. Nommez le depot : OmniLaunch-Releases (Public)
    echo 3. Relancez ce script !
)

echo.
pause
