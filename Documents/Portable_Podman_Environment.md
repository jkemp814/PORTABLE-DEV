# Portable Podman Environment

A plug-and-play, cross-platform developer workspace engineered to run entirely off a flash drive. Bundles its own unprivileged, rootless Podman engine and portable VS Code, requiring no `sudo` or host package installations.

---

## Directory Layout

```text
PORTABLE-DEV/
├── .devcontainer/
│   ├── devcontainer.json
│   └── Dockerfile
├── scripts/
│   └── install-bashdb.sh
├── Projects/
├── Scripts/
├── PortablePodman/
│   ├── bin/
│   ├── config/
│   └── storage/
│       ├── root/
│       └── run/
├── VSCodePortable-Linux/
├── VSCodePortable-Win/
├── start-env.sh
└── start-env.bat
```

---

## Step 1: Download Static Binaries

Do **not** compile Podman from source — the resulting dynamic binaries will break on different library versions. Use pre-compiled zero-dependency static releases instead.

### Container Engine

1. Download the latest `podman-linux-amd64.tar.gz` from [mgoltzsche/podman-static](https://github.com/mgoltzsche/podman-static/releases)
2. Extract and copy into `PortablePodman/bin/`:
    - `podman`
    - `crun`
    - `conmon`
    - `netavark`
    - `aardvark-dns`

### Unprivileged File Overlay

1. Download the static `fuse-overlayfs` binary from [containers/fuse-overlayfs](https://github.com/containers/fuse-overlayfs/releases)
2. Copy into `PortablePodman/bin/`

### Automated Download

```bash
DRIVE_DIR="/run/media/james/PORTABLE-DEV"

mkdir -p "$DRIVE_DIR/PortablePodman/bin" /tmp/podman-extract
cd /tmp/podman-extract

curl -fsSL -o podman-static.tar.gz \
  https://github.com/mgoltzsche/podman-static/releases/latest/download/podman-linux-amd64.tar.gz
tar -xzf podman-static.tar.gz

cp podman-linux-amd64/usr/bin/podman     "$DRIVE_DIR/PortablePodman/bin/"
cp podman-linux-amd64/usr/bin/crun       "$DRIVE_DIR/PortablePodman/bin/"
cp podman-linux-amd64/usr/bin/conmon     "$DRIVE_DIR/PortablePodman/bin/"
cp podman-linux-amd64/usr/libexec/podman/netavark     "$DRIVE_DIR/PortablePodman/bin/"
cp podman-linux-amd64/usr/libexec/podman/aardvark-dns "$DRIVE_DIR/PortablePodman/bin/"
cp podman-linux-amd64/usr/bin/fuse-overlayfs "$DRIVE_DIR/PortablePodman/bin/"

cd ~ && rm -rf /tmp/podman-extract
```

---

## Step 2: Linux Launcher (`start-env.sh`)

Auto-detects the mount path, generates `storage.conf`, and launches VS Code with Podman overrides.

```bash
#!/usr/bin/env bash
set -euo pipefail

DRIVE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORTABLE_ROOT="$DRIVE_DIR/PortablePodman/storage/root"
PORTABLE_RUN="$DRIVE_DIR/PortablePodman/storage/run"
FUSE_BIN="$DRIVE_DIR/PortablePodman/bin/fuse-overlayfs"

mkdir -p "$PORTABLE_ROOT" "$PORTABLE_RUN" "$DRIVE_DIR/PortablePodman/config"

cat << EOF > "$DRIVE_DIR/PortablePodman/config/storage.conf"
[storage]
driver = "overlay"
graphroot = "$PORTABLE_ROOT"
runroot = "$PORTABLE_RUN"

[storage.options.overlay]
mount_program = "$FUSE_BIN"
EOF

export CONTAINERS_STORAGE_CONF="$DRIVE_DIR/PortablePodman/config/storage.conf"
export PATH="$DRIVE_DIR/PortablePodman/bin:$PATH"

exec "$DRIVE_DIR/VSCodePortable-Linux/bin/code" \
    --user-data-dir "$DRIVE_DIR/VSCodePortable-Linux/data" \
    --extensions-dir "$DRIVE_DIR/VSCodePortable-Linux/extensions" \
    --set "devContainers.dockerPath=$DRIVE_DIR/PortablePodman/bin/podman" \
    "$DRIVE_DIR/PORTABLE-DEV.code-workspace"
```

### Optional: `--refresh` Flag for Sync Mode

Insert this block after the `export PATH` line and before the `exec` line:

```bash
if [ "${1:-}" = "--refresh" ]; then
    echo "Internet Sync Mode: rebuilding offline developer layer..."
    podman build --no-cache -t fedora-bash-dev \
        -f "$DRIVE_DIR/.devcontainer/Dockerfile" "$DRIVE_DIR/.devcontainer"
    echo "Sync complete. Drive is updated for offline use."
    exit 0
fi
```

---

## Step 3: Windows Launcher (`start-env.bat`)

Leverages WSL to run the Linux Podman binary. Converts Windows drive paths to WSL `/mnt/` paths.

```bat
@echo off
SETLOCAL EnableExtensions EnableDelayedExpansion

:: 1. Determine drive letter
set "DRIVE_DIR=%~dp0"
if "%DRIVE_DIR:~-1%"=="\" set "DRIVE_DIR=%DRIVE_DIR:~0,-1%"

:: 2. Convert to WSL mount path (e.g. E:\PORTABLE-DEV -> /mnt/e/PORTABLE-DEV)
set "LETTER=%DRIVE_DIR:~0,1%"
for %%L in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do (
    if /I "!LETTER!"=="%%L" set "WSL_LETTER=%%L"
)
set "REMAINDER=%DRIVE_DIR:~2%"
set "REMAINDER=%REMAINDER:\=/%"
set "WSL_DRIVE_DIR=/mnt/%WSL_LETTER%%REMAINDER%"

:: 3. Define paths
set "PORTABLE_ROOT=%WSL_DRIVE_DIR%/PortablePodman/storage/root"
set "PORTABLE_RUN=%WSL_DRIVE_DIR%/PortablePodman/storage/run"
set "FUSE_BIN=%WSL_DRIVE_DIR%/PortablePodman/bin/fuse-overlayfs"

if not exist "%DRIVE_DIR%\PortablePodman\storage\root" mkdir "%DRIVE_DIR%\PortablePodman\storage\root"
if not exist "%DRIVE_DIR%\PortablePodman\storage\run" mkdir "%DRIVE_DIR%\PortablePodman\storage\run"
if not exist "%DRIVE_DIR%\PortablePodman\config" mkdir "%DRIVE_DIR%\PortablePodman\config"

:: 4. Generate storage.conf
(
echo [storage]
echo driver = "overlay"
echo graphroot = "%PORTABLE_ROOT%"
echo runroot = "%PORTABLE_RUN%"
echo.
echo [storage.options.overlay]
echo mount_program = "%FUSE_BIN%"
) > "%DRIVE_DIR%\PortablePodman\config\storage.conf"

:: 5. Set environment for WSL
set "CONTAINERS_STORAGE_CONF=%WSL_DRIVE_DIR%/PortablePodman/config/storage.conf"
set "PATH=%WSL_DRIVE_DIR%/PortablePodman/bin;%PATH%"

:: 6. Launch VS Code Portable
if exist "%DRIVE_DIR%\VSCodePortable-Win\Code.exe" (
    start /wait "" "%DRIVE_DIR%\VSCodePortable-Win\Code.exe" ^
        --user-data-dir "%DRIVE_DIR%\VSCodePortable-Win\data" ^
        --extensions-dir "%DRIVE_DIR%\VSCodePortable-Win\extensions" ^
        --set "devContainers.dockerPath=%WSL_DRIVE_DIR%/PortablePodman/bin/podman" ^
        "%DRIVE_DIR%\PORTABLE-DEV.code-workspace"

    :: 7. Cleanup WSL cache after VS Code closes
    echo [INFO] Purging host container runtime environment...
    wsl run rm -rf ~/.config/containers/ 2>nul
    wsl --shutdown
    echo [SUCCESS] Environment detached from host.
) else (
    echo [ERROR] VSCodePortable-Win\Code.exe not found.
    pause
)

ENDLOCAL
```

---

## Step 4: Portable `devcontainer.json`

Strips host-specific bindings (`${localEnv:HOME}`) and maps everything relative to the USB workspace.

```json
{
  "name": "Fedora Bash Dev",
  "build": {
    "dockerfile": "Dockerfile",
    "context": ".."
  },
  "mounts": [
    "source=${localWorkspaceFolder}/Projects,target=/Projects,type=bind",
    "source=${localWorkspaceFolder}/Scripts,target=/Scripts,type=bind",
    "source=/run/user/${localEnv:UID}/podman/podman.sock,target=/var/run/docker.sock,type=bind"
  ],
  "remoteEnv": {
    "DOCKER_HOST": "unix:///var/run/docker.sock"
  },
  "postCreateCommand": "shellcheck --version && shfmt --version",
  "postStartCommand": "sudo chmod 666 /var/run/docker.sock || true",
  "customizations": {
    "vscode": {
      "settings": {
        "devContainers.dockerPath": "${localWorkspaceFolder}/PortablePodman/bin/podman",
        "files.associations": {
          "*.sh": "shellscript"
        },
        "editor.formatOnSave": true,
        "[shellscript]": {
          "editor.defaultFormatter": "foxundermoon.shell-format"
        },
        "cSpell.words": ["foxundermoon"]
      },
      "extensions": [
        "timonwong.shellcheck",
        "foxundermoon.shell-format",
        "rogalmic.bash-debug"
      ]
    }
  },
  "remoteUser": "vscode"
}
```

---

## Step 5: `Dockerfile`

```dockerfile
FROM docker.io/library/fedora:latest

RUN dnf install -y \
    bash git podman ShellCheck shfmt sudo \
    cmake make autoconf automake autogen texinfo libtool \
    bison flex gcc gcc-c++ wget tar which curl \
    perl-Pod-Html texi2html nodejs npm \
    && dnf clean all

COPY scripts/install-bashdb.sh /tmp/install-bashdb.sh
RUN chmod +x /tmp/install-bashdb.sh && /tmp/install-bashdb.sh && rm /tmp/install-bashdb.sh

RUN useradd -m vscode \
    && echo 'vscode ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/vscode
USER vscode
```

---

## Isolation & Cleanup

| Resource                         | Fate on Drive Removal                                                    |
| -------------------------------- | ------------------------------------------------------------------------ |
| Container images, layers, config | Written to `PortablePodman/storage/` on the USB — no host trace          |
| Linux runtime namespaces         | Dissolved automatically when VS Code closes                              |
| WSL cache (Windows)              | Cleaned by `wsl run rm -rf ~/.config/containers/` and `wsl --shutdown`   |
| VS Code user data/extensions     | Stored in `VSCodePortable-Linux/data` / `VSCodePortable-Win/data` on USB |
