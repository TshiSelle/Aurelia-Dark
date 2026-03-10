#!/bin/bash
# Aurelia Dark Theme Installation Script
# This script properly installs and configures the Aurelia Dark theme
# for Omarchy Hyprland systems.
#
# Usage: ./install.sh
# Or from GitHub: bash <(curl -s https://raw.githubusercontent.com/TshiSelle/Aurelia-Dark/main/install.sh)
#
# CONFIGURATION:
# Comment out any function below to skip its installation. Example:
#   # apply_walker
#   # apply_waybar

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Constants
THEME_NAME="aurelia-dark"
OMARCHY_CONFIG="$HOME/.config/omarchy"
THEMES_DIR="$OMARCHY_CONFIG/themes"
THEME_REPO="https://github.com/TshiSelle/Aurelia-Dark.git"
THEME_DIR="$THEMES_DIR/$THEME_NAME"
BACKUP_DIR="$OMARCHY_CONFIG/backups/aurelia-dark-$(date +%Y%m%d-%H%M%S)"
BACKED_UP_CONFIGS=()

# Helper functions
print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_section() {
    echo -e "\n${MAGENTA}├─ $1${NC}"
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

print_skip() {
    echo -e "${YELLOW}⊘${NC} Skipped: $1"
}

check_dependency() {
    if ! command -v "$1" &> /dev/null; then
        print_error "Required command not found: $1"
        return 1
    fi
    return 0
}

copy_file() {
    local src="$1"
    local dest="$2"
    if [[ -f "$src" ]]; then
        mkdir -p "$(dirname "$dest")"
        cp "$src" "$dest" || print_error "Failed to copy $src to $dest"
    fi
}

copy_dir() {
    local src="$1"
    local dest="$2"
    if [[ -d "$src" ]]; then
        mkdir -p "$dest"
        cp -r "$src"/* "$dest/" 2>/dev/null || true
    fi
}

backup_config() {
    local config_path="$1"
    local config_name="$2"

    if [[ -f "$config_path" ]] || [[ -d "$config_path" ]]; then
        mkdir -p "$BACKUP_DIR"
        if [[ -d "$config_path" ]]; then
            cp -r "$config_path" "$BACKUP_DIR/$config_name" 2>/dev/null || return 1
        else
            cp "$config_path" "$BACKUP_DIR/$config_name" 2>/dev/null || return 1
        fi
        BACKED_UP_CONFIGS+=("$config_name → $config_path")
        print_success "Backed up $(basename "$config_path") to $BACKUP_DIR/"
        return 0
    fi
    return 1
}

# ============================================================================
# COMPONENT INSTALLATION FUNCTIONS
# Comment out any function below to skip its installation
# ============================================================================

apply_hyprland_wayland() {
    print_section "Wayland/Hyprland Configuration"
    if [[ -f "$INSTALL_SOURCE/hyprland.conf" ]]; then
        copy_file "$INSTALL_SOURCE/hyprland.conf" "$OMARCHY_CONFIG/current/theme/hyprland.conf"
        print_success "Hyprland config installed"
    fi
}

apply_lockscreen() {
    print_section "Lockscreen (Hyprlock)"
    HYPRLOCK_CONFIG="$HOME/.config/hypr/hyprlock.conf"

    if [[ -f "$INSTALL_SOURCE/hyprlock.conf" ]]; then
        # Backup existing config
        backup_config "$HYPRLOCK_CONFIG" "hyprlock.conf.backup"

        mkdir -p "$(dirname "$HYPRLOCK_CONFIG")"
        copy_file "$INSTALL_SOURCE/hyprlock.conf" "$HYPRLOCK_CONFIG"
        print_success "Lockscreen config installed"
    fi
}

apply_walker() {
    print_section "Application Launcher (Walker)"
    WALKER_CONFIG="$HOME/.config/walker"

    if [[ -f "$INSTALL_SOURCE/walker.css" ]]; then
        # Backup existing config
        backup_config "$WALKER_CONFIG/style.css" "walker-style.css.backup"

        mkdir -p "$WALKER_CONFIG"
        copy_file "$INSTALL_SOURCE/walker.css" "$WALKER_CONFIG/style.css"
        print_success "Walker stylesheet installed"
    fi
}

apply_waybar() {
    print_section "Status Bar (Waybar)"
    WAYBAR_CONFIG="$HOME/.config/waybar"

    # Backup existing waybar config and styles
    if [[ -d "$WAYBAR_CONFIG" ]]; then
        backup_config "$WAYBAR_CONFIG/config.jsonc" "waybar-config.jsonc.backup"
        backup_config "$WAYBAR_CONFIG/style.css" "waybar-style.css.backup"
    fi

    mkdir -p "$WAYBAR_CONFIG"

    # Apply theme versions
    if [[ -f "$INSTALL_SOURCE/waybar.css" ]]; then
        copy_file "$INSTALL_SOURCE/waybar.css" "$WAYBAR_CONFIG/style.css"
    fi

    if [[ -d "$INSTALL_SOURCE/waybar-theme" ]]; then
        copy_dir "$INSTALL_SOURCE/waybar-theme" "$WAYBAR_CONFIG/theme"
        # Also copy config.jsonc from waybar-theme if available
        if [[ -f "$INSTALL_SOURCE/waybar-theme/config.jsonc" ]]; then
            copy_file "$INSTALL_SOURCE/waybar-theme/config.jsonc" "$WAYBAR_CONFIG/config.jsonc"
        fi
    fi

    print_success "Waybar config and styles installed"
}

apply_osd() {
    print_section "On-Screen Display (OSD)"

    # Mako notifications
    if [[ -f "$INSTALL_SOURCE/mako.ini" ]]; then
        MAKO_CONFIG="$HOME/.config/mako"

        # Backup existing config
        backup_config "$MAKO_CONFIG/config" "mako-config.backup"

        mkdir -p "$MAKO_CONFIG"
        copy_file "$INSTALL_SOURCE/mako.ini" "$MAKO_CONFIG/config"
        print_success "Mako notifications config installed"
    fi

    # SwayOSD
    if [[ -f "$INSTALL_SOURCE/swayosd.css" ]]; then
        SWAYOSD_CONFIG="$HOME/.config/swayosd"

        # Backup existing style
        backup_config "$SWAYOSD_CONFIG/style.css" "swayosd-style.css.backup"

        mkdir -p "$SWAYOSD_CONFIG"
        copy_file "$INSTALL_SOURCE/swayosd.css" "$SWAYOSD_CONFIG/style.css"
        print_success "SwayOSD style installed"
    fi
}

apply_terminals() {
    print_section "Terminal Emulators"

    # Alacritty
    if [[ -f "$INSTALL_SOURCE/alacritty.toml" ]]; then
        ALACRITTY_CONFIG="$HOME/.config/alacritty"
        mkdir -p "$ALACRITTY_CONFIG"
        copy_file "$INSTALL_SOURCE/alacritty.toml" "$ALACRITTY_CONFIG/alacritty.toml"
        print_success "Alacritty config installed"
    fi

    # Ghostty
    if [[ -f "$INSTALL_SOURCE/ghostty.conf" ]]; then
        GHOSTTY_CONFIG="$HOME/.config/ghostty"
        mkdir -p "$GHOSTTY_CONFIG"
        # Merge with existing config or create new
        if [[ -f "$GHOSTTY_CONFIG/config" ]]; then
            # Append theme colors if not already present
            if ! grep -q "aurelia-dark" "$GHOSTTY_CONFIG/config" 2>/dev/null; then
                echo -e "\n# Aurelia Dark Theme" >> "$GHOSTTY_CONFIG/config"
                cat "$INSTALL_SOURCE/ghostty.conf" >> "$GHOSTTY_CONFIG/config"
            fi
        else
            copy_file "$INSTALL_SOURCE/ghostty.conf" "$GHOSTTY_CONFIG/config"
        fi
        print_success "Ghostty config installed"
    fi

    # Kitty
    if [[ -f "$INSTALL_SOURCE/kitty.conf" ]]; then
        KITTY_CONFIG="$HOME/.config/kitty"
        mkdir -p "$KITTY_CONFIG"
        # Merge with existing config or create new
        if [[ -f "$KITTY_CONFIG/kitty.conf" ]]; then
            if ! grep -q "aurelia-dark" "$KITTY_CONFIG/kitty.conf" 2>/dev/null; then
                echo -e "\n# Aurelia Dark Theme" >> "$KITTY_CONFIG/kitty.conf"
                cat "$INSTALL_SOURCE/kitty.conf" >> "$KITTY_CONFIG/kitty.conf"
            fi
        else
            copy_file "$INSTALL_SOURCE/kitty.conf" "$KITTY_CONFIG/kitty.conf"
        fi
        print_success "Kitty config installed"
    fi
}

apply_gtk() {
    print_section "GTK Theming"
    if [[ -f "$INSTALL_SOURCE/gtk.css" ]]; then
        GTK3_CONFIG="$HOME/.config/gtk-3.0"
        GTK4_CONFIG="$HOME/.config/gtk-4.0"
        mkdir -p "$GTK3_CONFIG" "$GTK4_CONFIG"
        copy_file "$INSTALL_SOURCE/gtk.css" "$GTK3_CONFIG/gtk.css"
        copy_file "$INSTALL_SOURCE/gtk.css" "$GTK4_CONFIG/gtk.css"
        print_success "GTK3/4 CSS installed"
    fi
}

apply_apps() {
    print_section "Application Themes"

    # BTops
    if [[ -f "$INSTALL_SOURCE/btop.theme" ]]; then
        BTOP_CONFIG="$HOME/.config/btop/themes"
        mkdir -p "$BTOP_CONFIG"
        copy_file "$INSTALL_SOURCE/btop.theme" "$BTOP_CONFIG/aurelia-dark"
        print_success "Btop theme installed"
    fi

    # Icons
    if [[ -f "$INSTALL_SOURCE/icons.theme" ]]; then
        # This is typically handled by omarchy, but ensure it's available
        ICONS_DIR="$OMARCHY_CONFIG/current/theme"
        mkdir -p "$ICONS_DIR"
        copy_file "$INSTALL_SOURCE/icons.theme" "$ICONS_DIR/icons.theme"
        print_success "Icon theme reference installed"
    fi

    # Neovim
    if [[ -f "$INSTALL_SOURCE/neovim.lua" ]]; then
        NVIM_CONFIG="$HOME/.config/nvim"
        mkdir -p "$NVIM_CONFIG"
        if [[ -d "$NVIM_CONFIG/colors" ]]; then
            copy_file "$INSTALL_SOURCE/neovim.lua" "$NVIM_CONFIG/colors/aurelia-dark.lua"
            print_success "Neovim colorscheme installed"
        fi
    fi

    # VS Code
    if [[ -f "$INSTALL_SOURCE/vscode.json" ]]; then
        VSCODE_CONFIG="$HOME/.config/Code/User"
        # VS Code config location varies by distro
        if [[ ! -d "$VSCODE_CONFIG" ]]; then
            VSCODE_CONFIG="$HOME/.vscode"
        fi
        mkdir -p "$VSCODE_CONFIG"
        # Note: VS Code uses settings.json, user can merge colors manually
        print_step "VS Code theme available at $INSTALL_SOURCE/vscode.json (merge settings manually)"
    fi
}

apply_shell_colors() {
    print_section "Shell Colors"

    # Fish shell
    if [[ -f "$INSTALL_SOURCE/colors.fish" ]]; then
        FISH_CONFIG="$HOME/.config/fish/conf.d"
        mkdir -p "$FISH_CONFIG"
        copy_file "$INSTALL_SOURCE/colors.fish" "$FISH_CONFIG/aurelia-dark-colors.fish"
        print_success "Fish shell colors installed"
    fi

    # FZF
    if [[ -f "$INSTALL_SOURCE/fzf.fish" ]]; then
        copy_file "$INSTALL_SOURCE/fzf.fish" "$FISH_CONFIG/fzf-aurelia-dark.fish"
        print_success "FZF theme installed"
    fi
}

apply_wallpapers() {
    print_section "Wallpapers"
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
            print_step "No wallpapers found in backgrounds folder (add them later)"
        fi
    else
        print_step "No backgrounds directory found"
    fi
}

# ============================================================================
# MAIN INSTALLATION ORCHESTRATION
# ============================================================================

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

    # ========================================================================
    # COMPONENT INSTALLATION CALLS
    # Comment out any function below to skip its installation
    # ========================================================================

    print_header "Installing Theme Components"

    # Core system
    apply_hyprland_wayland
    apply_lockscreen
    apply_gtk

    # Desktop environment
    apply_walker
    apply_waybar
    apply_osd

    # Terminals
    apply_terminals

    # Application themes
    apply_apps
    apply_shell_colors

    # Wallpapers
    apply_wallpapers

    # ========================================================================
    # VERIFICATION & FINAL MESSAGE
    # ========================================================================

    print_step "Verifying installation..."
    if [[ -L "$OMARCHY_CONFIG/current/theme" ]] || [[ -d "$OMARCHY_CONFIG/current/theme" ]]; then
        CURRENT_THEME=$(basename "$(readlink -f "$OMARCHY_CONFIG/current/theme")")
        if [[ "$CURRENT_THEME" == "$THEME_NAME" ]] || [[ -f "$OMARCHY_CONFIG/current/theme.name" ]]; then
            print_success "Installation verified"
        fi
    fi

    print_header "✨ Installation Complete! ✨"
    echo -e "Aurelia Dark has been successfully installed!\n"
    echo -e "  ${GREEN}✓${NC} Theme files deployed"
    echo -e "  ${GREEN}✓${NC} Desktop environment configured"
    echo -e "  ${GREEN}✓${NC} Terminals themed"
    echo -e "  ${GREEN}✓${NC} Applications styled"
    echo -e "  ${GREEN}✓${NC} System hooks activated\n"

    echo -e "${BLUE}Installed components:${NC}"
    [[ -f "$OMARCHY_CONFIG/current/theme/hyprland.conf" ]] && echo -e "  ${GREEN}✓${NC} Hyprland/Wayland"
    [[ -f "$HOME/.config/hypr/hyprlock.conf" ]] && echo -e "  ${GREEN}✓${NC} Lockscreen (Hyprlock)"
    [[ -f "$HOME/.config/walker/style.css" ]] && echo -e "  ${GREEN}✓${NC} Walker launcher"
    [[ -f "$HOME/.config/waybar/style.css" ]] && echo -e "  ${GREEN}✓${NC} Waybar status bar"
    [[ -f "$HOME/.config/mako/config" ]] && echo -e "  ${GREEN}✓${NC} Notifications (Mako)"
    [[ -d "$HOME/.config/alacritty" ]] && echo -e "  ${GREEN}✓${NC} Alacritty terminal"
    [[ -f "$HOME/.config/ghostty/config" ]] && echo -e "  ${GREEN}✓${NC} Ghostty terminal"
    [[ -f "$HOME/.config/kitty/kitty.conf" ]] && echo -e "  ${GREEN}✓${NC} Kitty terminal"
    [[ -d "$OMARCHY_CONFIG/backgrounds/$THEME_NAME" ]] && [[ $(find "$OMARCHY_CONFIG/backgrounds/$THEME_NAME" -type f 2>/dev/null | wc -l) -gt 0 ]] && echo -e "  ${GREEN}✓${NC} Wallpapers"

    # Show backup information
    if [[ ${#BACKED_UP_CONFIGS[@]} -gt 0 ]]; then
        echo -e "\n${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BLUE}Backed up configurations:${NC}"
        for backup_info in "${BACKED_UP_CONFIGS[@]}"; do
            echo -e "  ${YELLOW}→${NC} $backup_info"
        done
        echo -e "\n${BLUE}Backup location:${NC}"
        echo -e "  ${YELLOW}$BACKUP_DIR${NC}\n"
        echo -e "${BLUE}To restore:${NC}"
        echo -e "  ${YELLOW}→${NC} Copy files back from backup: cp -r $BACKUP_DIR/* ~/.config/"
        echo -e "  ${YELLOW}→${NC} Or manually edit your configs in ~/.config/\n"
        echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    fi

    echo -e "${BLUE}Next steps:${NC}"
    echo -e "  ${YELLOW}→${NC} Restart your shell/terminal to see color changes"
    echo -e "  ${YELLOW}→${NC} Log out and back in for full Hyprland/Wayland changes"
    echo -e "  ${YELLOW}→${NC} Customize further by editing config files in ~/.config/\n"
    echo -e "${BLUE}To customize this installer:${NC}"
    echo -e "  ${YELLOW}→${NC} Edit install.sh and comment out component functions you don't need"
    echo -e "  ${YELLOW}→${NC} Re-run to skip those components\n"
    echo -e "${BLUE}Enjoy your new Aurelia Dark theme!${NC}\n"
}

# Run installation
main "$@"
