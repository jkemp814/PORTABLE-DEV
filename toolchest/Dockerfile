# Minimal Fedora-based Rust devcontainer
FROM fedora:43

# Install Rust toolchain, C/C++ compilers, and basic dev tools
RUN dnf -y upgrade --refresh --best --allowerasing && dnf -y install \
	make gcc gcc-c++ \
	shellcheck shfmt yamllint \
	curl fuse fuse-libs git wget \
	openssh-clients openssl-devel ca-certificates \
	libffi-devel zlib-devel bzip2-devel \
	xz-devel tk-devel \
	sqlite sqlite-devel \
	readline-devel pkg-config fontconfig \
	tree-sitter-cli procps-ng \
	fzf zoxide bat jq \
	htop tldr tree httpie \
	&& dnf clean all \
	&& curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

ENV PATH="/root/.cargo/bin:${PATH}"

# Set up vscode user for devcontainer compatibility
RUN useradd -m vscode && echo 'vscode ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Install Oh My Bash and Bash Line Editor (ble.sh) for vscode user
USER vscode
WORKDIR /home/vscode
RUN bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" \
	&& git clone --recursive https://github.com/akinomyoga/ble.sh.git ~/ble.sh \
	&& bash ~/ble.sh/install.sh

CMD ["bash"]
