# Start with the base image
FROM fedora:43
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
    git clone --depth=1 https://github.com/LazyVim/starter /home/vscode/.config/nvim && \
    chown -R vscode:vscode /home/vscode/.config/nvim

# Install core development tools and languages
RUN dnf -y groupinstall "Development Tools" \
    && dnf -y install --best --allowerasing \
        # Python
        python3 python3-pip python3-virtualenv python3-devel \
        # Node.js
        nodejs nodejs-npm \
        # Java
        java-21-openjdk java-21-openjdk-devel maven \
        # Rust
        rust rust-analyzer \
        # C/C++
        cmake make ninja-build gdb lldb \
        # .NET
        dotnet-sdk-8.0 \
        # Ruby
        ruby ruby-devel \
        # Go
        golang \
        # Shell/Script tools
        shellcheck shfmt yamllint \
        # System/Dev tools
        fuse fuse-libs \
        clang clang-tools-extra \
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
        # CLI utilities
        fzf zoxide bat exa htop tldr tree httpie eva \
    && dnf clean all


# Python environment activation helpers and formatters/linters
RUN pip3 install --upgrade pip setuptools wheel \
    pynvim \
    black \
    flake8 \
    isort \
    pylint \
    mypy \
    pyyaml \
    toml \
    thefuck


# Node.js global tools
RUN npm install -g prettier eslint


# Rust tools
RUN cargo install --locked ripgrep fd-find

# Set up a non-root user for VS Code
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000
RUN useradd -m $USERNAME --uid $USER_UID --gid $USER_GID && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER $USERNAME
WORKDIR /workspace

# Entrypoint
CMD ["/bin/bash"]
