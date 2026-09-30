#!/bin/bash

# Lumon Plymouth Theme Installer
# Inspired by Lumon Industries (Severance)

THEME_NAME="lumon"
THEME_DIR="/usr/share/plymouth/themes/$THEME_NAME"
REPO_URL="https://github.com/kudayyurter/PlymouthLumonSplash.git"

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (use sudo)"
  exit 1
fi

echo "------------------------------------------"
echo "   Installing Lumon Plymouth Theme...   "
echo "------------------------------------------"

# If not running from within the repository, clone it to a temporary directory
if [[ ! -d "contents/splash" ]]; then
    echo "Files not found locally. Cloning from repository..."
    TEMP_DIR=$(mktemp -d)
    git clone --depth 1 "$REPO_URL" "$TEMP_DIR"
    cd "$TEMP_DIR" || { echo "Failed to enter temporary directory"; exit 1; }
fi

# Create theme directory
echo "Creating theme directory at $THEME_DIR..."
mkdir -p "$THEME_DIR"

# Copy files
echo "Copying theme files..."
cp contents/splash/*.png "$THEME_DIR/"
cp contents/splash/lumon.plymouth "$THEME_DIR/"
cp contents/splash/lumon.script "$THEME_DIR/"

# Set the theme
if command -v plymouth-set-default-theme &> /dev/null; then
    echo "Setting $THEME_NAME as the default theme..."
    if plymouth-set-default-theme -R "$THEME_NAME"; then
        echo "Done! The theme has been set and initramfs has been updated."
    else
        echo "Error: Failed to set the theme or update initramfs."
        exit 1
    fi
else
    echo "Error: plymouth-set-default-theme not found. Please install plymouth."
    exit 1
fi

echo "------------------------------------------"
echo "         Installation complete.           "
echo "------------------------------------------"
