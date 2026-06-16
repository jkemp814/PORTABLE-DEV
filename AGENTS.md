# AGENTS

Purpose: Help coding agents become productive quickly in this repo.

## Project Snapshot

- Portable dev environment on a USB drive -- zero host prerequisites.
- Hybrid architecture: self-contained `PortablePodman` (static binaries) or host Podman/Docker fallback.
- Target audience: students without reliable internet or their own machine.
- Cross-platform: Linux and Windows (via WSL).

## Key Files

| File                                          | Purpose                                                                             |
| --------------------------------------------- | ----------------------------------------------------------------------------------- |
| `README.md`                                   | Full project docs, folder structure, quick start                                    |
| `start-env.sh`                                | Linux launcher -- detects mount, configures PortablePodman, opens VS Code           |
| `start-env.bat`                               | Windows launcher (WSL-based)                                                        |
| `PortablePodman/config/storage.conf`          | Container storage paths (uses `__PORTABLE_DEV__` placeholder, rewritten at runtime) |
| `.devcontainer/devcontainer.json`             | Root devcontainer -- mounts Projects/ and Scripts/ relative to drive                |
| `.devcontainer/Dockerfile`                    | Fedora 44 base with multi-language dev tools                                        |
| `Environments/`                               | Per-language devcontainer configs (Python, Rust, C++, Bash, Full)                   |
| `Toolchest/download_portablepodman.sh`        | Downloads static podman + deps into PortablePodman/bin/                             |
| `Toolchest/setup_vscode_portable_linux.sh`    | Downloads/extracts VS Code Portable for Linux                                       |
| `Toolchest/setup_vscode_portable_windows.bat` | Downloads/extracts VS Code Portable for Windows                                     |

## First Steps For Agents

1. Read `README.md` for the full architecture and folder layout.
2. Read `start-env.sh` to understand the self-contained launch flow and path rewriting.
3. Read `PortablePodman/config/storage.conf` -- note the `__PORTABLE_DEV__` placeholder pattern.
4. Check `.gitignore` before touching files -- many directories (bin/, storage/, Environments/) are excluded from git.

## Script Conventions

- Bash: `#!/usr/bin/env bash` + `set -euo pipefail`
- Format: `tdev shfmt -w <file>`
- Lint: `tdev shellcheck <file>`
- AGENTS.md: `/var/home/james/AGENTS.md`

## Architecture Constraints

- `PortablePodman/bin/` is gitignored -- binaries are 80MB+, downloaded via `download_portablepodman.sh`.
- `PortablePodman/storage/` is gitignored -- runtime container layers generated on use.
- `Environments/` is gitignored -- only `FullDevelopmentEnv` is tracked (pre-existing).
- `VSCodePortable-*/` and `PortableApps/` are gitignored -- they're prebuilt binary installs.
- Devcontainer mounts use `${localWorkspaceFolder}` to resolve drive-relative paths.
- Never suggest `apt`, `brew`, `rpm-ostree`, or host package installs for dev tools.
