# Lumon Plymouth Theme

A visually appealing Plymouth splash screen theme inspired by the Lumon Industries aesthetic from *Severance*. It features a 168-frame animation that plays during the boot and shutdown process.

## Features

- 168-frame animation sequence.
- Centered layout compatible with various screen resolutions.
- Simple installation script included.

## Quick Install (One-liner)

To install and set the Lumon theme as your default Plymouth splash screen, run the following command in your terminal:

```bash
curl -sSL https://raw.githubusercontent.com/kudayyurter/PlymouthLumonSplash/main/install.sh | sudo bash
```

This will automatically clone the repository, copy the theme files, and register it as your default splash.

## Manual Installation

If you prefer to install manually or have already cloned the repository:

1.  **Navigate to the root directory:**
    ```bash
    cd PlymouthLumonSplash
    ```

2.  **Run the installation script with sudo:**
    ```bash
    sudo ./install.sh
    ```

The script will:
- Copy the theme files to `/usr/share/plymouth/themes/lumon/`.
- Register the theme with Plymouth.
- Update your `initramfs` (using `plymouth-set-default-theme -R`).

## Manual Steps (Advanced)

If the script doesn't work for your distribution, follow these manual steps:

1.  Create the theme directory:
    ```bash
    sudo mkdir -p /usr/share/plymouth/themes/lumon
    ```

2.  Copy all files from `contents/splash/` to that directory:
    ```bash
    sudo cp contents/splash/*.png contents/splash/*.plymouth contents/splash/*.script /usr/share/plymouth/themes/lumon/
    ```

3.  Apply the theme (Debian/Ubuntu/Fedora):
    ```bash
    sudo plymouth-set-default-theme -R lumon
    ```

    *On some distributions like Arch Linux, you might need to manually update your `initramfs`:*
    ```bash
    sudo mkinitcpio -P linux
    ```

## Requirements

- **Plymouth:** Ensure Plymouth is installed and configured on your system.
- **Root Privileges:** Required to write to `/usr/share/plymouth/`.
- **Git:** Required for the quick install script.

## Preview

The theme features the Lumon logo animation sequence.

---
*Created with care for the Lumon Industries family.*
