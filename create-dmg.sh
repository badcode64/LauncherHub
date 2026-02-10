#!/bin/bash

# LauncherHub DMG Creator
# Creates a distributable DMG file

set -e

APP_NAME="LauncherHub"
VERSION="1.0.0"
DMG_NAME="${APP_NAME}-${VERSION}"
DMG_DIR="dmg-temp"
DMG_FILE="${DMG_NAME}.dmg"

echo "🚀 Creating ${DMG_FILE}..."

# Build the app first
./build.sh

# Check if app exists
if [ ! -d "${APP_NAME}.app" ]; then
    echo "❌ Error: ${APP_NAME}.app not found!"
    exit 1
fi

# Add icon to app if exists
if [ -f "LauncherHub.icns" ]; then
    cp LauncherHub.icns "${APP_NAME}.app/Contents/Resources/AppIcon.icns"
    # Update Info.plist to use the icon
    /usr/libexec/PlistBuddy -c "Add :CFBundleIconFile string AppIcon" "${APP_NAME}.app/Contents/Info.plist" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Set :CFBundleIconFile AppIcon" "${APP_NAME}.app/Contents/Info.plist"
fi

# Clean up old DMG and temp directory
rm -rf "${DMG_DIR}" "${DMG_FILE}"

# Create temp directory structure
mkdir -p "${DMG_DIR}"

# Copy app to temp directory
cp -R "${APP_NAME}.app" "${DMG_DIR}/"

# Create symbolic link to Applications folder
ln -s /Applications "${DMG_DIR}/Applications"

# Create DMG
echo "📦 Creating DMG image..."

# Calculate size needed (app size + 10MB buffer)
APP_SIZE=$(du -sm "${APP_NAME}.app" | cut -f1)
DMG_SIZE=$((APP_SIZE + 20))

# Create DMG using hdiutil
hdiutil create -volname "${APP_NAME}" \
    -srcfolder "${DMG_DIR}" \
    -ov -format UDZO \
    "${DMG_FILE}"

# Clean up
rm -rf "${DMG_DIR}"

# Get file size
SIZE=$(ls -lh "${DMG_FILE}" | awk '{print $5}')

echo ""
echo "✅ Successfully created: ${DMG_FILE} (${SIZE})"
echo ""
echo "📋 To install:"
echo "   1. Open ${DMG_FILE}"
echo "   2. Drag LauncherHub to Applications"
echo "   3. Open LauncherHub from Applications"
echo ""
echo "⚠️  Note: On first launch, you may need to:"
echo "   Right-click → Open → Open (to bypass Gatekeeper)"
echo "   Or: System Settings → Privacy & Security → Open Anyway"
