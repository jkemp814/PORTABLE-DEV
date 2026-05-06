# Portable Development Environment

[![GitHub stars](https://img.shields.io/github/stars/jkemp814/PORTABLE-DEV?style=social)](https://github.com/jkemp814/PORTABLE-DEV)
[![GitHub forks](https://img.shields.io/github/forks/jkemp814/PORTABLE-DEV?style=social)](https://github.com/jkemp814/PORTABLE-DEV/network/members)
[![GitHub issues](https://img.shields.io/github/issues/jkemp814/PORTABLE-DEV)](https://github.com/jkemp814/PORTABLE-DEV/issues)
[![Last Commit](https://img.shields.io/github/last-commit/jkemp814/PORTABLE-DEV)](https://github.com/jkemp814/PORTABLE-DEV/commits/main)
[![Languages](https://img.shields.io/github/languages/top/jkemp814/PORTABLE-DEV)](https://github.com/jkemp814/PORTABLE-DEV/search?l=Shell)

> **A cross-platform, plug-and-play coding environment you can carry anywhere.**  
> Compatible with **Linux**, **Windows**, containers, and VMs, all self-contained and ready to go from an external drive or any host.

---

## 🚩 Features

- **Cross-Platform:** Works on Linux & Windows (and with minor tweaks, macOS).
- **Portable Apps:** Includes portable versions of Firefox, Chromium, KeePass, Calibre, Git, VS Code, and more.
- **Reference Library:** Offline technical manuals, programming guides, and code references via Calibre.
- **Multiple Dev Stacks:** Pre-configured Python, Rust, C++, Bash, and full-stack environments.
- **Dev Containers:** Podman/Docker support for instant, isolated environments.
- **Central Projects Folder:** Single workspace for all your repos.
- **All-in-One:** Works off external drives—perfect for school, work, or travel.

---

## 📂 Folder Structure

```text
PORTABLE-DEV/
├── Documents/                  # Personal documents
├── Environments/               # Dev env configurations (Python, Rust, C++, Bash, etc.)
│   ├── BashDev/
│   ├── CppDev/
│   ├── PythonDev/
│   ├── RustDev/
│   └── FullDevelopmentEnv/
├── Projects/                   # All code repositories & projects
├── PortableApps/               # Standalone portable applications
│   ├── FirefoxPortable/
│   ├── KeePassXCPortable/
│   ├── calibrePortable/
│   └── ClamWinPortable/
├── PortableGit/                # Portable Git
├── Toolchest/                  # Helper scripts & utilities
├── VSCodePortable-Linux/       # VS Code Portable for Linux (+ data/)
├── VSCodePortable-Windows/     # VS Code Portable for Windows (+ data/)
├── PORTABLE-DEV.code-workspace # VS Code workspace file
└── README.md
```

_Tip: The `data/` subfolder for VS Code stores your settings and extensions, keeping your IDE portable and personalized._

---

## 🛠️ Prerequisites

- **Linux:** Podman (recommended) or Docker installed on the host
- **Windows:** Docker Desktop or [Podman for Windows](https://podman.io/getting-started/installation)
- **macOS:** Docker Desktop or Podman (some features may require adaptation)
- **External or Portable Storage:** For maximum portability

---

## 🚀 Getting Started

### On Linux

```bash
./VSCodePortable-Linux/bin/code PORTABLE-DEV.code-workspace
```

- Use the provided configs in `Environments/`
- Keep your repositories in `Projects/`
- VS Code and Git = portable, ready-to-go

### On Windows

```powershell
VSCodePortable-Windows/bin/Code.exe PORTABLE-DEV.code-workspace
```

- Use `PortableGit` for version control
- Your projects and tools are all set up under one roof

### Dev Containers (Optional, recommended for isolation)

1. Configure environments in `Environments/`
2. Use or edit `.devcontainer/devcontainer.json`
3. In VS Code, "Reopen in Container"

---

## ⚙️ Customization

- **Environments:** Tweak configs per language/stack in `Environments/`
- **Dev Containers:** Update `.devcontainer/devcontainer.json` as needed
- **Portable Apps:** Add more apps to `PortableApps/`
- **Scripts:** Your helper scripts go in `Toolchest/`

---

## 📚 Reference & Resources

- [VS Code Portable Mode](https://code.visualstudio.com/docs/editor/portable)
- [Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)
- [PortableApps Directory](https://portableapps.com/apps)
- [PortableGit](https://github.com/git-for-windows/git/releases)
- [Podman](https://podman.io/getting-started/installation)
- [Docker](https://www.docker.com/get-started/)

---

## 💡 Tips

- **Portability:** Run everything off a USB SSD, NVMe, or portable drive for true plug-and-code freedom.
- **Mount Drives:** With dev containers, use mounts for `Projects/` as your codespace.
- **Version Control:** Each project in `Projects/` can be its own Git repo, managed with PortableGit.
- **Cross-Platform:** Use the same workspace and codebase on both Windows & Linux without duplication.
- **Keep It Clean:** Use `.gitignore` wisely for build artifacts and temp files.

---

## 🤝 Contributing

PRs and suggestions are welcome!  
Please open issues or pull requests as you improve or adapt the project for more platforms or stacks.

---

## 📄 License

Licensed under the [MIT License](LICENSE).

---

**Happy Coding—Anywhere, Anytime!**
