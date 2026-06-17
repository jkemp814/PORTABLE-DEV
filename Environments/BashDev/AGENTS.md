# AGENTS

Purpose: Help coding agents become productive quickly in this repo.

## Project Snapshot

- Container-first Bash development environment for Windows + WSL2 + Docker Desktop.
- Primary work areas:
  - `.devcontainer/` for runtime and tooling setup
  - `scripts/` for host/container setup automation
  - `.vscode/` for local editor behavior and runnable tasks

## First Steps For Agents

1. Read `.devcontainer/devcontainer.json` for container lifecycle commands and extension/tool expectations.
2. Read `.devcontainer/Dockerfile` for installed dependencies and image-level behavior.
3. Read `.vscode/tasks.json` and prefer existing tasks before inventing new commands.
4. Read `scripts/fix-devcontainer-mount.ps1` before changing any Windows mount behavior.

## Preferred Commands

- Mount diagnostics only (default task):
  - `Devcontainer: Check mount only`
- Full mount fix workflow:
  - `Devcontainer: Fix D drive mount`

When a task exists, run the task instead of ad hoc shell commands.

## Environment Constraints And Pitfalls

- Most frequent failure mode is Windows drive sharing/mount issues for non-C drives.
- `scripts/fix-devcontainer-mount.ps1` intentionally uses a temporary `alpine:3.20` container for diagnostics; this is expected behavior.
- Devcontainer runs as non-root user `vscode`.
- Docker socket permissions are adjusted in `postStartCommand`; avoid removing this unless replacing it with an equivalent.

## Script Conventions

- Bash scripts should use strict mode unless there is a strong reason not to:
  - `set -euo pipefail`
- Keep shell formatting compatible with workspace settings:
  - formatter: `foxundermoon.shell-format`
  - format flags: `-i 4 -ci`
- ShellCheck is enabled and expected to pass for touched shell files.

## Change Guidance

- Keep edits minimal and targeted.
- Do not duplicate long documentation in instructions files; link to source files.
- For new workflow automation, prefer:
  1. update `.vscode/tasks.json` for repeatable operations
  2. update scripts under `scripts/` for reusable logic
  3. keep container boot commands in `.devcontainer/devcontainer.json` concise

## Quick File Map

- Container config: `.devcontainer/devcontainer.json`
- Container image/toolchain: `.devcontainer/Dockerfile`
- VS Code tasks: `.vscode/tasks.json`
- VS Code shell formatting/debug settings: `.vscode/settings.json`
- Mount diagnostics and remediation: `scripts/fix-devcontainer-mount.ps1`
- bashdb installer: `scripts/install-bashdb.sh`
