[CmdletBinding()]
param(
    [string]$WorkspacePath = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [string]$ProbeImage = "mcr.microsoft.com/devcontainers/rust:1-1-bullseye",
    [switch]$HealOnFailure,
    [switch]$OpenCode,
    [string]$CodeCommand = "code",
    [int]$DockerReadyTimeoutSeconds = 240
)

$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $false

function Write-Step {
    param([string]$Message)
    Write-Host "[devcontainer-preflight] $Message" -ForegroundColor Cyan
}

function Test-DockerDaemon {
    $stdoutFile = [System.IO.Path]::GetTempFileName()
    $stderrFile = [System.IO.Path]::GetTempFileName()
    try {
        $process = Start-Process -FilePath "docker" -ArgumentList @("version", "--format", "{{.Server.Version}}") -NoNewWindow -Wait -PassThru -RedirectStandardOutput $stdoutFile -RedirectStandardError $stderrFile
        return ($process.ExitCode -eq 0)
    }
    catch {
        return $false
    }
    finally {
        Remove-Item -LiteralPath $stdoutFile -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $stderrFile -ErrorAction SilentlyContinue
    }
}

function Wait-DockerReady {
    param([int]$TimeoutSeconds)

    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    while ((Get-Date) -lt $deadline) {
        $pipeReady = Test-Path "\\.\pipe\dockerDesktopLinuxEngine"
        if ($pipeReady -and (Test-DockerDaemon)) {
            return $true
        }
        Start-Sleep -Seconds 2
    }

    return $false
}

function Test-BindMount {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Image
    )

    $stdoutFile = [System.IO.Path]::GetTempFileName()
    $stderrFile = [System.IO.Path]::GetTempFileName()

    try {
        $dockerArgs = @(
            "run", "--rm",
            "--mount", "type=bind,source=$Path,target=/work,consistency=cached",
            "--entrypoint", "/bin/sh",
            $Image,
            "-lc", "test -d /work"
        )

        $process = Start-Process -FilePath "docker" -ArgumentList $dockerArgs -NoNewWindow -Wait -PassThru -RedirectStandardOutput $stdoutFile -RedirectStandardError $stderrFile
        $output = @()
        if (Test-Path $stdoutFile) {
            $output += Get-Content -Raw -Path $stdoutFile
        }
        if (Test-Path $stderrFile) {
            $output += Get-Content -Raw -Path $stderrFile
        }

        $exitCode = $process.ExitCode
    }
    finally {
        Remove-Item -LiteralPath $stdoutFile -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $stderrFile -ErrorAction SilentlyContinue
    }

    [pscustomobject]@{
        Success = ($exitCode -eq 0)
        ExitCode = $exitCode
        Output = ($output | Out-String).Trim()
    }
}

function Restart-DockerDesktop {
    Write-Step "Shutting down WSL (refreshes docker-desktop mount state)..."
    & wsl --shutdown | Out-Null

    $dockerCli = Join-Path $env:ProgramFiles "Docker\Docker\DockerCli.exe"
    $dockerDesktopExe = Join-Path $env:ProgramFiles "Docker\Docker\Docker Desktop.exe"

    if (Test-Path $dockerCli) {
        Write-Step "Asking Docker Desktop to shut down..."
        & $dockerCli -Shutdown | Out-Null
    }
    else {
        Write-Step "DockerCli.exe not found; stopping Docker Desktop process if running..."
        Get-Process "Docker Desktop", "com.docker.backend", "com.docker.build" -ErrorAction SilentlyContinue | Stop-Process -Force
    }

    $deadline = (Get-Date).AddSeconds(20)
    while ((Get-Date) -lt $deadline) {
        $running = Get-Process "Docker Desktop", "com.docker.backend", "com.docker.build" -ErrorAction SilentlyContinue
        if (-not $running) {
            break
        }
        Start-Sleep -Seconds 1
    }

    $stillRunning = Get-Process "Docker Desktop", "com.docker.backend", "com.docker.build" -ErrorAction SilentlyContinue
    if ($stillRunning) {
        Write-Step "Forcing remaining Docker Desktop processes to stop..."
        $stillRunning | Stop-Process -Force
    }

    if (-not (Test-Path $dockerDesktopExe)) {
        throw "Docker Desktop executable was not found at '$dockerDesktopExe'."
    }

    Write-Step "Starting Docker Desktop..."
    Start-Process -FilePath $dockerDesktopExe | Out-Null
}

function Get-DockerDesktopPathDiagnostics {
    param([Parameter(Mandatory = $true)][string]$WindowsPath)

    if (-not (Get-Command wsl -ErrorAction SilentlyContinue)) {
        return @()
    }

    if ($WindowsPath -notmatch '^[A-Za-z]:\\') {
        return @()
    }

    $drive = $WindowsPath.Substring(0, 1).ToLowerInvariant()
    $suffix = $WindowsPath.Substring(2).TrimStart('\\') -replace '\\', '/'

    $probePaths = @(
        "/mnt/host/$drive/$suffix",
        "/run/desktop/mnt/host/$drive/$suffix"
    )

    $results = @()
    foreach ($path in $probePaths) {
        $stdoutFile = [System.IO.Path]::GetTempFileName()
        $stderrFile = [System.IO.Path]::GetTempFileName()
        try {
            $process = Start-Process -FilePath "wsl" -WorkingDirectory "C:\\" -ArgumentList @("-d", "docker-desktop", "-e", "sh", "-lc", "test -d '$path'") -NoNewWindow -Wait -PassThru -RedirectStandardOutput $stdoutFile -RedirectStandardError $stderrFile
            $exitCode = $process.ExitCode
        }
        finally {
            Remove-Item -LiteralPath $stdoutFile -ErrorAction SilentlyContinue
            Remove-Item -LiteralPath $stderrFile -ErrorAction SilentlyContinue
        }

        $results += [pscustomobject]@{
            Path = $path
            Exists = ($exitCode -eq 0)
        }
    }

    return $results
}

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw "Docker CLI was not found on PATH. Install Docker Desktop or add docker.exe to PATH."
}

if (-not (Test-Path -LiteralPath $WorkspacePath -PathType Container)) {
    throw "Workspace path does not exist or is not a directory: $WorkspacePath"
}

$WorkspacePath = (Resolve-Path -LiteralPath $WorkspacePath).Path

Write-Step "Workspace path: $WorkspacePath"

if (-not (Test-DockerDaemon)) {
    if (-not $HealOnFailure) {
        throw "Docker daemon is not reachable. Start Docker Desktop and re-run this script, or use -HealOnFailure."
    }

    Write-Step "Docker daemon is not reachable; attempting reset/start because -HealOnFailure is enabled..."
    Restart-DockerDesktop
    Write-Step "Waiting for Docker daemon to become ready..."
    if (-not (Wait-DockerReady -TimeoutSeconds $DockerReadyTimeoutSeconds)) {
        throw "Docker daemon did not become ready within $DockerReadyTimeoutSeconds seconds."
    }
}

Write-Step "Probing bind mount via Docker..."
$probe = Test-BindMount -Path $WorkspacePath -Image $ProbeImage

if (-not $probe.Success) {
    Write-Step "Initial bind mount probe failed (exit code $($probe.ExitCode))."
    if ($probe.Output) {
        Write-Host $probe.Output -ForegroundColor Yellow
    }

    $diagnostics = Get-DockerDesktopPathDiagnostics -WindowsPath $WorkspacePath
    if ($diagnostics.Count -gt 0) {
        Write-Step "Docker Desktop VM path diagnostics:"
        foreach ($entry in $diagnostics) {
            $state = if ($entry.Exists) { "exists" } else { "missing" }
            Write-Host "  - $state : $($entry.Path)" -ForegroundColor DarkYellow
        }
        if (-not ($diagnostics | Where-Object { $_.Exists })) {
            Write-Host "Docker Desktop cannot currently see this folder path from its VM. Check Docker Desktop file sharing / synchronized file share settings for this directory." -ForegroundColor Yellow
        }
    }

    if (-not $HealOnFailure) {
        throw "Bind mount probe failed. Re-run with -HealOnFailure to auto-reset WSL and Docker Desktop."
    }

    Restart-DockerDesktop

    Write-Step "Waiting for Docker daemon to become ready..."
    if (-not (Wait-DockerReady -TimeoutSeconds $DockerReadyTimeoutSeconds)) {
        throw "Docker daemon did not become ready within $DockerReadyTimeoutSeconds seconds."
    }

    Write-Step "Re-running bind mount probe..."
    $probe = Test-BindMount -Path $WorkspacePath -Image $ProbeImage
    if (-not $probe.Success) {
        if ($probe.Output) {
            Write-Host $probe.Output -ForegroundColor Yellow
        }

        $diagnostics = Get-DockerDesktopPathDiagnostics -WindowsPath $WorkspacePath
        if ($diagnostics.Count -gt 0) {
            Write-Step "Docker Desktop VM path diagnostics after reset:"
            foreach ($entry in $diagnostics) {
                $state = if ($entry.Exists) { "exists" } else { "missing" }
                Write-Host "  - $state : $($entry.Path)" -ForegroundColor DarkYellow
            }
        }

        throw "Bind mount still failing after WSL/Docker reset."
    }
}

Write-Step "Bind mount probe passed. Docker can see your workspace path."

if ($OpenCode) {
    Write-Step "Opening VS Code at workspace path..."
    try {
        & $CodeCommand $WorkspacePath
    }
    catch {
        Write-Host "VS Code launch command '$CodeCommand' failed. Open the folder manually." -ForegroundColor Yellow
    }
}

Write-Host "Ready: you can run 'Dev Containers: Reopen in Container' now." -ForegroundColor Green
