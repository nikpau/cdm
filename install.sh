#!/usr/bin/env bash

# Build and install cdm, then add a shell function that can change the
# calling shell's working directory.
set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SOURCE_FILE="$SCRIPT_DIR/cdm.cpp"
readonly BUILD_FILE="$SCRIPT_DIR/cdm"
readonly INSTALL_FILE="/usr/local/bin/cdm"
readonly CONFIG_MARKER="# cdm shell integration"

log() {
    printf '[cdm] %s\n' "$1"
}

fail() {
    printf '[cdm] error: %s\n' "$1" >&2
    exit 1
}

command -v g++ >/dev/null 2>&1 || fail "g++ is required. Install your system's C++ build tools and try again."
[[ -f "$SOURCE_FILE" ]] || fail "Could not find cdm.cpp next to this installer."

log "Source: $SOURCE_FILE"
log "Compiler: $(command -v g++)"
log "Building with C++20 warnings enabled..."
g++ -std=c++20 -Wall -Wextra -pedantic -o "$BUILD_FILE" "$SOURCE_FILE"
log "Build complete: $BUILD_FILE"

if [[ -w "$(dirname "$INSTALL_FILE")" ]]; then
    install -m 0755 "$BUILD_FILE" "$INSTALL_FILE"
else
    command -v sudo >/dev/null 2>&1 || fail "Cannot write to $INSTALL_FILE and sudo is unavailable."
    log "Installing to $INSTALL_FILE (administrator permission required)..."
    sudo install -m 0755 "$BUILD_FILE" "$INSTALL_FILE"
fi
log "Installed executable: $INSTALL_FILE"

readonly USER_SHELL="${SHELL##*/}"
case "$USER_SHELL" in
    bash) CONFIG_FILE="${BASH_ENV:-$HOME/.bashrc}" ;;
    zsh) CONFIG_FILE="$HOME/.zshrc" ;;
    fish) CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish" ;;
    *)
        log "Shell '$USER_SHELL' is not configured automatically."
        log "Add a shell function that runs 'cd \$(command cdm \"\$@\")' manually."
        exit 0
        ;;
esac

mkdir -p "$(dirname "$CONFIG_FILE")"
if grep -Fqx "$CONFIG_MARKER" "$CONFIG_FILE" 2>/dev/null; then
    log "Shell integration already present in $CONFIG_FILE"
else
    {
        printf '\n%s\n' "$CONFIG_MARKER"
        if [[ "$USER_SHELL" == fish ]]; then
            printf 'function cdm\n    cd (command cdm $argv)\nend\n'
        else
            printf 'cdm() { builtin cd -- "$(command cdm "$@")"; }\n'
        fi
    } >> "$CONFIG_FILE"
    log "Added shell integration to $CONFIG_FILE"
fi

log "Installation finished. Restart your shell or reload its config, then run: cdm <directory>"