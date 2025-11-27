#!/bin/bash
set -e  # Exit immediately on error


# ========================
# PROJECT CONFIGURATION
# ========================
PROJECT_NAME="chromiumut"
SNAP_FILE="${BUILD_DIR}/chromium-desktop.snap"
EXTRACT_DIR="${BUILD_DIR}/squashfs-root"
INSTALL_DIR="${BUILD_DIR}/install"
EXPECTED_HASH="7ee73ff2b6057ed279fe22d871b2dff28f53384f9da6f43e0dda9f2664e097be"

# ======================================
# STEP 0: Install maliit with crackle
# ======================================
echo "[1/6] Cleaning up..."

# ${ROOT}/crackle/crackle update
# ${ROOT}/crackle/crackle click maliit-inputcontext-gtk3


# ========================
# STEP 1: PREPARATION
# ========================
echo "[2/6] Cleaning up..."
rm -rf "$EXTRACT_DIR" "$INSTALL_DIR"
mkdir -p "$EXTRACT_DIR" "$INSTALL_DIR"
cp -r ${BUILD_DIR}/usr/lib "$INSTALL_DIR"
rm -rf $INSTALL_DIR/lib/x86_64-linux-gnu
# cp -r ${ROOT}/immodules.cache "$INSTALL_DIR/lib/aarch64-linux-gnu/gtk-3.0/3.0.0/immodules/immodules.cache"

# ========================
# STEP 2: DOWNLOAD THE LATEST SIGNAL DESKTOP SNAP USING SNAP
# ========================
echo "[3/6] Downloading latest Signal Desktop via snap..."
mkdir -p "$EXTRACT_DIR"


# Télécharge le snap sans l’installer globalement
cd ${BUILD_DIR}
DOWNLOAD_URL=$(curl -s https://api.snapcraft.io/v2/snaps/info/chromium -H "Snap-Device-Series: 16" -H "Snap-Architecture: arm64" | jq -r '.["channel-map"][] 
            | select(.channel.architecture=="arm64" and .channel.name=="stable") 
            | .download.url'
            )
curl -L -o "$SNAP_FILE" "$DOWNLOAD_URL"
# ========================
# STEP 3: EXTRACTION
# ========================
echo "[4/6] Extracting .snap package..."
rm -r $EXTRACT_DIR
echo "Extracting $SNAP_FILE to $EXTRACT_DIR"
unsquashfs "$SNAP_FILE"

# ========================
# STEP 4: INSTALL TO TEMP DIRECTORY
# ========================


echo "[5/6] Copying Chrome to $INSTALL_DIR/usr..."
mkdir -p "$INSTALL_DIR/usr/"
cp -r "$EXTRACT_DIR/usr/" "$INSTALL_DIR/" || true


mkdir -p "$INSTALL_DIR/utils/"
cp ${ROOT}/utils/sleep.sh "$INSTALL_DIR/utils/"
cp ${ROOT}/utils/get-scale.sh "$INSTALL_DIR/utils/"

# Copy project files
cp ${ROOT}/launcher.sh "$INSTALL_DIR/"
cp ${ROOT}/chromiumut.desktop "$INSTALL_DIR/"
cp ${ROOT}/icon.png "$INSTALL_DIR/"
cp ${ROOT}/icon-splash.png "$INSTALL_DIR/"
cp ${ROOT}/manifest.json "$INSTALL_DIR/"
cp ${ROOT}/chromiumut.apparmor "$INSTALL_DIR/"

chmod +x $INSTALL_DIR/utils/sleep.sh
chmod +x $INSTALL_DIR/utils/get-scale.sh
chmod +x $INSTALL_DIR/launcher.sh
chmod +x $INSTALL_DIR/usr/lib/chromium-browser/chrome
chmod +x $INSTALL_DIR/usr/lib/chromium-browser/chrome-sandbox
chmod +x $INSTALL_DIR/usr/lib/chromium-browser/chrome_crashpad_handler

# ========================
# STEP 5: BUILD THE CLICK PACKAGE
# ========================
echo "[6/6] Building click package..."
# click build "$INSTALL_DIR"

echo "✅ Preparation done, building the .click package."
 
