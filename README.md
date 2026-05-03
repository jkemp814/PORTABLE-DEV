# Portable Development Environment

A cross-platform portable development environment supporting both **Linux and Windows**. This setup provides reproducible development environments with portable applications, dev containers, and organized development tools—all self-contained and runnable from external drives.

## Features

- **Cross-Platform Support**: Runs on Linux and Windows from portable storage
- **Portable Applications**: PortableFirefox, PortableChromium, KeePass, Calibre, and more included
- **Reference Library**: Technical manuals, programming language guides, and code references via calibrePortable
- **Development Environments**: Pre-configured setups for Python, Rust, C++, Bash, and full development stacks
- **Portable Git**: Self-contained Git installation
- **Portable VS Code**: Linux and Windows versions included
- **Dev Containers**: Podman/Docker/container support for isolated development
- **Projects Folder**: Centralized workspace for your code repositories

## Folder Structure

```text
PORTABLE-DEV/
├── Documents/               # Personal documents
├── Environments/            # Dev environment configurations
│   ├── BashDev/
│   ├── CppDev/
│   ├── PythonDev/
│   ├── RustDev/
│   └── FullDevelopmentEnv/
├── Projects/                # Your code repositories and projects
├── PortableApps/            # Self-contained applications
│   ├── FirefoxPortable/
│   ├── KeePassXCPortable/
│   ├── calibrePortable/     # Technical manuals, programming language guides, and code references
│   └── ClamWinPortable/
├── PortableGit/             # Self-contained Git installation
├── Toolchest/               # Scripts and utilities
├── VSCodePortable-Linux/    # VS Code for Linux
├── VSCodePortable-Windows/  # VS Code for Windows
├── PORTABLE-DEV.code-workspace
└── README.md
```

## Prerequisites

- **For Dev Containers**: Podman or Docker must be installed on the host machine
  - **Linux**: Install Podman or Docker via your package manager
  - **Windows**: Install Docker Desktop (includes Docker Engine)
  - **macOS**: Install Docker Desktop or Podman

## Getting Started

### Using on Linux

1. Open the workspace file in VS Code:

   ```bash
   code PORTABLE-DEV.code-workspace
   ```

2. Use the environment-specific setups in `Environments/`
3. Add your projects to the `Projects/` folder
4. Use Portable Git located in `PortableGit/bin/git`

### Using on Windows

1. Open the workspace file in VS Code Portable (Windows):

   ```bash
   VSCodePortable-Windows/bin/Code.exe PORTABLE-DEV.code-workspace
   ```

2. Use Portable Git for version control
3. Add your projects to the `Projects/` folder

### Working with Dev Containers

1. Configure your environment in `Environments/`
2. Set up `.devcontainer/devcontainer.json` with proper mounts
3. Use "Reopen in Container" in VS Code when ready

## Customization

- **Development Environments**: Each subfolder in `Environments/` contains environment-specific configurations
- **Dev Container Setup**: Edit or create `.devcontainer/devcontainer.json` in your environment to customize container mounts and tools
- **Portable Apps**: Install additional portable applications in the `PortableApps/` folder
- **Scripts**: Add helper scripts to `Toolchest/` for common tasks

## How This Setup Was Built

1. Prepare a portable drive layout and keep all tools/data at the drive root.
2. Install or extract cross-platform tools (VS Code, Git, and portable apps) into dedicated folders.
3. Create reusable development environments under `Environments/`.
4. Keep project repositories under `Projects/`.
5. Use Dev Containers for isolated toolchains, and mount `Projects/` from the host into the container.
6. Track infrastructure and documentation changes in git.

## References

- **VS Code Downloads (official)**: [https://code.visualstudio.com/Download](https://code.visualstudio.com/Download)
- **VS Code Dev Containers (official docs)**: [https://code.visualstudio.com/docs/devcontainers/containers](https://code.visualstudio.com/docs/devcontainers/containers)
- **Microsoft Dev Container samples**: [https://github.com/devcontainers/images/tree/main/src](https://github.com/devcontainers/images/tree/main/src)
- **PortableApps Platform**: [https://portableapps.com/download](https://portableapps.com/download)
- **PortableApps App Directory**: [https://portableapps.com/apps](https://portableapps.com/apps)
- **Git for Windows Downloads**: [https://git-scm.com/download/win](https://git-scm.com/download/win)
- **PortableGit Releases (Git for Windows)**: [https://github.com/git-for-windows/git/releases](https://github.com/git-for-windows/git/releases)

## Tips

- **Mount External Drives**: Use `devcontainer.json` mounts to access Projects folder from inside containers
- **Portability**: Keep all development tools and data on the external drive for use across computers
- **Version Control**: Each project in `Projects/` can be its own git repository
- **Cross-Platform Switching**: Use the same codebase on both Linux and Windows without duplication
- **Browser Option**: Side note: you can use either PortableFirefox or PortableChromium
- **Keep It Clean**: Use `.gitignore` to exclude build artifacts and temporary files

## License

Licensed under the MIT License. See [LICENSE](LICENSE).
