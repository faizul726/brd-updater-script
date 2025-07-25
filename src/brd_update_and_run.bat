:: PLACEBO
:: PLACEBO
:: Made by github.com/faizul726
:: Updater logic from github.com/faizul726/matject

@echo off
setlocal enabledelayedexpansion
pushd "%~dp0"

set MAJOR=1
set MINOR=2
set deiteu=20250719

rem TODO
rem Add self updater script from Matject
rem 20250719

title Fzul's BRD Updater v%MAJOR%.%MINOR% - %deiteu%

set "GRY=[90m"
set "RED=[91m"
set "GRN=[92m"
set "YLW=[93m"
set "CYN=[96m"
set "WHT=[97m"
set "RST=[0m"

set "updaterVersion=v%MAJOR%.%MINOR%"

:setConfig
cls
call :loadConfig
if not defined brdMajor (
    echo %YLW%[i] Creating a test file to see if current folder is writeable...%RST%
    echo.

    echo Test file for Fzul's BRD Updater>test-file.txt
    if exist "test-file.txt" (
        del /q ".\test-file.txt"
        echo %GRN%[i] Folder is writeable^^!%RST%
        timeout 2 >nul
    ) else (
        echo %RED%[^^!] Folder is NOT writeable.
        echo     Make sure current folder is not in ransomware protection list.
        echo     %GRY%As it often restricts programs to write in the folder.
        echo.

        echo Press any key to exit...%RST%
        pause >nul
        exit /b 1
    )
    cls
    echo %WHT%Fzul's BRD Updater %updaterVersion%
    echo.
    echo %YLW%[*] Initial setup%RST%
    echo.
    echo.
    echo %WHT%[i] BetterRenderDragon is often considered as malware by Microsoft Defender
    echo     Which is a false positive. Means, BRD does nothing harmful but still considered as virus.
    echo     This often leads to BRD files being deleted, thus making BRD not work.%RST%
    echo.

    echo %YLW%[?] Do you want to put this folder in Microsoft Defender exclusions?%RST%
    echo.
    echo %GRN%[Y] Yes ^(will request admin permission^)
    echo %RED%[N] No, skip%RST%
    echo.
    echo %GRY%Note: You can skip if you use other antivirus, 
    echo but make sure to put this folder in exclusion/whitelist of that antivirus.%RST%
    echo.
    choice /c yn /n >nul
    if !errorlevel! equ 1 (
        call :whitelistFolder
    ) else (
        echo %RED%[^^!] Are you sure about not adding this folder to antivirus exclusions?%RST%
        echo.

        echo %RED%[Y] Yes, 101%% sure    %GRN%[N] No, add it to exclusion ^(will request admin permission^)%RST%
        echo.

        choice /c yn /n >nul
        if !errorlevel! equ 2 (call :whitelistFolder) else (echo %YLW%[^^!] Both updater and BRD may not work as expected.%RST% & timeout 3 >nul)
    )

    echo.
    call :setVariable Major
    call :setVariable Minor
    call :setVariable Patch

    echo %WHT%[?] Is the GitHub repo link %CYN%%repoLink%%WHT% correct?%RST%
    echo.
    echo %GRN%[Y] Yes, it is    %RED%[N] No, set my own%RST%
    echo.
    echo.
    choice /c yn /n >nul
    if !errorlevel! equ 2 call :setRepoLink

    echo %WHT%[?] Is the target filename %CYN%%fileName%%WHT% correct?%RST%
    echo.
    echo %GRN%[Y] Yes, it is    %RED%[N] No, set my own%RST%
    echo.
    echo.
    choice /c yn /n >nul
    if !errorlevel! equ 2 call :setFileName

    echo %WHT%[?] Is the executable file name %CYN%%executable%%WHT% correct?%RST%
    echo.
    echo %GRN%[Y] Yes, it is    %RED%[N] No, set my own%RST%
    echo.
    echo.
    choice /c yn /n >nul
    if !errorlevel! equ 2 call :setExecutableName

    cls
    echo %YLW%[?] Are these details correct?%RST%
    echo.
    echo %WHT%Current BRD version:  %RST%v!brdMajor!.!brdMinor!.!brdPatch!
    echo.
    echo %WHT%BRD GitHub repo link: %CYN%!repoLink!%RST%
    echo %WHT%BRD file to download: %RST%!fileName!
    echo %WHT%BRD executable file:  %RST%!executable!
    echo.
    echo %RED%[Y] Yes, everything is correct    %GRN%[N] No, let me set again%RST%
    echo.
    choice /c yn /n >nul
    if !errorlevel! neq 1 goto setConfig
    call :updateConfig "!repoLink!" "!fileName!" "!executable!" "!autoUpdate!" !brdMajor! !brdMinor! !brdPatch!
    exit 0
    pause
)

if "[%1]" equ "[justUpdated]" goto openBrd
echo %YLW%[i] Checking for BRD update and opening in 3 seconds...%RST%
echo     Press [S] to change updater settings.

choice /c s0 /t 3 /d 0 /n >nul
cls
if %errorlevel% equ 1 goto settings

:main
echo %YLW%[i] Checking for BRD update...%RST%
echo.
for /f "delims=" %%L in ('curl -Lso NUL -w "%%{url_effective}" "%repoLink%/releases/latest"') do set "latestReleaseLink=%%L"
::echo Source: %latestReleaseLink%
::echo.
if "%latestReleaseLink:~-1,1%" equ "/" set "latestReleaseLink=%latestReleaseLink:~0,-1%"
if "%latestReleaseLink:~0,8%" equ "https://" (
    if %brdPatch% lss %latestReleaseLink:~-1,1% goto newUpdateAvailable
    if %brdMinor% lss %latestReleaseLink:~-3,1% goto newUpdateAvailable
    if %brdMajor% lss %latestReleaseLink:~-5,1% goto newUpdateAvailable
    echo %GRN%[i] No new update available%RST%
) else (
    echo %YLW%[^^!] Couldn't check for updates%RST%
)
echo.
:openBrd
if not exist "%executable%" (
    echo %RED%[^^!] Executable file "%executable%" not found.%RST%
    echo.
    echo %YLW%[?] What do you want to do?%RST%
    echo.
    echo [1] It exists, 
    echo     just the file name got changed in this update.
    echo     Let me set the executable file name again
    echo.
    echo [2] Download BRD again
    echo.
    echo [B] Exit
    echo.
    choice /c 12b /n >nul
    if !errorlevel! equ 3 exit
    if !errorlevel! equ 2 (
        set brdMajor=0
        set brdMinor=0
        set brdPatch=0
        goto main
    )
    if !errorlevel! equ 1 call :setExecutableName & call :updateConfig "%repoLink%" "%fileName%" "%executable%" "%autoUpdate%" %brdMajor% %brdMinor% %brdPatch% & exit 0
)
echo %YLW%[i] Opening BRD...%RST%
start /i "" "%executable%"
timeout 3 >nul
exit 0

:newUpdateAvailable
if defined autoUpdate (
    echo [i] Updating BRD ^(v%brdMajor%.%brdMinor%.%brdPatch% -^> v%latestReleaseLink:~-5,1%.%latestReleaseLink:~-3,1%.%latestReleaseLink:~-1,1%^)
    echo.
    goto brdUpdater
)
echo %WHT%New BRD update is available^^! ^(v%brdMajor%.%brdMinor%.%brdPatch% -^> v%latestReleaseLink:~-5,1%.%latestReleaseLink:~-3,1%.%latestReleaseLink:~-1,1%^)%RST%
echo.
echo %YLW%[?] Do you want to update?%RST%
echo.
echo %GRN%[Y] Yes    %RED%[N] No%RST%
echo.
choice /c yn /n >nul
if %errorlevel% equ 1 goto brdUpdater
goto openBrd
exit 0

:setVariable
set /p "brd%1=%WHT%Enter the current BRD version %1: %RST%"
echo.
if not defined brd%1 (
    echo %RED%[^^!] Please try again.%RST%
    goto setVariable
)
goto :EOF

:whitelistFolder
:: Made possible thanks to
:: https://stackoverflow.com/a/54099977/30810698

echo %YLW%[i] Adding script folder to Microsoft Defender exclusions...%RST%
echo.
powershell Start-Process -Verb RunAs -Wait powershell -ArgumentList \"Write-Host [i] Adding script folder to exclusions... ; Write-Host ; Add-MpPreference -ExclusionPath `\"`\"`\"%cd%`\"`\"`\" ; Write-Host [*] Done ; sleep 3\" || (
    echo %RED%[^^!] Failed to add folder to Microsoft Defender exclusions.%RST%
    echo.
    echo %YLW%[?] Try again?%RST%
    echo.
    choice /c yn /n >nul
    if !errorlevel! equ 1 goto whitelistFolder
)
echo %GRN%[i] Added successfully%RST%
goto :EOF

:setRepoLink
set "repoLink="
set /p "repoLink=%WHT%Enter BRD GitHub repo link: %RST%"
echo.
if defined repoLink (
    set "repoLink=!repoLink: =!"
    if "!repoLink:~-1,1!" equ "/" set "repoLink=!repoLink:~0,-1!"
    if "!repoLink:~0,8!" neq "https://" set "repoLink=https://!repoLink!"
    echo.
) else (
    echo %RED%[^^!] Please try again.%RST%
    goto setRepoLink
)
goto :EOF

:setFileName
set "fileName="
set /p "fileName=%WHT%Enter target file name (name must be exact): %RST%"
echo.
if defined fileName (
    set "fileName=!fileName: =%20!"
    echo.
) else (
    echo %RED%[^^!] Please try again.%RST%
    goto setFileName
)
goto :EOF

:setExecutableName
set "executable="
set /p "executable=%WHT%Enter executable file name (including extension, case insensitive): %RST%"
echo.
if not defined executable (
    echo %RED%[^^!] Please try again.%RST%
    goto setExecutableName
)
goto :EOF

:brdUpdater
if exist "old_version\" rmdir /q /s ".\old_version"
mkdir old_version
for /d %%D in (*) do if "[%%~nD]" neq "[old_version]" (>nul move /y ".\%%D" old_version)
for %%F in (*) do if "[%%~nxF]" neq "[%~nx0]" (>nul move /y ".\%%F" old_version)
::echo powershell -NoProfile -Command "Invoke-WebRequest '%latestReleaseLink:/tag/=/download/%/%fileName%' -OutFile BRD_download.zip ; Expand-Archive -Force BRD_download.zip ."
::pause
echo %YLW%[i] Downloading BRD from GitHub... %GRY%^(%latestReleaseLink%^)%RST%
powershell -NoProfile -Command "Invoke-WebRequest '%latestReleaseLink:/tag/=/download/%/%fileName%' -OutFile BRD_download.zip ; Expand-Archive -Force BRD_download.zip ."
echo.
if exist "%executable%" (
    echo %GRN%[i] Successfully updated BRD^^!%RST%
    echo     Now updating updater settings...
) else (
    echo %RED%[^^!] Can't find %executable%.
    echo     So, can't ensure whether BRD update is complete.
    echo     Cleaning up...
)
echo.

del /q ".\BRD_download.zip"
call :updateConfig "%repoLink%" "%fileName%" "%executable%" "%autoUpdate%" %latestReleaseLink:~-5,1% %latestReleaseLink:~-3,1% %latestReleaseLink:~-1,1% "justUpdated"
exit 0

:settings
cls
echo %RED%^< [B] Restart BRD updater%WHT%
echo.

echo [1] Change BRD GitHub repo link %GRY%^(currently set to: %repoLink%^)%WHT%
echo [2] Change BRD target file name %GRY%^(currently set to: %fileName%^)%WHT%
echo [3] Change BRD executable file name %GRY%^(currently set to: %executable%^)%WHT%
if defined autoUpdate (
    echo [4] Update without confirmation %GRN%[ON]
) else (
    echo [4] Update without confirmation %GRY%[OFF]
)
echo %WHT%[5] Add current folder to Microsoft Defender exclusions
echo.
echo [6] Reset updater settings
echo.
echo %YLW%Press corresponding key to confirm your choice...%RST%
echo %GRY%Note: Updater will restart after each change%RST%
echo.
choice /c 123456b /n >nul

if %errorlevel% equ 1 call :setRepoLink & call :updateConfig "%repoLink%" "%fileName%" "%executable%" "%autoUpdate%" %brdMajor% %brdMinor% %brdPatch% & exit 0
if %errorlevel% equ 2 call :setFileName & call :updateConfig "%repoLink%" "%fileName%" "%executable%" "%autoUpdate%" %brdMajor% %brdMinor% %brdPatch% & exit 0
if %errorlevel% equ 3 call :setExecutableName & call :updateConfig "%repoLink%" "%fileName%" "%executable%" "%autoUpdate%" %brdMajor% %brdMinor% %brdPatch% & exit 0
if %errorlevel% equ 4 (
    if defined autoUpdate (
        call :updateConfig "%repoLink%" "%fileName%" "%executable%" "" %brdMajor% %brdMinor% %brdPatch% & exit 0
    ) else (
        call :updateConfig "%repoLink%" "%fileName%" "%executable%" "true" %brdMajor% %brdMinor% %brdPatch% & exit 0
    )
)
if %errorlevel% equ 5 call :whitelistFolder & start /i /b "" cmd /c "%~f0" & exit 0
if %errorlevel% equ 6 (
    echo %RED%[?] Are you sure about resetting updater settings?%RST%
    echo.
    echo %RED%[Y] Yes    %GRN%[N] No%RST%
    echo.
    call :updateConfig "https://github.com/QYCottage/BetterRenderDragon" "BetterRenderDragon.zip" "mcbe_injector.exe" "" "" "" "" & exit 0
)
if %errorlevel% equ 7 start /i /b "" cmd /c "%~f0" & exit 0

:updateConfig
echo %YLW%[i] Updating BRD updater settings...%RST%
echo.
copy /d "%~nx0" "%temp%" >nul
(
    echo @echo off
    echo setlocal
    echo pushd "%%~dp0"
    echo ^(echo :: Updated settings [%date% // %time:~0,-6%] ^& echo.^)^>"%~f0"
    echo for /F "usebackq tokens=* delims= skip=2" %%%%L in ^("%~nx0"^) do (
    echo     if "%%%%L" neq ":: CONFIG START" ^(
    echo         ^>^>"%~f0" echo %%%%L
    echo     ^) else ^(
    echo         ^(
    echo             echo :: CONFIG START
    echo             echo :loadConfig
    echo             echo set "repoLink=%~1"
    echo             echo set "fileName=%~2"
    echo             echo set "executable=%~3"
    echo             echo set "autoUpdate=%~4"
    echo             echo set "brdMajor=%~5"
    echo             echo set "brdMinor=%~6"
    echo             echo set "brdPatch=%~7"
    echo             echo :: CONFIG END
    echo         ^)^>^>"%~f0"
    echo         echo %GRN%[i] Updater settings updated successfully.%RST%
    echo         timeout 3 ^>nul
    echo         start /i /b "" cmd /c "%~f0" %~8
    echo         exit 0
    echo     ^)
    echo ^)
)>"%temp%\%~n0_updateConfig.bat"
start /i /b "" cmd /c "%temp%\%~n0_updateConfig.bat"
exit 0

:: CONFIG START
:loadConfig
set "repoLink=https://github.com/QYCottage/BetterRenderDragon"
set "fileName=BetterRenderDragon.zip"
set "executable=mcbe_injector.exe"
set "autoUpdate="
set "brdMajor="
set "brdMinor="
set "brdPatch="
:: CONFIG END
