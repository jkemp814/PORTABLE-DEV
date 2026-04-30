# direnv Utility

direnv automates environment variable and virtual environment activation/deactivation for your projects.

## Usage

1. Install direnv (`dnf install direnv` or `brew install direnv`).
2. Add the following to your shell config (e.g., `.bashrc`, `.zshrc`):
    ```sh
    eval "$(direnv hook bash)"
    ```
3. In your project folder, create a `.envrc` file. For Python:
    ```sh
    layout python
    ```
4. Run `direnv allow` in the project folder.

Now, entering the directory will auto-activate your Python virtual environment, and exiting will deactivate it.

See `direnv.envrc.example` for a template.