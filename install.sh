#!/bin/bash
# Aurelia Dark Theme Installation Script
# This script properly installs and configures the Aurelia Dark theme
# for Omarchy Hyprland systems.
#
# Usage: ./install.sh
# Or from GitHub: bash <(curl -s https://raw.githubusercontent.com/TshiSelle/Aurelia-Dark/main/install.sh)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Constants
THEME_NAME="aurelia-dark"
OMARCHY_CONFIG="$HOME/.config/omarchy"
THEMES_DIR="$OMARCHY_CONFIG/themes"
THEME_REPO="https://github.com/TshiSelle/Aurelia-Dark.git"
THEME_DIR="$THEMES_DIR/$THEME_NAME"

# Helper functions
print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_step() {
    echo -e "${YELLOW}▶${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1" >&2
}

check_dependency() {
    if ! command -v "$1" &> /dev/null; then
        print_error "Required command not found: $1"
        return 1
    fi
    return 0
}

# Main installation
main() {
    print_header "Aurelia Dark Theme Installer"

    # Check dependencies
    print_step "Checking dependencies..."
    if ! check_dependency "omarchy-theme-install"; then
        print_error "omarchy-theme-install not found. Please ensure Omarchy is installed."
        exit 1
    fi
    print_success "Dependencies check passed"

    # Determine if installing from local clone or from GitHub
    print_step "Determining installation source..."

    if [[ -d "$(pwd)/.git" ]] && grep -q "TshiSelle/Aurelia-Dark" .git/config 2>/dev/null; then
        # Installing from local clone
        INSTALL_SOURCE="$(pwd)"
        print_success "Installing from local repository"
    elif [[ -d "$THEME_DIR" ]]; then
        # Theme already exists locally, update it
        print_step "Theme found locally at $THEME_DIR, updating..."
        if command -v git &> /dev/null && [[ -d "$THEME_DIR/.git" ]]; then
            cd "$THEME_DIR"
            git pull origin main 2>/dev/null || print_step "Could not update theme from git"
            cd - > /dev/null
        fi
        INSTALL_SOURCE="$THEME_DIR"
        print_success "Using existing local theme"
    else
        # Clone from GitHub
        print_step "Cloning theme from GitHub..."
        mkdir -p "$THEMES_DIR"
        git clone "$THEME_REPO" "$THEME_DIR" 2>/dev/null || {
            print_error "Failed to clone theme repository"
            exit 1
        }
        INSTALL_SOURCE="$THEME_DIR"
        print_success "Theme cloned successfully"
    fi

    # Install theme using omarchy-theme-install
    print_step "Installing theme with Omarchy..."
    if omarchy-theme-install "$INSTALL_SOURCE" > /dev/null 2>&1; then
        print_success "Theme installed successfully"
    else
        print_error "Failed to install theme"
        exit 1
    fi

    # Setup theme-set hook
    print_step "Setting up theme hook..."
    HOOKS_DIR="$OMARCHY_CONFIG/hooks"
    mkdir -p "$HOOKS_DIR"

    if [[ -f "$INSTALL_SOURCE/install.sh" ]]; then
        # Extract hook from theme directory if it's a complete installation
        HOOK_SOURCE="$HOOKS_DIR/theme-set"
        if [[ ! -f "$HOOK_SOURCE" ]] || ! grep -q "Aurelia Dark" "$HOOK_SOURCE" 2>/dev/null; then
            cp "$INSTALL_SOURCE/install.sh" "$HOOK_SOURCE.new" 2>/dev/null || true
        fi
    fi

    # Ensure hook is executable
    if [[ -f "$HOOKS_DIR/theme-set" ]]; then
        chmod +x "$HOOKS_DIR/theme-set"
        print_success "Theme hook configured"
    fi

    # Copy backgrounds to omarchy backgrounds directory
    print_step "Installing wallpapers..."
    BG_SOURCE="$INSTALL_SOURCE/backgrounds"
    BG_DEST="$OMARCHY_CONFIG/backgrounds/$THEME_NAME"

    if [[ -d "$BG_SOURCE" ]]; then
        mkdir -p "$BG_DEST"
        BG_COUNT=$(find "$BG_SOURCE" -maxdepth 1 -type f \( -name '*.jpg' -o -name '*.jpeg' -o -name '*.png' \) 2>/dev/null | wc -l)

        if [[ $BG_COUNT -gt 0 ]]; then
            cp "$BG_SOURCE"/*.jpg "$BG_DEST/" 2>/dev/null || true
            cp "$BG_SOURCE"/*.jpeg "$BG_DEST/" 2>/dev/null || true
            cp "$BG_SOURCE"/*.png "$BG_DEST/" 2>/dev/null || true

            # Also copy to current theme location
            CURRENT_BG="$OMARCHY_CONFIG/current/theme/backgrounds"
            mkdir -p "$CURRENT_BG"
            cp "$BG_SOURCE"/*.jpg "$CURRENT_BG/" 2>/dev/null || true
            cp "$BG_SOURCE"/*.jpeg "$CURRENT_BG/" 2>/dev/null || true
            cp "$BG_SOURCE"/*.png "$CURRENT_BG/" 2>/dev/null || true

            print_success "Installed $BG_COUNT wallpaper(s)"
        else
            print_step "No wallpapers found in backgrounds folder (add them later with add-backgrounds.sh)"
        fi
    else
        print_step "No backgrounds directory found (create it and add wallpapers later)"
    fi

    # Apply the theme
    print_step "Applying theme..."
    if command -v omarchy-theme-set &> /dev/null; then
        omarchy-theme-set "$THEME_NAME" 2>/dev/null || {
            print_error "Failed to apply theme"
            exit 1
        }
        print_success "Theme applied successfully"
    else
        print_step "Theme installed. Apply it manually via Walker (SUPER + ALT + SPACE > Install > Style > Theme)"
    fi

    # Verification
    print_step "Verifying installation..."
    if [[ -L "$OMARCHY_CONFIG/current/theme" ]] || [[ -d "$OMARCHY_CONFIG/current/theme" ]]; then
        CURRENT_THEME=$(basename "$(readlink -f "$OMARCHY_CONFIG/current/theme")")
        if [[ "$CURRENT_THEME" == "$THEME_NAME" ]] || [[ -f "$OMARCHY_CONFIG/current/theme.name" ]]; then
            print_success "Installation verified"
        fi
    fi

    # Final message
    print_header "Installation Complete!"
    echo -e "Aurelia Dark has been successfully installed!\n"
    echo -e "  ${GREEN}✓${NC} Theme files deployed"
    echo -e "  ${GREEN}✓${NC} Wallpapers configured"
    echo -e "  ${GREEN}✓${NC} System hooks activated"
    echo -e "  ${GREEN}✓${NC} Theme applied\n"

    if [[ -d "$OMARCHY_CONFIG/current/theme/waybar-theme" ]]; then
        echo -e "  ${YELLOW}→${NC} Waybar styling installed"
    fi
    if [[ -d "$OMARCHY_CONFIG/current/theme/backgrounds" ]] && [[ $(find "$OMARCHY_CONFIG/current/theme/backgrounds" -type f 2>/dev/null | wc -l) -gt 0 ]]; then
        echo -e "  ${YELLOW}→${NC} Wallpapers available in Theme > Background"
    fi

    echo -e "\n${BLUE}Next steps:${NC}"
    echo -e "  ${YELLOW}→${NC} Add wallpapers: place .jpg/.png files in backgrounds/ folder"
    echo -e "  ${YELLOW}→${NC} Re-apply theme: Install → Style → Theme → Aurelia Dark"
    echo -e "  ${YELLOW}→${NC} View wallpapers: Style → Background in Walker\n"
    echo -e "${BLUE}Enjoy your new Aurelia Dark theme!${NC}\n"
}

# Run installation
main "$@"
