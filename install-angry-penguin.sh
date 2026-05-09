#!/usr/bin/env bash
set -euo pipefail
# ──────────────────────────────────────────────────────────────────────────────
# Angry Penguin Theme + Icons Installer for Omarchy (2025/2026 version)
# ──────────────────────────────────────────────────────────────────────────────

THEME_NAME="angry-penguin"
TARGET_DIR="$HOME/.config/omarchy/themes/$THEME_NAME"
ICON_THEME_NAME="Angry-Penguin"
ICON_DIR="$HOME/.local/share/icons/$ICON_THEME_NAME"
PAPIRUS_USER_DIR="$HOME/.local/share/icons/Papirus-Dark"

echo "🔥 Installing Angry Penguin Theme for Omarchy..."

# Create required directories
mkdir -p "$HOME/.config/omarchy/themes"
mkdir -p "$ICON_DIR"

# ──────────────────────────────────────────────────────────────────────────────
# 1. Install / copy the Omarchy theme itself
# ──────────────────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -d "$SCRIPT_DIR/$THEME_NAME" ]]; then
    echo "→ Copying Omarchy theme from $SCRIPT_DIR/$THEME_NAME ..."
    cp -r "$SCRIPT_DIR/$THEME_NAME" "$HOME/.config/omarchy/themes/"
else
    echo "⚠️ Could not find folder '$THEME_NAME' in current directory."
    echo " Make sure you run this script from inside the extracted theme folder."
    echo " Example: cd angry-penguin-main && bash install.sh"
    exit 1
fi

echo "✅ Angry Penguin theme installed!"
echo " → Open Omarchy → Theme selector → apply '$THEME_NAME'"
echo ""

# ──────────────────────────────────────────────────────────────────────────────
# 2. Papirus icon theme (user-local install) + papirus-folders
# ──────────────────────────────────────────────────────────────────────────────
echo "🖼️ Installing / updating Papirus icon theme + deeporange folders..."

# Official Papirus one-liner (user install)
wget -qO- https://git.io/papirus-icon-theme-install | env DESTDIR="$HOME/.local/share/icons" sh

# Install papirus-folders if on Arch (using yay) and it's not already installed
if [[ -f /etc/arch-release || -f /etc/manjaro-release ]] && command -v yay >/dev/null 2>&1; then
    if ! command -v papirus-folders >/dev/null 2>&1; then
        echo "→ Detected Arch-based system + yay → installing papirus-folders..."
        yay -S --noconfirm papirus-folders
    else
        echo "→ papirus-folders already installed"
    fi
else
    echo "→ Not running Arch with yay → skipping automatic papirus-folders installation"
    echo "  (install it manually if you want colored folders: yay -S papirus-folders)"
fi

# Colorize folder icons (deeporange works nicely on Papirus-Dark)
if command -v papirus-folders >/dev/null 2>&1; then
    papirus-folders -C deeporange --theme Papirus-Dark
    echo "→ Papirus-Dark folders set to deeporange"
else
    echo "⚠️ papirus-folders command not found → skipping folder colorization"
fi

# ──────────────────────────────────────────────────────────────────────────────
# 3. Angry-Penguin custom icon theme setup
# ──────────────────────────────────────────────────────────────────────────────
# Adjust this path if your extracted folder name / structure is different!
ICON_SOURCE="$HOME/Angry_Penguin/angry-penguin-icons"

if [[ ! -d "$ICON_SOURCE" ]]; then
    echo "⚠️ Could not find Angry-Penguin icon source at: $ICON_SOURCE"
    echo " → Please edit the ICON_SOURCE= line with the correct path"
    echo " Continuing without custom mimetypes..."
else
    echo "→ Copying custom mimetypes & scalable icons..."
    for size in 16x16 22x22 24x24 32x32 48x48 64x64 128x128; do
        if [[ -d "$ICON_SOURCE/$size/mimetypes" ]]; then
            mkdir -p "$ICON_DIR/$size"
            cp -r "$ICON_SOURCE/$size/mimetypes" "$ICON_DIR/$size/" || true
        fi
    done
    [[ -d "$ICON_SOURCE/scalable" ]]   && cp -r "$ICON_SOURCE/scalable"   "$ICON_DIR/" || true
    [[ -f "$ICON_SOURCE/index.theme" ]] && cp "$ICON_SOURCE/index.theme" "$ICON_DIR/" || true
fi

# ──────────────────────────────────────────────────────────────────────────────
# 4. Use Papirus-Dark actions (most consistent look)
# ──────────────────────────────────────────────────────────────────────────────
echo "→ Copying clean action icons from Papirus-Dark..."

# Clean up any wrong/old action folders
for size in 16x16 22x22 24x24 32x32 48x48 64x64; do
    rm -rf "$ICON_DIR/$size/actions" 2>/dev/null || true
done

# Copy fresh actions
for size in 16x16 22x22 24x24 32x32 48x48 64x64; do
    if [[ -d "$PAPIRUS_USER_DIR/$size/actions" ]]; then
        mkdir -p "$ICON_DIR/$size"
        cp -r "$PAPIRUS_USER_DIR/$size/actions" "$ICON_DIR/$size/" || true
    fi
done

# ──────────────────────────────────────────────────────────────────────────────
# 5. Update icon caches
# ──────────────────────────────────────────────────────────────────────────────
echo "→ Updating icon caches..."
gtk-update-icon-cache -q "$PAPIRUS_USER_DIR" 2>/dev/null || true
gtk-update-icon-cache -q "$ICON_DIR"         2>/dev/null || true

# ──────────────────────────────────────────────────────────────────────────────
echo ""
echo "🎉 Installation finished!"
echo ""
echo "Next steps:"
echo " • Open Omarchy theme selector → apply 'angry-penguin'"
echo " • Set icon theme to 'Angry-Penguin' in your desktop settings"
echo " • Log out / restart session OR press F5 in file manager"
echo ""
echo "If icons still look wrong → check that:"
echo " • ~/.local/share/icons/Angry-Penguin/index.theme exists"
echo " • You selected 'Angry-Penguin' as icon theme (not Papirus)"
echo ""
