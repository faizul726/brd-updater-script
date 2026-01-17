:: Born on 20260107-1034
:: Made by github.com/faizul726

@echo off
setlocal enabledelayedexpansion
pushd "%~dp0"

set "version=2.1"

title Fzul's BRD Manager Script v%version%

if not exist script_config.txt (
    >script_config.txt echo 0
)

set "WINHTTP_DLL=https://github.com/faizul726/ModLoader/releases/download/20251101-88c9ed6/WINHTTP.dll"
set "BRD_MIRROR=https://github.com/faizul726/brd-mirror/releases/latest"
set /p SCRIPT_CONFIG=<script_config.txt

set "BRD_FILENAME_0=BetterRenderDragon-no-imgui.dll"
set "BRD_FILENAME_1=BetterRenderDragon.dll"

set "_versionString=!SCRIPT_CONFIG:~1!"
if defined _versionString for /f "tokens=1,2 delims=__" %%A in ("%_versionString%") do (
    set /a CURRENT_VERSION=%%A
    set "CURRENT_VERSION_NAME=%%B"
)

:: Some color codes and goodies
set "ESC=["
set "GRY=[90m"
set "RED=[91m"
set "GRN=[92m"
set "YLW=[93m"
set "BLU=[94m"
set "CYN=[96m"
set "WHT=[97m"
set "RST=[0m"
set "ERR=[41;97m"

set "hideCursor=[?25l"
set "showCursor=[?25h"

cls
echo !YLW![*] Getting Minecraft install location...!RST!
echo.

:: Thanks to github.com/FlaredRoverCodes
for /f "tokens=*" %%P in ('powershell -NoProfile -Command "(Get-AppxPackage -Name Microsoft.MinecraftUWP).InstallLocation"') do (set "MCLOCATION=%%P")

if not defined MCLOCATION (echo !ERR![^^!] Minecraft is not installed!RST! & goto :stoppu)

echo test file >"!MCLOCATION!\testing.txt" && (
    del /q /s "!MCLOCATION!\testing.txt" >nul
    :: Thanks https://stackoverflow.com/a/17085933/30810698
    call 
) || (
    echo !ERR![^^!] Can't write to "!MCLOCATION!"!RST!
    goto :stoppu
)

where curl >nul 2>&1 || (
    echo !ERR![^^!] curl is missing. The script won't work for you.
)

:INIT
cls
pushd "%~dp0"
echo %hideCursor%!WHT!Fzul's BRD Manager Script v%version% ^| !CYN!github.com/faizul726/brd-updater-script!RST!
echo.

echo !GRN![1] Setup BRD
echo !BLU![2] Update BRD
echo !RED![3] Remove BRD
echo.

echo !WHT![S] Settings    !RED![B] Exit!RST!
echo.
echo !YLW!Press corresponding key to select your choice!RST!
echo.
echo !GRY!MC install location: !MCLOCATION!
if defined CURRENT_VERSION_NAME (
    echo BRD version: %CURRENT_VERSION_NAME%!RST!
) else (
    echo BRD version: N/A!RST!
)


choice /c 123sb /n >nul

call :option-!errorlevel!

goto INIT

:option-1
cls
if defined CURRENT_VERSION_NAME (
    echo !YLW![^^!] You already have setup BRD.!RST!
    echo.

    goto return
)
pushd "%temp%"
if exist "WINHTTP.dll" (del /q ".\WINHTTP.dll" >nul)

echo !YLW![*] Downloading ModLoader...!RST!
echo.

curl -L -s -o WINHTTP.dll "%WINHTTP_DLL%" >nul
if !errorlevel! equ 0 if exist "WINHTTP.dll" (
    echo !GRN![*] Downloaded successfully!RST!
    echo.

    move /y "WINHTTP.dll" "!MCLOCATION!" >nul
    echo !GRN![*] Moved "WINHTTP.dll" to "!MCLOCATION!"!RST!
    echo.
) else (
    echo !RED![^^!] Failed to download.!RST!
    echo.

    goto return
)

echo !YLW![*] Getting BetterRenderDragon version...!RST!
echo.

for /f "delims=" %%L in ('curl -Ls -o NUL -w "%%{url_effective}" "%BRD_MIRROR%"') do (set "latestLink=%%L")
if "%latestLink%" equ "%BRD_MIRROR%" (
    echo !RED![^^!] Failed to download.!RST!
    echo.

    goto return
)

for /f "tokens=1,2 delims=__" %%A in ("%latestLink:~53%") do (
    set /a BRD_VERSION=%%A
    set "BRD_VERSION_NAME=%%B"
)

echo !GRN![*] Found version %BRD_VERSION_NAME%!RST!
echo.

if exist "BetterRenderDragon.dll" (del /q ".\BetterRenderDragon.dll" >nul)

echo !YLW![*] Downloading...!RST!
echo.

curl -L -s -o "BetterRenderDragon.dll" "%latestLink:/tag/=/download/%/!BRD_FILENAME_%SCRIPT_CONFIG:~0,1%!" >nul
if !errorlevel! equ 0 if exist "BetterRenderDragon.dll" (
    echo !GRN![*] Downloaded successfully!RST!
    echo.

    if not exist "%APPDATA%\Minecraft Bedrock\mods" (mkdir "%APPDATA%\Minecraft Bedrock\mods")
    move /y "BetterRenderDragon.dll" "%APPDATA%\Minecraft Bedrock\mods" >nul
    echo !GRN![*] Moved "BetterRenderDragon.dll" to "%APPDATA%\Minecraft Bedrock\mods"!RST!
    echo.
) else (
    echo !RED![^^!] Failed to download.!RST!
    echo.

    goto return
)

popd

:: Disables debug (console) window of ModLoader, as it likely doesn't matter to anyone using this script
>"%MCLOCATION%\config.ini" (
    echo [General]
    echo Console=false
    echo Preview=false
)

>script_config.txt echo %SCRIPT_CONFIG:~0,1%%BRD_VERSION%__%BRD_VERSION_NAME%
set /a CURRENT_VERSION=%BRD_VERSION%
set "CURRENT_VERSION_NAME=%BRD_VERSION_NAME%"

echo !GRN![*] Done^^! BetterRenderDragon now should launch automatically when you open the game.!RST!
echo.

goto return
exit /b

:option-2
cls
if not defined CURRENT_VERSION (
    echo !YLW![^^!] Setup BRD first^^!!RST!
    echo.
    
    goto return
)
pushd "%temp%"

echo !YLW![*] Checking for updates...!RST!
echo.

for /f "delims=" %%L in ('curl -Ls -o NUL -w "%%{url_effective}" "%BRD_MIRROR%"') do (set "latestLink=%%L")

if "%latestLink%" equ "%BRD_MIRROR%" (
    echo !RED![^^!] Failed to check for update.!RST!
    echo.

    goto return
)

for /f "tokens=1,2 delims=__" %%A in ("%latestLink:~53%") do (
    set /a BRD_VERSION=%%A
    set "BRD_VERSION_NAME=%%B"
)

if %BRD_VERSION% gtr %CURRENT_VERSION% (
    echo !YLW![*] New update is available!RST! ^(%CURRENT_VERSION_NAME% -^> %BRD_VERSION_NAME%^)
    echo.
    
    echo !YLW![?] Do you want to update?!RST!
    echo.
    echo !RED![Y] Yes    !GRN![N] No!RST!
    
    choice /c yn /n >nul
    
    if !errorlevel! neq 1 (exit /b) else (
        cls
        echo !YLW![*] Downloading BRD update...!RST!
        echo.

        curl -L -s -o "BetterRenderDragon.dll" "%latestLink:/tag/=/download/%/!BRD_FILENAME_%SCRIPT_CONFIG:~0,1%!" >nul
        if !errorlevel! equ 0 if exist "BetterRenderDragon.dll" (
            echo !GRN![*] Downloaded successfully!RST!
            echo.

            if not exist "%APPDATA%\Minecraft Bedrock\mods" (mkdir "%APPDATA%\Minecraft Bedrock\mods")
            move /y "BetterRenderDragon.dll" "%APPDATA%\Minecraft Bedrock\mods" >nul
            echo !GRN![*] Moved "BetterRenderDragon.dll" to "%APPDATA%\Minecraft Bedrock\mods"!RST!
            echo.

            popd
            >script_config.txt echo %SCRIPT_CONFIG:~0,1%!BRD_VERSION!__!BRD_VERSION_NAME!
            set /a CURRENT_VERSION=%BRD_VERSION%
            set "CURRENT_VERSION_NAME=%BRD_VERSION_NAME%"

            echo !GRN![*] Updated successfully^^!!RST!
            echo.

            goto return
        ) else (
            echo !RED![^^!] Failed to download.!RST!
            echo.

            goto return
        )
    )
)

if %BRD_VERSION% equ %CURRENT_VERSION% (
    echo !GRN![*] You already have the latest version of BRD.!RST!
    echo.

    goto return
)

if %BRD_VERSION% equ %CURRENT_VERSION% (
    echo !YLW![*] Hmmmmmmm you somehow have a newer version of BRD that's not available online.!RST!
    echo Very sus ^>:^)
    echo.

    goto return
)

pause
exit /b

:option-3
cls
if not defined CURRENT_VERSION (
    echo !YLW![^^!] Setup BRD first^^!!RST!
    echo.

    goto return
)

echo !YLW![?] Are you sure about BRD removal?!RST!
echo.

echo !RED![Y] Yes    !GRN![N] No!RST!

choice /c yn /n >nul
if !errorlevel! neq 1 (exit /b)
cls

if exist "%MCLOCATION%\WINHTTP.dll" (
    del /q "%MCLOCATION%\WINHTTP.dll" >nul
    echo !YLW![*] Deleted WINHTTP.dll from "%MCLOCATION%"!RST!
    echo.
)

if exist "%APPDATA%\Minecraft Bedrock\mods\BetterRenderDragon.dll" (
    del /q "%APPDATA%\Minecraft Bedrock\mods\BetterRenderDragon.dll"
    echo !YLW![*] Deleted BetterRenderDragon.dll from "%APPDATA%\Minecraft Bedrock\mods"!RST!
    echo.
)

>script_config.txt echo %SCRIPT_CONFIG:~0,1%
set "CURRENT_VERSION="
set "CURRENT_VERSION_NAME="

echo !GRN![*] Deleted BRD related files, BRD should no longer start with Minecraft!RST!
echo.

goto return
exit /b


:option-4
:settings_init
set /p SCRIPT_CONFIG=<script_config.txt
cls
if "%SCRIPT_CONFIG:~0,1%" equ "0" (
    set "settings_1="
) else (
    set "settings_1=1"
)

if defined settings_1 (set "toggle_1=!GRN![x]!RST!") else (set "toggle_1=!GRY![ ]!RST!")

echo !RED!^< [B] Back!RST!
echo.

echo !toggle_1! 1. Download IMGUI version instead of NO_IMGUI
echo.

echo !YLW!Press corresponding number to select/toggle...!RST!
choice /c 1b /n >nul
if !errorlevel! equ 1 (
    if defined settings_1 (set "value=0") else (set "value=1")
    >script_config.txt echo !value!%SCRIPT_CONFIG:~1%
    
    goto settings_init
)

if !errorlevel! equ 2 (exit /b)


:return
echo Press any key to go back...
pause >nul
exit /b

:stoppu
echo The script won't work for you.
echo.

echo Press any key to exit...
pause >nul

:option-5
exit 