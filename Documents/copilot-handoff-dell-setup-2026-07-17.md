# Copilot Handoff: Dell SSH + Git Clone Setup

Date: 2026-07-17
Purpose: Continue setup on Dell laptop to clone/pull `jkemp814/Scripts` to USB drive with SSH key auth.

## Current Status

- Current machine is the rebuilt Dell laptop: `DELL-7740`.
- GitHub SSH on Dell is now working with OpenSSH for Windows.
- Dell `.ssh` folder exists at: `C:\Users\James\.ssh`
- GitHub keypair was copied from USB to Dell:
    - `C:\Users\James\.ssh\github-Dell-7740-Windows`
    - `C:\Users\James\.ssh\github-Dell-7740-Windows.pub`
- SSH config now includes a working `github.com` entry using `IdentityFile ~/.ssh/github-Dell-7740-Windows`.
- GitHub authentication test succeeded:
    - `ssh -o StrictHostKeyChecking=accept-new -T git@github.com`
    - Response included: `Hi jkemp814! You've successfully authenticated...`
- Git on this Windows install was present at `C:\Program Files\Git\cmd\git.exe`; current session PATH was refreshed.
- Existing repo on the USB drive was updated successfully at:
    - `D:\PORTABLE-DEV\Projects\BashDev\Scripts`
- `git pull origin main` returned:
    - `Already up to date.`
- Git safe-directory exception was required after Windows rebuild because the repo owner SID changed:
    - `git config --global --add safe.directory D:/PORTABLE-DEV/Projects/BashDev/Scripts`
- SSH host aliases were added to Dell config:
    - `HP-Z840` -> `james@192.168.8.8`
    - `Dell-7740` -> `James@192.168.14.2`
- Remaining blocker for machine-to-machine SSH:
    - local LAN SSH keys were not on the rebuilt Windows profile
    - those keys still need to be copied over from Fedora
    - neither machine was accepting SSH on port 22 at the time of testing

## Current SSH Config On Dell

```sshconfig
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/github-Dell-7740-Windows
    IdentitiesOnly yes

Host HP-Z840
    HostName 192.168.8.8
    User james

Host Dell-7740
    HostName 192.168.14.2
    User James
```

## Remaining Steps For LAN SSH

1. Copy the Fedora local/LAN SSH keypair(s) into `C:\Users\James\.ssh` on Dell.

2. Add `IdentityFile` lines under these host entries once the correct key filenames are available:

`Host HP-Z840`

`    IdentityFile ~/.ssh/<local-lan-key>`

`Host Dell-7740`

`    IdentityFile ~/.ssh/<local-lan-key>`

3. Ensure `sshd` is installed and running on each target machine and that the firewall allows port 22.

4. Test aliases after keys and servers are ready:

`ssh HP-Z840`

`ssh Dell-7740`

## Notes

- OpenSSH (built into Windows) is the intended SSH client; PuTTY is not required.
- `ssh-agent` is optional for GitHub here because `IdentityFile` + `IdentitiesOnly yes` are configured.
- Rebuilt Windows installations can require `safe.directory` for repos on removable media because the old Windows SID no longer matches the new user.

## Update - 2026-07-17 (Post-Recovery Progress)

Completed on Dell Windows host:

- OpenSSH Server capability is now installed:
    - `OpenSSH.Server~~~~0.0.1.0` state = `Installed`
- `sshd` service is now enabled and running:
    - startup type = `Automatic`
    - status = `Running`
- Windows firewall inbound rule for SSH is enabled:
    - `OpenSSH-Server-In-TCP` = enabled, allow, TCP/22
- Local loopback test confirms SSH listener:
    - `Test-NetConnection 127.0.0.1 -Port 22` => success

Workspace SSH config updates completed (`D:\Dell-7740-Windows\config`):

- `HP-Z840` and `Dell-7740` now explicitly prefer ed25519 first with rsa fallback.
- `IdentitiesOnly yes` added for `HP-Z840`, `Dell-7740`, and `github.com` to avoid trying unrelated keys.
- `HostName` normalized under `github.com`.

### Remaining Work To Finish HP-Z840 Connectivity

1. Ensure key files exist in active Windows profile path `C:\Users\James\.ssh`:
    - `id_ed25519`, `id_ed25519.pub`
    - optional fallback: `id_rsa`, `id_rsa.pub`

2. On HP-Z840, make sure OpenSSH server is running and enabled at boot.

3. On HP-Z840, verify firewall allows inbound TCP/22.

4. On HP-Z840 user account (`james`), confirm `~/.ssh/authorized_keys` contains Dell's matching public key (`id_ed25519.pub` preferred).

5. Test from Dell with verbose output:
    - `ssh -vv HP-Z840`

6. If auth fails, verify on HP-Z840:
    - home directory and `.ssh` ownership/permissions
    - `authorized_keys` permissions
    - sshd logs for key rejection reason

## Verification - 2026-07-17 (HP-Z840 Success)

Validation completed from Dell after copying local keypairs into `C:\Users\James\.ssh`:

- `ssh -vv HP-Z840` now loads keys correctly:
    - `id_ed25519` detected and offered
    - `id_rsa` available as fallback
- Server accepted `id_ed25519` and authenticated with `publickey`.
- Interactive shell session opened successfully on HP-Z840 (`james@HP-Z840`).

What changed to fix it:

- Added missing local key files to active Windows profile:
    - `C:\Users\James\.ssh\id_ed25519`
    - `C:\Users\James\.ssh\id_ed25519.pub`
    - `C:\Users\James\.ssh\id_rsa`
    - `C:\Users\James\.ssh\id_rsa.pub`
- Corrected private key ACLs on Dell for OpenSSH compatibility.

Remaining optional clean-up:

1. If you want stricter key usage on HP-Z840, remove legacy rsa key line(s) from HP `authorized_keys` after confirming ed25519 is stable.
2. Optionally enable and start `ssh-agent` on Dell if you prefer agent-backed workflows for non-GitHub hosts.
3. Run `ssh Dell-7740` from HP-Z840 to verify reverse direction and finalize two-way LAN trust.

## Quick Resume Checklist (If Chat Session Is Lost)

Goal: fix Fedora -> Windows SSH (`james@192.168.14.2`) after rebooting into Windows.

### On Windows (Admin PowerShell)

1. Confirm service is up:
    - `Get-Service sshd`

2. Confirm listener is on LAN interfaces:
    - `Get-NetTCPConnection -LocalPort 22 -State Listen`
    - Expect `0.0.0.0:22` and/or `:::22`.

3. Confirm firewall rule is enabled:
    - `Get-NetFirewallRule -Name OpenSSH-Server-In-TCP`
    - If disabled: `Enable-NetFirewallRule -Name OpenSSH-Server-In-TCP`

4. Ensure Windows network profile is not Public (preferred Private):
    - `Get-NetConnectionProfile`
    - If needed: `Set-NetConnectionProfile -InterfaceAlias "Ethernet" -NetworkCategory Private`

5. Confirm Fedora public key is allowed for user `James`:
    - `C:\Users\James\.ssh\authorized_keys` should include Fedora `id_ed25519.pub` line.

### From Fedora

1. Basic reachability test:
    - `ssh -o ConnectTimeout=8 james@192.168.14.2`

2. If no prompt/response, test TCP 22:
    - `nc -vz -w 5 192.168.14.2 22`

3. If prompted to trust host, answer `yes` once.

Expected success signal:

- SSH login prompt or shell opens for `james@DELL-7740`.

## Update - 2026-07-17 (HP-Z840 Follow-Up Diagnostics)

Validated from `HP-Z840` (`hp-z840\jkemp`) using PowerShell:

- `Dell-7740` host entry already uses:
    - `HostName 192.168.14.2`
    - `User james`
- Direct checks to Dell still fail from HP-Z840:
    - `Test-NetConnection 192.168.14.2 -Port 22` => `PingSucceeded=False`, `TcpTestSucceeded=False`
    - `ssh james@192.168.14.2` (batch mode) => timeout / exit 255
- Local HP-Z840 SSH server is currently not configured:
    - `Get-Service sshd` => service not found
    - no local listener on TCP 22
    - no `OpenSSH-Server-In-TCP` firewall rule present

### Important Username Note (Windows)

For OpenSSH on Windows local accounts, username matching is case-insensitive for logon. `james` and `James` should authenticate to the same local account context when the account exists.

### One-Shot Admin Fix On HP-Z840 (Run in elevated PowerShell)

```powershell
$cap = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'
if ($cap.State -ne 'Installed') {
        Add-WindowsCapability -Online -Name $cap.Name
}

Set-Service -Name sshd -StartupType Automatic
Start-Service sshd

if (Get-NetFirewallRule -Name OpenSSH-Server-In-TCP -ErrorAction SilentlyContinue) {
        Enable-NetFirewallRule -Name OpenSSH-Server-In-TCP
} else {
        New-NetFirewallRule -Name OpenSSH-Server-In-TCP -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
}

Get-Service sshd
Get-NetTCPConnection -LocalPort 22 -State Listen
Test-NetConnection 127.0.0.1 -Port 22
```

### After Running The Admin Fix

Re-test from HP-Z840:

```powershell
ssh -vv james@192.168.14.2
ssh -vv Dell-7740
ssh -vv HP-Z840
```

Interpretation:

- If `Dell-7740` still times out, Windows on Dell is likely not currently listening on LAN `:22` or network/firewall profile changed.
- If `HP-Z840` works locally but not from Dell, check HP firewall profile and subnet scope.
