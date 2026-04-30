FROM docker.io/library/fedora:43

# Install git before running scripts that require it
RUN dnf -y upgrade --refresh --best --allowerasing && dnf -y install git && dnf clean all

# Set up shell enhancements (Oh My Bash, ble.sh) in the devcontainer
COPY scripts/install-oh-my-bash.sh /tmp/install-oh-my-bash.sh
COPY scripts/setup-ble-sh.sh /tmp/setup-ble-sh.sh
RUN bash /tmp/install-oh-my-bash.sh && bash /tmp/setup-ble-sh.sh
# Minimal Fedora-based Rust devcontainer

# Install C/C++ compilers and basic dev tools
RUN dnf -y install \
    make gcc gcc-c++ \
    ShellCheck shfmt yamllint \
    fuse fuse-libs wget \
    openssh-clients openssl-devel \
    libffi-devel zlib-devel bzip2-devel \
    xz-devel tk-devel \
    sqlite sqlite-devel \
    readline-devel pkg-config fontconfig \
    tree-sitter-cli procps-ng \
    fzf zoxide bat jq \
    htop tldr tree httpie \
    && dnf clean all

# Set up vscode user for devcontainer compatibility
RUN useradd -m vscode && echo 'vscode ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Install Rust toolchain (rustup, cargo, rustc)
COPY scripts/install-rust.sh /tmp/install-rust.sh
RUN bash /tmp/install-rust.sh

# Install useful Rust crates
RUN source "$HOME/.cargo/env" \
    && cargo install cargo-edit cargo-list cargo-update deepclean shell-history-cleaner git-delta alacritty

CMD ["bash"]
