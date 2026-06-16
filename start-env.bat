@echo off
setlocal enabledelayedexpansion

:: PORTABLE-DEV Windows Launcher
:: Auto-detects drive mount path and launches VS Code via WSL

set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "VSCODE_DIR=%SCRIPT_DIR%\VSCodePortable-Windows"
set "WORKSPACE=%SCRIPT_DIR%\PORTABLE-DEV.code-workspace"
set "PORTABLE_PODMAN=%SCRIPT_DIR%\PortablePodman"

echo [INFO] PORTABLE-DEV Windows Launcher
echo [INFO] Drive root: %SCRIPT_DIR%

:: Check if we're on a removable drive
for %%d in (D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if /i "%SCRIPT_DIR%"=="%%d:\PORTABLE-DEV" (
        set "DRIVE_LETTER=%%d"
        goto :found
    )
)
set "DRIVE_LETTER=%SCRIPT_DIR:~0,1%"
:found

echo [INFO] Drive letter: %DRIVE_LETTER%

:: WSL check
where wsl >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] WSL is required but not found. Please enable WSL2.
    pause
    exit /b 1
)

:: PortablePodman check
if exist "%PORTABLE_PODMAN%\bin\podman.exe" (
    echo [INFO] PortablePodman detected.
) else (
    echo [INFO] No PortablePodman binary found -- using host container runtime if available.
)

:: Launch VS Code Portable
if exist "%VSCODE_DIR%\bin\Code.exe" (
    echo [INFO] Launching VS Code Portable...
    start "" "%VSCODE_DIR%\bin\Code.exe" "%WORKSPACE%"
) else (
    echo [ERROR] VS Code Portable not found at %VSCODE_DIR%
    echo [INFO] Run Toolchest\setup_vscode_portable_windows.bat to download it.
    pause
    exit /b 1
)

endlocal
