#!/usr/bin/env bash
# Install bashdb from Trepan-Debuggers GitHub (bash-5.3 branch) in Fedora toolbox

# Install required build tools
sudo dnf install -y git make gcc automake autoconf gcc-c++ kernel-devel texinfo

# Clone the bashdb repo and checkout the bash-5.3 branch
git clone --branch bash-5.3 https://github.com/Trepan-Debuggers/bashdb.git
cd bashdb || exit 1

# Build and install
./autogen.sh
./configure
make
sudo make install

echo "bashdb installed from Trepan-Debuggers/bash-5.3 branch."
