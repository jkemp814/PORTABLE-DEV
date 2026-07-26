# skills

## PowerShell Profile Stabilization Playbook

### 1) Confirm Active Profile Targets

Use:

- `$PROFILE`
- `$PROFILE | Format-List *`

Goal:

- Confirm CurrentUserAllHosts and CurrentUserCurrentHost paths.

### 2) Unify Host Behavior

Pattern:

- Keep logic in Microsoft.PowerShell_profile.ps1.
- Dot-source it from profile.ps1.
- Add one-time global guard in the main profile to prevent double execution.

### 3) Keep Analyzer Clean

- Prefer approved verbs for function names.
- Remove unused assignments.
- Keep backward-compatible aliases when command names change.

### 4) Validate in Clean Shell

Use:

- `pwsh -NoProfile -Command ". $PROFILE.CurrentUserAllHosts; Get-Command prompt"`
- `pwsh -NoProfile -Command ". $PROFILE.CurrentUserCurrentHost; Get-Command Invoke-SvcSyncApply,svcsync-apply"`

### 5) If Diagnostics Look Wrong

- Restart PowerShell session in VS Code.
- Reload VS Code window.
