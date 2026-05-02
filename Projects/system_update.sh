#!/bin/bash
set -uo pipefail

# Source helper functions if available
HELPERS="$(dirname "$0")/common.sh"
if [ -f "$HELPERS" ]; then
	# shellcheck source=common.sh
	. "$HELPERS"
else
	echo "[WARN] common.sh not found, make sure all helper functions are defined!" >&2
fi

# Pre-flight check for required commands
REQUIRED_CMDS=(curl grep sed basename mktemp tar find file mv chmod unzip rustup npm python pip git fwupdmgr flatpak toolbox direnv)
MISSING_CMDS=()
for cmd in "${REQUIRED_CMDS[@]}"; do
	if ! command -v "$cmd" >/dev/null 2>&1; then
		MISSING_CMDS+=("$cmd")
	fi
done
if [ ${#MISSING_CMDS[@]} -ne 0 ]; then
	echo "[ERROR] Missing required commands: ${MISSING_CMDS[*]}" >&2
	echo "Please install the missing commands and re-run the script." >&2
	exit 1
fi

# Dry-run mode
DRY_RUN=0
for arg in "$@"; do
	if [[ "$arg" == "--dry-run" ]]; then
		DRY_RUN=1
		info "Running in dry-run mode: no changes will be made."
	fi
done

# Logging setup
LOG_DIR="$HOME/Scripts/UPDATE/logs"
if [[ $DRY_RUN -eq 0 ]]; then
	mkdir -p "$LOG_DIR"
	HOSTNAME=$(hostname)
	LOG_FILE="$LOG_DIR/update_${HOSTNAME}_$(date +%Y%m%d_%H%M%S).log"
	exec > >(tee -a "$LOG_FILE") 2>&1
fi

# Helper function for safe curl downloads
get_latest_github_asset_url() {
    # Usage: get_latest_github_asset_url <repo> <pattern>
    local repo="$1"
    local pattern="$2"
    local api_url="https://api.github.com/repos/$repo/releases/latest"
    local asset_url
    asset_url=$(curl -sf "$api_url" | grep -oE '"browser_download_url": "[^"]+' | cut -d '"' -f4 | grep "$pattern" | head -n1)
    echo "$asset_url"
}

update_github_cli() {
    headline "== GitHub CLI (gh) Updater =="
    GH_VERSION=$(curl -sf https://api.github.com/repos/cli/cli/releases/latest | grep -Po '"tag_name": "v\\K[0-9.]+' )
    if [[ -z "$GH_VERSION" ]]; then
        error "Failed to fetch latest GitHub CLI version."
        return 1
    fi
    info "Latest GitHub CLI version: $GH_VERSION"
    # Optionally, add logic to download and install the latest gh here
    # For now, just print the version
    return 0
}

update_appimages() {
	headline "== AppImage and Binary Downloader/Updater =="
	CONFIG_FILE="$(dirname "$0")/appimage_sources.conf"
	DOWNLOAD_DIR="$HOME/AppImages"
	SANDBOX_DIR="$HOME/Sandbox"
	BIN_DIR="$HOME/bin"
	LOCAL_BIN_DIR="$HOME/.local/bin"
	mkdir -p "$DOWNLOAD_DIR" "$SANDBOX_DIR" "$BIN_DIR" "$LOCAL_BIN_DIR"
	# Define placement rules
	BIN_TO_LOCAL=(uv helm mkcert gh tgpt direnv)
	BIN_TO_BIN=(crc odo)
	if [ -f "$CONFIG_FILE" ]; then
		while read -r name url; do
			[[ "$name" =~ ^#.*$ || -z "$name" ]] && continue
			info "Updating $name from $url"
			# Detect GitHub release URLs
			if [[ "$url" =~ github.com/.+/.+/releases ]]; then
				repo=$(echo "$url" | sed -n 's|https://github.com/\([^/]*\)/\([^/]*\)/releases.*|\1/\2|p')
				pattern=$(basename "$url" | sed 's/latest/download\///')
				asset_url=$(get_latest_github_asset_url "$repo" "$pattern")
				if [ -z "$asset_url" ]; then
					error "Could not find asset for $name matching $pattern in $repo"
					continue
				fi
				url="$asset_url"
			fi
			dest="$SANDBOX_DIR/$name"
			case "$url" in
				*.appimage|*.AppImage)
					dest="$DOWNLOAD_DIR/$name.appimage"
					if ! safe_curl "$url" "$dest" "$name"; then
						continue
					fi
					chmod +x "$dest"
					success "$name AppImage updated."
					;;
				*.tar.gz|*.tgz)
					tmpdir=$(mktemp -d)
					if ! safe_curl "$url" "$tmpdir/$name.tar.gz" "$name"; then
						rm -rf "$tmpdir"
						continue
					fi
					if [[ $DRY_RUN -eq 1 ]]; then
						info "[dry-run] Would extract $tmpdir/$name.tar.gz and move binary to $dest"
						rm -rf "$tmpdir"
						continue
					fi
					tar -xzf "$tmpdir/$name.tar.gz" -C "$tmpdir"
					exe=$(find "$tmpdir" -type f -executable -name "$name" -o -name "$name-amd64" | head -n 1)
					if [ -n "$exe" ]; then
						if ! file "$exe" | grep -q 'executable'; then
							warn "$name binary extracted but appears corrupt or not executable. Skipping."
							rm -rf "$tmpdir"
							continue
						fi
						mv "$exe" "$dest"
						chmod +x "$dest"
						success "$name extracted and updated."
					else
						warn "Could not find main binary for $name in archive."
					fi
					rm -rf "$tmpdir"
					;;
				*.zip)
					tmpdir=$(mktemp -d)
					if ! safe_curl "$url" "$tmpdir/$name.zip" "$name"; then
						rm -rf "$tmpdir"
						continue
					fi
					unzip -o "$tmpdir/$name.zip" -d "$tmpdir"
					exe=$(find "$tmpdir" -type f -executable -name "$name" | head -n 1)
					if [ -n "$exe" ]; then
						mv "$exe" "$dest"
						chmod +x "$dest"
						success "$name extracted and updated."
					else
						warn "Could not find main binary for $name in zip."
					fi
					rm -rf "$tmpdir"
					;;
				*)
					if ! safe_curl "$url" "$dest" "$name"; then
						continue
					fi
					chmod +x "$dest"
					success "$name binary updated."
					;;
			esac
			# Placement logic
			for b in "${BIN_TO_LOCAL[@]}"; do
				if [[ "$name" == "$b" ]]; then
					mv -f "$dest" "$LOCAL_BIN_DIR/$name"
					chmod +x "$LOCAL_BIN_DIR/$name"
					success "$name moved to $LOCAL_BIN_DIR/$name"
					dest="$LOCAL_BIN_DIR/$name"
				fi
			done
			for b in "${BIN_TO_BIN[@]}"; do
				if [[ "$name" == "$b" ]]; then
					mv -f "$dest" "$BIN_DIR/$name"
					chmod +x "$BIN_DIR/$name"
					success "$name moved to $BIN_DIR/$name"
					dest="$BIN_DIR/$name"
				fi
			done
		done < "$CONFIG_FILE"
	else
		warn "No appimage_sources.conf found, skipping AppImage/binary downloads."
	fi
	# Only create symlinks for lazygit and lnav from Sandbox, nvim from AppImages, all to ~/bin only
	for bin in lazygit lnav; do
		src="$SANDBOX_DIR/$bin"
		if [ -f "$src" ]; then
			ln -sf "$src" "$BIN_DIR/$bin"
			success "Symlinked $bin to $BIN_DIR/$bin"
		fi
	done
	src="$DOWNLOAD_DIR/nvim.appimage"
	if [ -f "$src" ]; then
		ln -sf "$src" "$BIN_DIR/nvim"
		success "Symlinked nvim to $BIN_DIR/nvim"
	fi
	# All other binaries are left as-is (no symlinks)
}

# Rustup update
update_rust() {
	headline "== Rustup Update =="
	rustup update && success "rustup update complete."
}

# NPM global update
update_npm() {
	headline "== NPM Global Update =="
	info "Updating npm itself and all global npm packages:"
	# Detect if inside toolbox (or podman container)
	       if grep -qE '/toolbox/' /proc/1/cgroup 2>/dev/null || [ -n "${TOOLBOX_PATH:-}" ]; then
		       if npm install -g npm && npm update -g; then
			       success "npm and global packages updated."
		       else
			       warn "NPM update failed due to permissions or other error. Skipping global npm update."
		       fi
	       elif command -v toolbox >/dev/null 2>&1; then
		       info "Not in toolbox, running npm commands via toolbox..."
		       if toolbox run --container fedora-develop-43 npm install -g npm && \
			  toolbox run --container fedora-develop-43 npm update -g; then
			       success "npm and global packages updated (via toolbox)."
		       else
			       warn "NPM update in toolbox failed due to permissions or other error. Skipping global npm update."
		       fi
	       else
		       warn "npm not available on host and toolbox not found. Skipping npm update."
	       fi
}

# Python user site update
update_python_user() {
	headline "== Python User Site Update =="
	warn "Running pip install --upgrade (user site)"
	python -m pip install --upgrade a2wsgi fastapi glances nvitop pip pip-search-ex \
	py3nvml pynvim python-dotenv PyYAML setuptools thefuck unicorn wheel
}

# g4f Python Environment Update
update_g4f_env() {
	   headline "== g4f Python Environment Update =="
	   info "Updating Python env in ~/g4f via direnv:"
	   pushd "$HOME/g4f" > /dev/null 2>&1 || return
	   eval "$(direnv export bash)"
	   if [ -z "${VIRTUAL_ENV:-}" ]; then
		   error "direnv did not activate a Python virtual environment! Aborting g4f update."
		   warn "Make sure direnv is installed, allowed, and .envrc contains 'layout python'."
		   popd > /dev/null || return
		   return 1
	   fi
	   python -m pip install --upgrade 'g4f[all]' && success "g4f[all] upgraded."
	popd > /dev/null || return
}

# Tdarr Updater
update_tdarr() {
	headline "== Tdarr Updater =="
	pushd "$HOME/Tdarr" > /dev/null 2>&1 || return
	./Tdarr_Updater && success "Tdarr updated."
	popd > /dev/null || return
}

# Firmware Updates
update_firmware() {
	headline "== Firmware Updates =="
	info "Refreshing and applying firmware updates:"
	       if fwupdmgr refresh && fwupdmgr update; then
		       success "Firmware updated."
	       else
		       warn "Firmware update failed or not supported. Skipping."
	       fi
}

# fzf and fzf-git.sh
update_fzf() {
	headline "== fzf and fzf-git.sh =="
	pushd "$HOME/fzf" > /dev/null 2>&1 || return
	git pull && ./install --all && success "fzf updated."
	popd > /dev/null || return
	pushd "$HOME/fzf-git.sh" > /dev/null 2>&1 || return
	git pull && success "fzf-git.sh updated."
	popd > /dev/null || return
}

# RPM-Ostree and Flatpak
update_rpm_ostree_flatpak() {
	headline "== System Package Updates =="
	rpm-ostree cleanup -brpm && success "RPM-Ostree cleanup complete."
	warn "Upgrading RPM-Ostree system:"
	rpm-ostree upgrade && success "RPM-Ostree upgrade complete."
	warn "Update flatpaks:"
	flatpak update -y && success "Flatpaks updated."
}

# Fedora Toolbox Updates
update_toolbox() {
	for container in fedora-toolbox-43 fedora-develop-43; do
		headline "============= Entering $container ============="
		toolbox run --container "$container" sudo dnf autoremove -y
		toolbox run --container "$container" sudo dnf clean all
		toolbox run --container "$container" sudo dnf upgrade --refresh --best --allowerasing -y
		if [ "$container" = "fedora-develop-43" ]; then
			toolbox run --container "$container" cargo install-update -a
		else
			toolbox run --container "$container" sudo freshclam
		fi
	done
}

# GitHub Repositories Update
update_github_repos() {
	headline "== GitHub Repositories Update =="
	GITHUB_DIR="$HOME/Projects/GitHub"
	for repo in "$GITHUB_DIR"/*/; do
		[ -d "$repo/.git" ] || continue
		reponame=$(basename "$repo")
		warn "Pulling latest changes for $reponame"
		pushd "$repo" > /dev/null || return
		git pull
		popd > /dev/null || return
	done
	# Update local Scripts repository if it's a git repo
	if [ -d "$HOME/Scripts/.git" ]; then
		warn "Pulling latest changes for local Scripts repository"
		pushd "$HOME/Scripts" > /dev/null || return
		git pull && success "Local Scripts repository updated."
		popd > /dev/null || return
	fi
}

# Fonts Updater (calls external script)
update_fonts() {
	headline "== Nerd Fonts Updater =="
	"$(dirname "$0")/fonts-font_cache_silverblue.sh" || warn "Font update failed"
	success "Font update completed."
}

# Main orchestrator
main() {
	update_appimages || warn "AppImage update failed, continuing."
	update_rust || warn "Rustup update failed, continuing."
	update_npm || warn "NPM update failed, continuing."
	update_python_user || warn "Python user site update failed, continuing."
	update_g4f_env || warn "g4f Python env update failed, continuing."
	update_tdarr || warn "Tdarr update failed, continuing."
	update_firmware || warn "Firmware update failed, continuing."
	update_fzf || warn "fzf update failed, continuing."
	update_rpm_ostree_flatpak || warn "RPM-Ostree/Flatpak update failed, continuing."
	update_toolbox || warn "Toolbox update failed, continuing."
	update_github_repos || warn "GitHub repos update failed, continuing."
	update_github_cli || warn "GitHub CLI update failed, continuing."
	update_cargo_deepclean || warn "Cargo deepclean failed, continuing."
	update_fonts || warn "Font update failed, continuing."
	headline "== All Updates Complete! =="
}

main "$@"

# Also update Alacritty themes if not in GitHub dir
if [ -d ~/.config/alacritty/themes/.git ]; then
	warn "Pulling patch from Alacritty Themes Github repository"
	pushd ~/.config/alacritty/themes > /dev/null || exit
	git pull origin master && success "Alacritty themes updated."
	popd > /dev/null || exit
fi
