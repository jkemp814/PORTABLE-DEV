FROM docker.io/library/fedora:latest

RUN dnf install -y \
    bash \
    git \
    moby-engine \
    ShellCheck \
    shfmt \
    sudo \
    cmake \
    make \
    autoconf \
    automake \
    autogen \
    texinfo \
    libtool \
    bison \
    flex \
    gcc \
    gcc-c++ \
    wget \
    tar \
    which \
    curl \
    perl-Pod-Html \
    texi2html \
    nodejs \
    npm \
    && dnf clean all

# Install bashdb from source for matching Bash version
COPY scripts/install-bashdb.sh /tmp/install-bashdb.sh
RUN chmod +x /tmp/install-bashdb.sh && /tmp/install-bashdb.sh && rm /tmp/install-bashdb.sh

# Create a non-root user for VS Code
RUN useradd -m vscode \
    && echo 'vscode ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/vscode
USER vscode
