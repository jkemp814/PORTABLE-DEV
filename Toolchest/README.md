# Toolchest — Portable Dev Toolkit

Scripts, configs, and resources for the PORTABLE-DEV environment on the SMART-Fit drive.

## VS Code Portable

| Script | Action |
|--------|--------|
| `setup_vscode_portable_linux.sh` | First-time setup: downloads and extracts VS Code Linux portable to `../VSCodePortable-Linux/` |
| `setup_vscode_portable_windows.bat` | Same for Windows (`VSCodePortable-Windows/`) |
| `update_vscode_portable.sh` | Downloads latest VS Code and updates in-place, preserving `data/` (settings, extensions) |

**update_vscode_portable.sh usage:**

```
./update_vscode_portable.sh          # updates both Linux and Windows
./update_vscode_portable.sh linux    # Linux only
./update_vscode_portable.sh windows  # Windows only
```

## Portable Podman

| Script | Action |
|--------|--------|
| `download_portablepodman.sh` | Downloads latest static Podman binaries to `../PortablePodman/` |

Supports an optional version argument: `./download_portablepodman.sh v0.1.0`

## Configs

`Configs/` — editor and tool config templates (`.editorconfig`, `.prettierrc`, ESLint, Rustfmt, tsconfig, etc.). Seed copies for new projects.

## VSCode

`VSCode/User/` — seed VS Code settings, keybindings, and extensions list. Copied into portable data on first setup.

## Fonts

`Fonts/` — development fonts (Cascadia Code).
