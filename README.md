# Portable Development Environment

[![GitHub stars](https://img.shields.io/github/stars/jkemp814/PORTABLE-DEV?style=social)](https://github.com/jkemp814/PORTABLE-DEV)
[![GitHub forks](https://img.shields.io/github/forks/jkemp814/PORTABLE-DEV?style=social)](https://github.com/jkemp814/PORTABLE-DEV/network/members)
[![GitHub issues](https://img.shields.io/github/issues/jkemp814/PORTABLE-DEV)](https://github.com/jkemp814/PORTABLE-DEV/issues)
[![Last Commit](https://img.shields.io/github/last-commit/jkemp814/PORTABLE-DEV)](https://github.com/jkemp814/PORTABLE-DEV/commits/main)
[![Languages](https://img.shields.io/github/languages/top/jkemp814/PORTABLE-DEV)](https://github.com/jkemp814/PORTABLE-DEV/search?l=Shell)

> A cross-platform, plug-and-play coding environment you can carry anywhere.
> Compatible with Linux, Windows, containers, and VMs -- all self-contained and ready to go from an external drive or any host.

---

## Features

- **Self-Contained or BYO Runtime:** Bundles its own `PortablePodman` with static binaries for zero-dependency launch, or use your host's existing Podman/Docker.
- **Cross-Platform:** Works on Linux and Windows (and with minor tweaks, macOS).
- **Portable Apps:** Includes portable versions of Firefox, Chromium, KeePassXC, Calibre, Git, VS Code, and more.
- **Reference Library:** Offline technical manuals, programming guides, and code references via Calibre.
- **Multiple Dev Stacks:** Pre-configured Python, Rust, C++, Bash, and full-stack environments.
- **Dev Containers:** Podman/Docker support for instant, isolated environments.
- **Deep Isolation:** All container images, caching layers, and configurations write to the drive, not the host (`~/.local/share/containers`, etc.).
- **Central Projects Folder:** Single workspace for all your repos.
- **Dynamic Mount Point Tracking:** Launch scripts auto-detect the drive's active mount path and rewrite configurations on the fly.
- **100% Unprivileged:** Uses rootless static binaries and `fuse-overlayfs` -- no `sudo` or admin rights needed.
- **All-in-One:** Works off external drives -- perfect for school, work, or travel.

---

## Folder Structure

```text
PORTABLE-DEV/
├── Documents/                   # Personal documents
├── Environments/                # Dev env configurations per language
│   ├── BashDev/
│   ├── CppDev/
│   ├── PythonDev/
│   ├── RustDev/
│   └── FullDevelopmentEnv/
├── PortableApps/                # Standalone portable applications
│   ├── FirefoxPortable/
│   ├── KeePassXCPortable/
│   ├── calibrePortable/
│   ├── ClamWinPortable/
│   ├── StellariumPortable/
│   └── PortableApps.com/
├── PortableGit/                 # Portable Git for Windows
├── PortablePodman/              # Self-contained container runtime
│   ├── bin/                     # Static podman + fuse-overlayfs binaries
│   ├── config/                  # Auto-managed storage paths
│   └── storage/                 # Container layers trapped on the drive
├── Projects/                    # All code repositories and projects
│   ├── BashDev/
│   ├── CppDev/
│   ├── PythonDev/
│   ├── RustDev/
│   └── FullDevelopmentEnv/
├── Scripts/                     # Shared helper scripts (binds to /Scripts)
├── Temp/                        # Temporary build artifacts
├── Toolchest/                   # Setup utilities, configs, fonts
│   ├── Configs/
│   ├── Fonts/
│   └── VSCode/
├── VSCodePortable-Linux/        # VS Code Portable for Linux (+ data/)
├── VSCodePortable-Windows/      # VS Code Portable for Windows (+ data/)
├── start-env.sh                 # Linux initialization wrapper
├── start-env.bat                # Windows initialization wrapper
├── PORTABLE-DEV.code-workspace  # VS Code workspace file
├── README.md
└── LICENSE
```

The `data/` subfolder for VS Code stores your settings and extensions, keeping your IDE portable and personalized.

---

## Prerequisites

- **Self-Contained Mode (Recommended):** No host prerequisites. Place static `podman` and `fuse-overlayfs` binaries in `PortablePodman/bin/`.
- **Linux (BYO Runtime):** Podman (recommended) or Docker installed on the host.
- **Windows:** Docker Desktop or [Podman for Windows](https://podman.io/getting-started/installation) (with WSL2 enabled).
- **macOS:** Docker Desktop or Podman (some features may require adaptation).
- **External or Portable Storage:** USB SSD, NVMe, or portable drive for true plug-and-code freedom.

---

## Quick Start

### Self-Contained Mode (No Host Prerequisites)

1. Insert your drive into any Linux or Windows workstation.
2. Place the static `podman` and `fuse-overlayfs` binaries into `PortablePodman/bin/`.

#### Linux (Self-Contained)

```bash
chmod +x start-env.sh
./start-env.sh
```

The launcher auto-detects the drive mount path, configures `PortablePodman`, and opens VS Code in the workspace. Click "Reopen in Container" when prompted.

#### Windows (Self-Contained)

Double-click `start-env.bat`. VS Code initializes, hooks into the drive's portable engine via WSL, and loads your workspace container.

### BYO Runtime Mode (Host Podman/Docker)

#### Linux (BYO)

```bash
./VSCodePortable-Linux/bin/code PORTABLE-DEV.code-workspace
```

Use the configs in `Environments/` and keep your repos in `Projects/`.

#### Windows (BYO)

```powershell
VSCodePortable-Windows/bin/Code.exe PORTABLE-DEV.code-workspace
```

Use `PortableGit` for version control.

### Dev Containers (Isolated Environments)

1. Navigate to the environment in `Environments/` (e.g. `Environments/PythonDev/`).
2. Open that folder in VS Code and run "Reopen in Container".

---

## Customization

- **Environments:** Tweak configs per language/stack in `Environments/`.
- **Dev Containers:** Update the devcontainer config under the relevant `Environments/*/.devcontainer/`.
- **Portable Apps:** Add more apps to `PortableApps/`.
- **Scripts:** Helper scripts go in `Scripts/` or `Toolchest/`.

---

## Reference and Resources

- [VS Code Portable Mode](https://code.visualstudio.com/docs/editor/portable)
- [Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)
- [PortableApps Directory](https://portableapps.com/apps)
- [PortableGit](https://github.com/git-for-windows/git/releases)
- [Podman](https://podman.io/getting-started/installation)
- [Docker](https://www.docker.com/get-started/)

---

## Tips

- **Portability:** Run everything off a USB SSD, NVMe, or portable drive for true plug-and-code freedom.
- **Mount Drives:** With dev containers, use mounts for `Projects/` and `Scripts/` as your codespace.
- **Version Control:** Each project in `Projects/` can be its own Git repo, managed with `PortableGit`.
- **Cross-Platform:** Use the same workspace and codebase on both Windows and Linux without duplication.
- **Keep It Clean:** Use `.gitignore` wisely for build artifacts and temp files.
- **Zero Pollution:** `PortablePodman/storage/` keeps all container layers on the drive -- no traces left on the host.

---

## Contributing

PRs and suggestions are welcome.
Please open issues or pull requests as you improve or adapt the project for more platforms or stacks.

---

## License

Licensed under the [MIT License](LICENSE).

---

**Happy Coding -- Anywhere, Anytime!**
