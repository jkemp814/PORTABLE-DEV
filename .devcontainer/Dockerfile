# Fedora 43 base image
FROM fedora:43

# --- Core development tools ---
RUN dnf -y groupinstall "Development Tools" \
    # --- Languages ---
    && dnf -y install --best --allowerasing \
        python3 python3-pip python3-virtualenv python3-devel \
        nodejs nodejs-npm \
        java-21-openjdk java-21-openjdk-devel maven \
        rust rust-analyzer \
        dotnet-sdk-8.0 \
        ruby ruby-devel \
        golang \
    # --- C/C++ ---
        cmake make ninja-build gdb lldb clang clang-tools-extra \
    # --- Linters / Formatters ---
        shellcheck shfmt yamllint \
    # --- System/Dev tools ---
        fuse fuse-libs \
        jq \
        openssh-clients \
        uv \
        helm \
        mkcert \
        direnv \
        libffi-devel \
        zlib-devel \
        bzip2-devel \
        xz-devel \
        sqlite sqlite-devel \
        readline-devel \
        tk-devel \
        pkg-config \
        openssl-devel \
        fontconfig \
        redis \
        nginx \
        tree-sitter-cli \
        ca-certificates \
    # --- CLI utilities ---
        fzf zoxide bat exa htop tldr tree httpie eva \
    && dnf clean all

# Install latest Neovim AppImage
RUN mkdir -p /opt/appimages && \
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage && \
    chmod u+x nvim.appimage && \
    mv nvim.appimage /opt/appimages/neovim && \
    ln -sf /opt/appimages/neovim /usr/local/bin/nvim

# Install latest lnav linux-musl-x86_64 binary
RUN LNAV_URL=$(curl -s https://api.github.com/repos/tstack/lnav/releases/latest \
    | grep browser_download_url \
    | grep linux-musl-x86_64 \
    | cut -d '"' -f 4) \
    && curl -LO "$LNAV_URL" \
    && chmod u+x lnav-*-linux-musl-x86_64 \
    && mv lnav-*-linux-musl-x86_64 /usr/local/bin/lnav

# Install latest lazygit binary
RUN LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep 'tag_name' | cut -d '"' -f 4 | tr -d 'v') && \
    curl -LO https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz && \
    tar -xzf lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz lazygit && \
    mv lazygit /usr/local/bin/lazygit && \
    rm lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz

# Install git-delta from Fedora repo (latest available)
RUN dnf -y install git-delta --best --allowerasing && dnf clean all

# Install LazyVim starter config for Neovim
RUN mkdir -p /home/vscode/.config/nvim && \
    # Backup existing nvim config/data/state/cache if they exist
    [ -d /home/vscode/.config/nvim ] && mv /home/vscode/.config/nvim /home/vscode/.config/nvim.bak || true && \
    [ -d /home/vscode/.local/share/nvim ] && mv /home/vscode/.local/share/nvim /home/vscode/.local/share/nvim.bak || true && \
    [ -d /home/vscode/.local/state/nvim ] && mv /home/vscode/.local/state/nvim /home/vscode/.local/state/nvim.bak || true && \
    [ -d /home/vscode/.cache/nvim ] && mv /home/vscode/.cache/nvim /home/vscode/.cache/nvim.bak || true && \
    # Clone LazyVim starter and remove .git
    git clone --depth=1 https://github.com/LazyVim/starter /home/vscode/.config/nvim && \
    rm -rf /home/vscode/.config/nvim/.git && \
    chown -R vscode:vscode /home/vscode/.config/nvim

# Python environment activation helpers and formatters/linters
RUN python3 -m ensurepip --upgrade && \
    python3 -m pip install --upgrade pip && \
    pip3 install --upgrade setuptools wheel \
    pynvim \
    black \
    flake8 \
    isort \
    pylint \
    mypy \
    pyyaml \
    toml \
    thefuck \
    glances \
    pip-search-ex \
    nvidia-ml-py \
    fastapi \
    uvicorn

# Node.js global tools
RUN npm install -g prettier eslint

# Rust tools
RUN cargo install --locked cargo-edit cargo-list cargo-update deepclean ripgrep fd-find shell-history-cleaner zellij zoxide
