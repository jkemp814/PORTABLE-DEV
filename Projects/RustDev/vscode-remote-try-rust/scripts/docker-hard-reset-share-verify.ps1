[CmdletBinding()]
param(
    [string]$SharedRoot = "D:\Environments",
    [string]$WorkspacePath = "D:\Environments\RustDev\vscode-remote-try-rust",
    [int]$DockerReadyTimeoutSeconds = 120
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "[docker-hard-reset] $Message" -ForegroundColor Cyan
}

function Test-DockerReady {
    try {
        $null = docker version --format '{{.Server.Version}}' 2>$null
        return $true
    }
    catch {
        return $false
    }
}

function Wait-DockerReady {
    param([int]$TimeoutSeconds)

    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    while ((Get-Date) -lt $deadline) {
        if (Test-DockerReady) {
            return $true
        }
        Start-Sleep -Seconds 2
    }

    return $false
}

function Get-WindowsChildNames {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "Windows path does not exist: $Path"
    }

    return @(Get-ChildItem -LiteralPath $Path -Directory | Select-Object -ExpandProperty Name | Sort-Object)
}

function Get-DockerDesktopChildNames {
    param([string]$Path)

    if ($Path -notmatch '^[A-Za-z]:\\') {
        throw "Expected a Windows path with drive letter, got: $Path"
    }

    $probe = Get-DockerDesktopLinuxPath -Path $Path
    if (-not $probe.Path) {
        return @()
    }

    $result = Invoke-WslDockerDesktop -ShellCommand "ls -1 '$($probe.Path)' 2>/dev/null || true"
    $text = $result.StdOut.Trim()
    if (-not $text) {
        return @()
    }

    return @($text -split "`r?`n" | Where-Object { $_ -ne "" } | Sort-Object)
}

function Test-DockerSeesPath {
    param([string]$Path)

    $probe = Get-DockerDesktopLinuxPath -Path $Path
    return [bool]$probe.Path
}

function Invoke-WslDockerDesktop {
    param([string]$ShellCommand)

    $stdoutFile = [System.IO.Path]::GetTempFileName()
    $stderrFile = [System.IO.Path]::GetTempFileName()
    try {
        $proc = Start-Process -FilePath "wsl" -WorkingDirectory "C:\" -ArgumentList @("-d", "docker-desktop", "-e", "sh", "-lc", $ShellCommand) -NoNewWindow -Wait -PassThru -RedirectStandardOutput $stdoutFile -RedirectStandardError $stderrFile
        [pscustomobject]@{
            ExitCode = $proc.ExitCode
            StdOut = (Get-Content -Raw -LiteralPath $stdoutFile)
            StdErr = (Get-Content -Raw -LiteralPath $stderrFile)
        }
    }
    finally {
        Remove-Item -LiteralPath $stdoutFile -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $stderrFile -ErrorAction SilentlyContinue
    }
}

function Get-DockerDesktopLinuxPath {
    param([string]$Path)

    if ($Path -notmatch '^[A-Za-z]:\\') {
        return [pscustomobject]@{ Path = $null; Source = $null }
    }

    $drive = $Path.Substring(0, 1).ToLowerInvariant()
    $suffix = $Path.Substring(2).TrimStart('\\') -replace '\\', '/'
    $candidates = @(
        "/mnt/host/$drive/$suffix",
        "/run/desktop/mnt/host/$drive/$suffix"
    )

    foreach ($candidate in $candidates) {
        $test = Invoke-WslDockerDesktop -ShellCommand "test -d '$candidate'"
        if ($test.ExitCode -eq 0) {
            return [pscustomobject]@{ Path = $candidate; Source = $candidate }
        }
    }

    return [pscustomobject]@{ Path = $null; Source = $null }
}

$SharedRoot = (Resolve-Path -LiteralPath $SharedRoot).Path
$WorkspacePath = (Resolve-Path -LiteralPath $WorkspacePath).Path

Write-Step "Shared root: $SharedRoot"
Write-Step "Workspace path: $WorkspacePath"

Write-Step "Stopping Docker Desktop processes..."
Get-Process "Docker Desktop", "com.docker.backend" -ErrorAction SilentlyContinue | Stop-Process -Force

Write-Step "Shutting down WSL..."
& wsl --shutdown | Out-Null

$dockerDesktopExe = Join-Path $env:ProgramFiles "Docker\Docker\Docker Desktop.exe"
if (-not (Test-Path -LiteralPath $dockerDesktopExe)) {
    throw "Docker Desktop executable not found: $dockerDesktopExe"
}

Write-Step "Starting Docker Desktop..."
Start-Process -FilePath $dockerDesktopExe | Out-Null

Write-Step "Waiting for Docker daemon..."
if (-not (Wait-DockerReady -TimeoutSeconds $DockerReadyTimeoutSeconds)) {
    throw "Docker daemon did not become ready within $DockerReadyTimeoutSeconds seconds."
}

Write-Step "Collecting recursive visibility check at shared root..."
$winChildren = Get-WindowsChildNames -Path $SharedRoot
$dockerChildren = Get-DockerDesktopChildNames -Path $SharedRoot

Write-Host "Windows child folders:" -ForegroundColor Gray
$winChildren | ForEach-Object { Write-Host "  - $_" }
Write-Host "Docker-visible child folders:" -ForegroundColor Gray
$dockerChildren | ForEach-Object { Write-Host "  - $_" }

$missing = @($winChildren | Where-Object { $dockerChildren -notcontains $_ })
if ($missing.Count -gt 0) {
    Write-Host "Missing in Docker view:" -ForegroundColor Yellow
    $missing | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
}

Write-Step "Checking workspace path visibility from docker-desktop VM..."
if (-not (Test-DockerSeesPath -Path $WorkspacePath)) {
    throw "Workspace path is still not visible in docker-desktop VM. Update Docker Desktop file sharing/synchronized shares for $SharedRoot and retry."
}

Write-Host "PASS: Docker can see workspace path and shared-root visibility check completed." -ForegroundColor Green
