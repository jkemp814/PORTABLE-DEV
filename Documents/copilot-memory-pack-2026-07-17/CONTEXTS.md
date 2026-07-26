# CONTEXTS

## Environment Snapshot

- OS: Windows
- PowerShell: 7.6.3
- Profile root resolved to OneDrive Documents path.

## Profile Paths (Current User)

- CurrentUserAllHosts: C:\Users\jkemp\OneDrive\Documents\PowerShell\profile.ps1
- CurrentUserCurrentHost: C:\Users\jkemp\OneDrive\Documents\PowerShell\Microsoft.PowerShell_profile.ps1

## Observed Symptoms

- Custom prompt appeared to load inconsistently between hosts.
- PSScriptAnalyzer warnings persisted after edits due to stale diagnostics cache.

## Root Cause Pattern

- Host-specific profile split can cause inconsistent prompt behavior.
- Analyzer cache can show old symbols/line mappings after a file changes.

## 2026-07-17 Dell Rebuild Snapshot

- Machine: `DELL-7740`
- User profile: `C:\Users\James`
- `.ssh` was missing after Windows rebuild and had to be recreated.
- GitHub OpenSSH setup now works on Dell using key `github-Dell-7740-Windows`.
- GitHub SSH test succeeded against `git@github.com`.
- USB repo path `D:\PORTABLE-DEV\Projects\BashDev\Scripts` already existed and `git pull origin main` reported `Already up to date`.
- Git required a `safe.directory` override for that USB repo because the old owner SID did not match the rebuilt Windows account SID.
- SSH aliases were added on Dell for:
    - `HP-Z840` -> `james@192.168.8.8`
    - `Dell-7740` -> `James@192.168.14.2`
- Machine-to-machine LAN keys were not yet copied from Fedora.
- Port 22 checks to both `192.168.8.8` and `192.168.14.2` were not accepting TCP connections during validation.
