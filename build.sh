#!/bin/bash
cd "$(dirname "$0")"

echo "Building LauncherHub.app..."

# Compile
swiftc -o LauncherHub LauncherHub.swift -framework Cocoa -framework WebKit 2>&1
if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

# Create app bundle
rm -rf LauncherHub.app
mkdir -p LauncherHub.app/Contents/MacOS
mkdir -p LauncherHub.app/Contents/Resources

mv LauncherHub LauncherHub.app/Contents/MacOS/

# Copy HTML resources
cp Resources/*.html LauncherHub.app/Contents/Resources/

cat > LauncherHub.app/Contents/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>LauncherHub</string>
    <key>CFBundleIdentifier</key>
    <string>com.launcherhub.app</string>
    <key>CFBundleName</key>
    <string>LauncherHub</string>
    <key>CFBundleDisplayName</key>
    <string>LauncherHub</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2024 LauncherHub. MIT License.</string>
</dict>
</plist>
EOF

# Copy icon if exists
if [ -f "LauncherHub.icns" ]; then
    cp LauncherHub.icns LauncherHub.app/Contents/Resources/AppIcon.icns
    /usr/libexec/PlistBuddy -c "Add :CFBundleIconFile string AppIcon" LauncherHub.app/Contents/Info.plist 2>/dev/null || true
fi

echo "✅ Build successful! LauncherHub.app created"
