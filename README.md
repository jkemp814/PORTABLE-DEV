# FEDORA_DEV Portable Devcontainer

This repository contains a portable Fedora-based devcontainer setup for reproducible development environments. It includes scripts, configuration files, and instructions for setting up and using the devcontainer.

## Features

- Fedora 43 base image
- Preinstalled development tools: Python, Node.js, Java, Rust, Go, .NET, Ruby, and more
- Neovim (with LazyVim), lnav, lazygit, git-delta
- Python, Node.js, and Rust global tools
- User-friendly scripts and reusable configs
- Project folder for your code

## Folder Structure

```
FEDORA_DEV/
├── .devcontainer/
│   ├── Dockerfile
│   ├── devcontainer.json
│   ├── scripts/
│   │   └── activate_python_env.sh
│   └── configs/
├── projects/
├── .gitignore
└── README.md
```

## Getting Started

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/FEDORA_DEV.git
   cd FEDORA_DEV
   ```
2. Open in VS Code and "Reopen in Container" when prompted.
3. Add your projects to the `projects/` folder.
4. Use provided scripts and configs as needed.

## Customization

- Edit `.devcontainer/Dockerfile` to add or remove tools.
- Place reusable configs in `.devcontainer/configs/`.
- Add your own scripts to `.devcontainer/scripts/`.

## Tips

- Each project in `projects/` can be its own git repo.
- The Docker image is built from the Dockerfile and not tracked in git.
- Use `.gitignore` to keep your repo clean.

## License

MIT (or your preferred license)
