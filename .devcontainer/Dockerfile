FROM docker.io/library/fedora:43

RUN dnf -y upgrade --refresh --best --allowerasing \
    && dnf -y install \
        git \
        make gcc gcc-c++ \
        ShellCheck shfmt yamllint \
        fuse fuse-libs wget curl \
        openssh-clients openssl-devel \
        libffi-devel zlib-devel bzip2-devel \
        xz-devel tk-devel \
        sqlite sqlite-devel \
        readline-devel pkg-config fontconfig \
        tree-sitter-cli procps-ng \
        fzf zoxide bat jq \
        htop tldr tree httpie \
        nodejs npm \
        sudo \
    && dnf clean all

RUN useradd -m vscode \
    && echo 'vscode ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/vscode

USER vscode
CMD ["bash"]
