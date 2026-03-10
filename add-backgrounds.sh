#!/bin/bash
# Add Aurelia Dark Wallpapers Helper
# This script copies wallpapers from the theme folder to omarchy locations
# so they appear immediately in the Style > Background menu
#
# Usage: ./add-backgrounds.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

THEME_NAME="aurelia-dark"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BG_SOURCE="$SCRIPT_DIR/backgrounds"
BG_DEST_1="$HOME/.config/omarchy/backgrounds/$THEME_NAME"
BG_DEST_2="$HOME/.config/omarchy/current/theme/backgrounds"

echo -e "${YELLOW}Aurelia Dark Wallpaper Installer${NC}\n"

if [[ ! -d "$BG_SOURCE" ]]; then
    echo -e "${RED}✗${NC} Backgrounds folder not found at: $BG_SOURCE"
    exit 1
fi

BG_COUNT=$(find "$BG_SOURCE" -maxdepth 1 -type f \( -name '*.jpg' -o -name '*.jpeg' -o -name '*.png' \) 2>/dev/null | wc -l)

if [[ $BG_COUNT -eq 0 ]]; then
    echo -e "${YELLOW}→${NC} No wallpapers found in: $BG_SOURCE"
    echo -e "${YELLOW}→${NC} Add wallpapers (aur-*.jpg) to the backgrounds folder"
    exit 0
fi

# Copy to both locations
mkdir -p "$BG_DEST_1" "$BG_DEST_2"

cp "$BG_SOURCE"/*.jpg "$BG_DEST_1/" 2>/dev/null || true
cp "$BG_SOURCE"/*.jpeg "$BG_DEST_1/" 2>/dev/null || true
cp "$BG_SOURCE"/*.png "$BG_DEST_1/" 2>/dev/null || true

cp "$BG_SOURCE"/*.jpg "$BG_DEST_2/" 2>/dev/null || true
cp "$BG_SOURCE"/*.jpeg "$BG_DEST_2/" 2>/dev/null || true
cp "$BG_SOURCE"/*.png "$BG_DEST_2/" 2>/dev/null || true

echo -e "${GREEN}✓${NC} Installed $BG_COUNT wallpaper(s)\n"
echo -e "${YELLOW}→${NC} Wallpapers are now available in Style > Background"
echo -e "${YELLOW}→${NC} No need to restart — open the menu to see them!\n"
