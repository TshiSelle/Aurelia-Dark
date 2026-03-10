#!/bin/bash
# Aurelia Dark Color Customizer
# Interactive script to change the theme's color palette
#
# Usage: ./customize-colors.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COLORS_FILE="$SCRIPT_DIR/colors.toml"

# Default colors (from current palette)
DEFAULT_ACCENT="#F05629"      # Orange
DEFAULT_BACKGROUND="#181B25"  # Deep Navy
DEFAULT_FOREGROUND="#E1E4EA"  # Light Grey

# Color preview function
preview_color() {
    local color="$1"
    local name="$2"
    # Convert hex to RGB for preview (simplified)
    echo -e "${CYAN}● ${NC}$name: ${color}"
}

# Validate hex color
validate_hex() {
    if [[ $1 =~ ^#[0-9A-Fa-f]{6}$ ]]; then
        return 0
    fi
    return 1
}

main() {
    clear
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  Aurelia Dark — Color Customizer${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

    # Extract current colors from colors.toml
    CURRENT_ACCENT=$(grep '^accent = ' "$COLORS_FILE" | cut -d'"' -f2)
    CURRENT_BG=$(grep '^background = ' "$COLORS_FILE" | cut -d'"' -f2)
    CURRENT_FG=$(grep '^foreground = ' "$COLORS_FILE" | cut -d'"' -f2)

    echo -e "${YELLOW}Current palette:${NC}\n"
    preview_color "$CURRENT_ACCENT" "Accent (primary color)"
    preview_color "$CURRENT_BG" "Background"
    preview_color "$CURRENT_FG" "Foreground (text)"

    echo -e "\n${YELLOW}Options:${NC}"
    echo -e "  ${CYAN}1${NC} — Change accent color (buttons, highlights, borders)"
    echo -e "  ${CYAN}2${NC} — Change background color (dark base)"
    echo -e "  ${CYAN}3${NC} — Change foreground color (text)"
    echo -e "  ${CYAN}4${NC} — Use preset palette"
    echo -e "  ${CYAN}5${NC} — Reset to default Aurelia"
    echo -e "  ${CYAN}6${NC} — View all editable colors"
    echo -e "  ${CYAN}0${NC} — Exit\n"

    read -p "Choose option: " choice

    case $choice in
        1)
            change_accent
            ;;
        2)
            change_background
            ;;
        3)
            change_foreground
            ;;
        4)
            preset_palette
            ;;
        5)
            reset_to_default
            ;;
        6)
            view_all_colors
            ;;
        0)
            echo -e "\n${BLUE}Goodbye!${NC}\n"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            sleep 1
            main
            ;;
    esac

    apply_changes
}

change_accent() {
    echo -e "\n${YELLOW}Change Accent Color${NC}"
    echo "Current: $CURRENT_ACCENT"
    echo "This color is used for buttons, highlights, and borders."
    echo -e "\nEnter hex color (e.g., #FF6B35, #00D9FF, #FFB84D):"
    read -p "> " NEW_COLOR

    if validate_hex "$NEW_COLOR"; then
        sed -i "s/^accent = .*/accent = \"$NEW_COLOR\"/" "$COLORS_FILE"
        echo -e "${GREEN}✓${NC} Accent color updated to $NEW_COLOR"
    else
        echo -e "${RED}✗${NC} Invalid hex color format"
        sleep 1
    fi
}

change_background() {
    echo -e "\n${YELLOW}Change Background Color${NC}"
    echo "Current: $CURRENT_BG"
    echo "This is the main dark background of your desktop."
    echo -e "\nEnter hex color (e.g., #0a0e1a, #1a1a1a, #0f0f23):"
    read -p "> " NEW_COLOR

    if validate_hex "$NEW_COLOR"; then
        sed -i "s/^background = .*/background = \"$NEW_COLOR\"/" "$COLORS_FILE"
        echo -e "${GREEN}✓${NC} Background color updated to $NEW_COLOR"
    else
        echo -e "${RED}✗${NC} Invalid hex color format"
        sleep 1
    fi
}

change_foreground() {
    echo -e "\n${YELLOW}Change Foreground Color${NC}"
    echo "Current: $CURRENT_FG"
    echo "This is the text/foreground color (usually light)."
    echo -e "\nEnter hex color (e.g., #E1E4EA, #F0F0F0, #D0D0D0):"
    read -p "> " NEW_COLOR

    if validate_hex "$NEW_COLOR"; then
        sed -i "s/^foreground = .*/foreground = \"$NEW_COLOR\"/" "$COLORS_FILE"
        echo -e "${GREEN}✓${NC} Foreground color updated to $NEW_COLOR"
    else
        echo -e "${RED}✗${NC} Invalid hex color format"
        sleep 1
    fi
}

preset_palette() {
    echo -e "\n${YELLOW}Choose Preset Palette:${NC}\n"
    echo -e "  ${CYAN}1${NC} — Aurelia (default) — Orange accent"
    echo -e "  ${CYAN}2${NC} — Catppuccin-inspired — Purple accent"
    echo -e "  ${CYAN}3${NC} — Nord-inspired — Blue accent"
    echo -e "  ${CYAN}4${NC} — Dracula-inspired — Pink accent"
    echo -e "  ${CYAN}5${NC} — Sunset — Warm coral accent\n"

    read -p "Choose preset: " preset

    case $preset in
        1)
            # Aurelia
            sed -i 's/^accent = .*/accent = "#F05629"/' "$COLORS_FILE"
            sed -i 's/^background = .*/background = "#181B25"/' "$COLORS_FILE"
            sed -i 's/^foreground = .*/foreground = "#E1E4EA"/' "$COLORS_FILE"
            echo -e "${GREEN}✓${NC} Applied Aurelia palette"
            ;;
        2)
            # Catppuccin Purple
            sed -i 's/^accent = .*/accent = "#C5A3FF"/' "$COLORS_FILE"
            sed -i 's/^background = .*/background = "#161320"/' "$COLORS_FILE"
            sed -i 's/^foreground = .*/foreground = "#D9E0EE"/' "$COLORS_FILE"
            echo -e "${GREEN}✓${NC} Applied Catppuccin palette"
            ;;
        3)
            # Nord Blue
            sed -i 's/^accent = .*/accent = "#88C0D0"/' "$COLORS_FILE"
            sed -i 's/^background = .*/background = "#2E3440"/' "$COLORS_FILE"
            sed -i 's/^foreground = .*/foreground = "#ECEFF4"/' "$COLORS_FILE"
            echo -e "${GREEN}✓${NC} Applied Nord palette"
            ;;
        4)
            # Dracula Pink
            sed -i 's/^accent = .*/accent = "#FF79C6"/' "$COLORS_FILE"
            sed -i 's/^background = .*/background = "#282A36"/' "$COLORS_FILE"
            sed -i 's/^foreground = .*/foreground = "#F8F8F2"/' "$COLORS_FILE"
            echo -e "${GREEN}✓${NC} Applied Dracula palette"
            ;;
        5)
            # Sunset
            sed -i 's/^accent = .*/accent = "#FF7B54"/' "$COLORS_FILE"
            sed -i 's/^background = .*/background = "#0D1117"/' "$COLORS_FILE"
            sed -i 's/^foreground = .*/foreground = "#F0F6FC"/' "$COLORS_FILE"
            echo -e "${GREEN}✓${NC} Applied Sunset palette"
            ;;
        *)
            echo -e "${RED}Invalid preset${NC}"
            sleep 1
            return
            ;;
    esac
}

reset_to_default() {
    echo -e "\n${YELLOW}Reset to Aurelia defaults?${NC} [y/N]"
    read -p "> " confirm
    if [[ $confirm == "y" || $confirm == "Y" ]]; then
        sed -i 's/^accent = .*/accent = "#F05629"/' "$COLORS_FILE"
        sed -i 's/^background = .*/background = "#181B25"/' "$COLORS_FILE"
        sed -i 's/^foreground = .*/foreground = "#E1E4EA"/' "$COLORS_FILE"
        echo -e "${GREEN}✓${NC} Reset to default Aurelia palette"
    fi
}

view_all_colors() {
    echo -e "\n${YELLOW}All Customizable Colors in colors.toml:${NC}\n"
    echo "Main Colors:"
    grep "^accent\|^background\|^foreground\|^cursor\|^selection" "$COLORS_FILE" | head -5
    echo -e "\nANSI Terminal Colors (color0-color15):"
    grep "^color" "$COLORS_FILE" | head -8
    echo -e "\n(Edit colors.toml directly for full control over all 16 ANSI colors)"
    read -p "Press Enter to continue..."
}

apply_changes() {
    echo -e "\n${YELLOW}Changes made to colors.toml${NC}"
    echo -e "\n${YELLOW}To apply changes:${NC}"
    echo -e "  1. Go to Walker: ${CYAN}SUPER + ALT + SPACE${NC}"
    echo -e "  2. Navigate to: ${CYAN}Install → Style → Theme${NC}"
    echo -e "  3. Select and apply: ${CYAN}Aurelia Dark${NC}"
    echo -e "\nThis will regenerate all theme files with your new colors.\n"

    read -p "Would you like to re-apply the theme now? (y/N) " reapply
    if [[ $reapply == "y" || $reapply == "Y" ]]; then
        if command -v omarchy-theme-set &> /dev/null; then
            omarchy-theme-set aurelia-dark 2>/dev/null && \
                echo -e "${GREEN}✓${NC} Theme applied!" || \
                echo -e "${YELLOW}→${NC} Theme set, restart applications to see changes"
        else
            echo -e "${YELLOW}→${NC} Please apply theme manually through Walker"
        fi
    fi

    echo -e "\n${BLUE}Ready to make more changes? (any key to continue)${NC}"
    read -p "> "
    main
}

main "$@"
