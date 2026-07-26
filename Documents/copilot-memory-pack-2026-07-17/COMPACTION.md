# COMPACTION

## What Was Changed

1. Linter cleanup in Microsoft.PowerShell_profile.ps1

- Removed unused variable assignments.
- Renamed unapproved-verb functions:
    - Load-EnvFile -> Import-EnvFile
    - svcsync-apply -> Invoke-SvcSyncApply
- Added alias for compatibility:
    - svcsync-apply -> Invoke-SvcSyncApply

2. Multi-host profile consistency

- Added one-time global load guard in host profile.
- Created CurrentUserAllHosts bootstrap profile.ps1 that dot-sources Microsoft.PowerShell_profile.ps1.

3. Prompt readability tweak

- Added explicit separator between OS glyph and label (`glyph: label`) to avoid visual crowding.

## Verification Outcomes

- Profile loads clean in fresh shell.
- Prompt and helper commands resolve.
- Alias compatibility confirmed.

## Cache Recovery Steps

- Save profile file.
- PowerShell: Restart Current Session.
- If needed: Developer: Reload Window.

---

# Session Compaction — 2026-07-17 (Dell <-> HP SSH server + key trust)

## Goal

Continue the cross-machine handoff work and make SSH reliable both ways between Dell (Fedora) and HP (Windows), with low-friction commands and clear recovery steps.

## What changed

- Restored paste usability in PowerShell by binding PSReadLine paste handlers (`Ctrl+v` and `Ctrl+Shift+v`) for the active shell.
- Reviewed and improved `h:\PORTABLE-DEV\Scripts\enable-openssh-server.ps1`.
- Added explicit Administrator privilege detection and plain-language guidance when the script is run in a non-admin shell.
- Kept existing script behavior for OpenSSH Server capability install, `sshd` startup config, firewall rule setup, and connection checks.
- Validated non-admin behavior: script now exits cleanly with a clear message and exit code `1`.
- User then ran the script as Administrator successfully and completed OpenSSH server enablement.

## Verification outcomes

- `sshd` service: `Running` and startup type `Automatic` on HP.
- Port 22: listening on both IPv4 and IPv6 (`0.0.0.0:22` and `:: :22`).
- Local SSH test on HP: `TcpTestSucceeded True` to `127.0.0.1:22`.

## SSH trust and key notes

- Dell -> HP initially failed with host key warning: "remote identification has changed".
- This is expected after creating/recreating the HP SSH host keys.
- Host key trust (`known_hosts`) is separate from login identity keys (`id_ed25519`, etc.).
- Updating Dell's stored host key for HP does not overwrite Fedora login keys.

## Current status

- OpenSSH Server on HP is installed and healthy.
- Remaining operator step: clear stale Dell `known_hosts` entry for HP and reconnect once to trust the new HP host key fingerprint.
- Final user concern to validate in-session: confirm which private key SSH is actually offering/using during auth (`ssh -v` / `ssh -G`).
