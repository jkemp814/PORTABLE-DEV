$ErrorActionPreference = 'Stop'

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host ''
    Write-Host 'This script needs an Administrator PowerShell window.' -ForegroundColor Yellow
    Write-Host 'How to run it:' -ForegroundColor Yellow
    Write-Host '1) Open Start menu, type PowerShell, then choose Run as administrator.' -ForegroundColor Yellow
    Write-Host '2) Run: & "H:\PORTABLE-DEV\Scripts\enable-openssh-server.ps1"' -ForegroundColor Yellow
    Write-Host ''
    exit 1
}

Write-Host 'Checking OpenSSH Server capability...'
$cap = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'
if (-not $cap) {
    throw 'Could not find OpenSSH.Server capability on this system.'
}

if ($cap.State -ne 'Installed') {
    Write-Host 'Installing OpenSSH Server capability...'
    Add-WindowsCapability -Online -Name $cap.Name | Out-Null
} else {
    Write-Host 'OpenSSH Server capability already installed.'
}

Write-Host 'Configuring sshd service...'
Set-Service -Name sshd -StartupType Automatic
Start-Service sshd

Write-Host 'Ensuring firewall rule exists and is enabled...'
$rule = Get-NetFirewallRule -Name OpenSSH-Server-In-TCP -ErrorAction SilentlyContinue
if ($rule) {
    Enable-NetFirewallRule -Name OpenSSH-Server-In-TCP | Out-Null
} else {
    New-NetFirewallRule -Name OpenSSH-Server-In-TCP -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 | Out-Null
}

Write-Host ''
Write-Host 'Validation:'
Get-Service sshd | Select-Object Name, Status, StartType | Format-Table -AutoSize
Get-NetTCPConnection -LocalPort 22 -State Listen | Select-Object LocalAddress, LocalPort, OwningProcess | Format-Table -AutoSize
Test-NetConnection 127.0.0.1 -Port 22 | Select-Object ComputerName, RemoteAddress, PingSucceeded, TcpTestSucceeded | Format-Table -AutoSize

Write-Host ''
Write-Host 'Done. Next, test from HP-Z840 shell:'
Write-Host '  ssh -vv james@192.168.14.2'
