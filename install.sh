#!/usr/bin/env bash
# spotify-spicetify — Arch Linux
# Usage: curl -fsSL <raw-url>/install.sh | bash

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}✔${NC} $1"; }
warn()  { echo -e "${YELLOW}⚠${NC} $1"; }
fail()  { echo -e "${RED}✘${NC} $1" >&2; exit 1; }

# Check OS
if ! grep -qi 'arch' /etc/os-release 2>/dev/null; then
  fail "This script is for Arch Linux only."
fi

# 1. Spotify
if command -v spotify-launcher &>/dev/null; then
  warn "spotify-launcher already installed, skipping."
else
  info "Installing spotify-launcher..."
  sudo pacman -S --noconfirm spotify-launcher
fi

# 2. Wayland config
CONF="$HOME/.config/spotify-launcher.conf"
if [ ! -f "$CONF" ]; then
  mkdir -p "$(dirname "$CONF")"
  cat > "$CONF" << 'EOF'
[spotify]
extra_arguments = ["--enable-features=UseOzonePlatform", "--ozone-platform=wayland"]
EOF
  info "Created Wayland config at $CONF"
else
  warn "Config already exists at $CONF, skipping."
fi

# 3. Spicetify CLI
if command -v spicetify &>/dev/null; then
  warn "Spicetify already installed, skipping."
else
  info "Installing Spicetify CLI..."
  curl -fsSL https://raw.githubusercontent.com/spicetify/cli/main/install.sh | sh
fi

# Refresh PATH
export PATH="$HOME/.local/share/spicetify/bin:$PATH"

# 4. Point Spicetify to Spotify
SPOTIFY_PATH="$HOME/.local/share/spotify-launcher/install/usr/share/spotify"
if [ -d "$SPOTIFY_PATH" ]; then
  info "Setting Spotify path for Spicetify..."
  spicetify config spotify_path "$SPOTIFY_PATH"
else
  warn "Spotify not found at $SPOTIFY_PATH — run 'spotify-launcher' first, then re-run this script."
fi

# 5. Apply
info "Applying Spicetify..."
spicetify backup apply

# 6. Marketplace (optional)
read -rp "Install Spicetify Marketplace? [y/N] " ANSWER
if [[ "$ANSWER" =~ ^[Yy]$ ]]; then
  info "Installing Marketplace..."
  curl -fsSL https://raw.githubusercontent.com/spicetify/spicetify-marketplace/main/resources/install.sh | sh
fi

echo ""
info "Done! Launch Spotify with:"
echo "  spotify-launcher"
echo ""
echo "Browse themes:"
echo "  spicetify theme"   
