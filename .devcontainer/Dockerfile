# Minimal Fedora-based Rust devcontainer for Codespaces
FROM fedora:43

# Install Rust toolchain, git, and basic build tools only
RUN dnf -y upgrade --refresh --best --allowerasing && dnf -y install \
    make gcc gcc-c++ git curl ca-certificates \
    && dnf clean all \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

ENV PATH="/root/.cargo/bin:${PATH}"

# Set up vscode user for devcontainer compatibility
RUN useradd -m vscode && echo 'vscode ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER vscode
WORKDIR /home/vscode

CMD ["bash"]
