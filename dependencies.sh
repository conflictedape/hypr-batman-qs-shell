#!/usr/bin/env bash
#
# dependencies.sh will install the packages this shell config needs.
#
# Not run automatically by anything in this repo. Review it, then run it
# yourself (it will prompt for sudo via pacman):
#
#   ./dependencies.sh
#
# Safe to re-run any time (pacman -S --needed skips already-installed
# packages). Intended for setting this config up on a fresh CachyOS/Arch
# install.

set -euo pipefail

PACMAN_PACKAGES=(
    quickshell # the shell runtime (qs)
    ttf-hack-nerd # terminal/monospace font
    lm_sensors # CPU temperature, read by scripts/cpu-detail.sh via `sensors`
    nvidia-utils # NVIDIA GPU stats, read by scripts/gpu-*.sh via `nvidia-smi` (skip if no NVIDIA GPU)
    pciutils # AMD GPU friendly name, read by scripts/gpu-detail.sh via `lspci`
)

echo "Installing: ${PACMAN_PACKAGES[*]}"
sudo pacman -S --needed "${PACMAN_PACKAGES[@]}"

# --- lm_sensors first-time setup ---------------------------------------
# On a fresh machine (or a different CPU/motherboard than this one),
# lm_sensors needs to detect which kernel sensor modules to load. This is
# interactive, so it's not run automatically here. Run once after install:
#
#   sudo sensors-detect
#
# Answer the interactive prompts (defaults/YES is fine for most setups),
# then either reboot or `sudo modprobe <module>` for whatever it suggests.
# `scripts/cpu-detail.sh` degrades gracefully (empty temp field) if
# `sensors` has nothing to report yet.

# --- Material Symbols icon font -----------------------------------------
# Not packaged in the official repos or AUR in a form we depend on — this
# repo self-hosts the font file instead of relying on a system package, so
# the icons keep working even if an AUR package changes/disappears.
# Already present at assets/fonts/MaterialSymbolsRounded.ttf, loaded at
# runtime by Icons.qml via FontLoader (no `fc-cache`/system install needed).
#
# To refresh it (e.g. to pick up new icon glyphs) or set it up on a new
# machine if the assets/ directory wasn't copied over, re-download with:
#
#   curl -L -o assets/fonts/MaterialSymbolsRounded.ttf \
#       "https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsRounded%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf"

echo "Done. If this is a fresh machine, remember to run: sudo sensors-detect"
