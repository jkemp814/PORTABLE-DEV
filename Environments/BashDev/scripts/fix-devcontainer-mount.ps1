param(
    [string]$WorkspacePath = (Resolve-Path ".").Path,
    [switch]$SkipDockerRestart
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Test-Mount {
    param(
        [Parameter(Mandatory = $true)]
        [string]$HostPath
    )

    try {
        $output = & docker run --rm --mount "type=bind,source=$HostPath,target=/mnt/test" alpine:3.20 sh -lc "ls -A /mnt/test | wc -l" 2>&1
        if ($LASTEXITCODE -ne 0) {
            return [pscustomobject]@{
                Path = $HostPath
                Success = $false
                Count = -1
                Raw = ($output | Out-String).Trim()
            }
        }

        $count = [int](($output | Out-String).Trim())
        return [pscustomobject]@{
            Path = $HostPath
            Success = $true
            Count = $count
            Raw = ($output | Out-String).Trim()
        }
    }
    catch {
        return [pscustomobject]@{
            Path = $HostPath
            Success = $false
            Count = -1
            Raw = $_.Exception.Message
        }
    }
}

Write-Step "Checking Docker availability"
docker version | Out-Null

if (-not (Test-Path $WorkspacePath)) {
    throw "Workspace path does not exist: $WorkspacePath"
}

Write-Step "Workspace path"
Write-Host $WorkspacePath

if (-not $SkipDockerRestart) {
    Write-Step "Restarting Docker Desktop service if available"
    $svc = Get-Service -Name "com.docker.service" -ErrorAction SilentlyContinue
    if ($null -ne $svc) {
        Restart-Service -Name "com.docker.service" -Force
        Write-Host "Restarted com.docker.service"
    }
    else {
        Write-Host "Docker service not found; please restart Docker Desktop from the UI."
    }
}
else {
    Write-Step "Skipping Docker restart by request"
}

Write-Step "Shutting down WSL"
wsl --shutdown

Write-Step "Testing mount for workspace path"
Write-Host "Note: this script uses a temporary alpine:3.20 container only for mount diagnostics; it does NOT affect your devcontainer image build." -ForegroundColor DarkGray
$workspaceTest = Test-Mount -HostPath $WorkspacePath
$workspaceDrive = [System.IO.Path]::GetPathRoot($WorkspacePath)
$controlPath = "$env:USERPROFILE"

Write-Step "Testing mount for control path on C:"
$controlTest = Test-Mount -HostPath $controlPath

Write-Host "`nMount test summary:" -ForegroundColor Yellow
Write-Host ("- Workspace: {0} | success={1} | entries={2}" -f $workspaceTest.Path, $workspaceTest.Success, $workspaceTest.Count)
Write-Host ("- Control  : {0} | success={1} | entries={2}" -f $controlTest.Path, $controlTest.Success, $controlTest.Count)
Write-Host "- Devcontainer image source: .devcontainer/Dockerfile" -ForegroundColor DarkGray

if ($workspaceTest.Success -and $workspaceTest.Count -gt 0) {
    Write-Host "`nWorkspace mount looks healthy. You can now run: Dev Containers: Rebuild and Reopen in Container" -ForegroundColor Green
    exit 0
}

Write-Host "`nWorkspace mount still looks broken." -ForegroundColor Red
Write-Host "Next actions:" -ForegroundColor Yellow
Write-Host ("1) In Docker Desktop, enable file sharing for drive {0}" -f $workspaceDrive)
Write-Host "2) Apply settings and restart Docker Desktop"
Write-Host "3) Re-run this script"
Write-Host "4) Temporary fallback: move repo to a C: path and reopen in container"

if (-not $workspaceTest.Success) {
    Write-Host "`nLast workspace mount error:" -ForegroundColor DarkYellow
    Write-Host $workspaceTest.Raw
}

exit 1
