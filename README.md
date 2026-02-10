# 🚀 LauncherHub

A lightweight, customizable menu bar launcher for macOS. Quickly access your projects, folders, URLs, and commands from a beautiful, dark-themed popup interface.

![macOS](https://img.shields.io/badge/macOS-12.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.0+-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

- **Menu Bar App** - Lives in your menu bar, always one click away
- **Draggable Groups** - Organize your links into movable groups
- **Drag & Drop Links** - Reorder links within groups or move between groups
- **6 Link Types**:
  - 🎯 **Application** - Launch any macOS app
  - 📂 **VS Code** - Open folders in Visual Studio Code
  - 📁 **Finder** - Open folders or files in Finder
  - 🌐 **Chrome** - Open URLs in Google Chrome
  - 💻 **Terminal/SSH** - Run commands or SSH connections
  - ⚡ **Shell** - Execute shell scripts
- **220+ Icons** - Choose from a huge collection of emoji icons
- **12 Colors** - Customize each link with different colors
- **Smart Path Memory** - Remembers last used folders for each link type
- **Dark Theme** - Modern, eye-friendly dark interface
- **Ultra-Compact UI** - Fits more on screen with optimized spacing
- **Native macOS** - Built with Swift and WebKit, no Electron bloat (~113KB DMG!)

## 📥 Installation

### Download DMG (Recommended)
1. Download the latest `LauncherHub-x.x.x.dmg` from [Releases](../../releases)
2. Open the DMG file
3. Drag **LauncherHub** to **Applications**
4. Open LauncherHub from Applications
5. On first launch: Right-click → Open → Open (to bypass Gatekeeper)

### Build from Source
```bash
git clone https://github.com/yourusername/LauncherHub.git
cd LauncherHub
./build.sh
./run.sh
```

## 🎯 Usage

1. Click the **🚀** icon in the menu bar
2. Click **+ New Group** to create a group
3. Click **+** in a group to add links
4. **Drag groups** by their title bar to rearrange
5. **Click a link** to open it
6. **Double-click a link** to edit it
7. **Right-click** the menu bar icon to quit

## 📸 Screenshots

```
┌─────────────────────────────────────────┐
│  🚀 LauncherHub                    [×]  │
├─────────────────────────────────────────┤
│ ┌─────────────────┐ ┌─────────────────┐ │
│ │ 💼 Work      [+]│ │ 🏠 Personal  [+]│ │
│ ├─────────────────┤ ├─────────────────┤ │
│ │ 📂 Project A    │ │ 📁 Documents    │ │
│ │ 📂 Project B    │ │ 🌐 Gmail        │ │
│ │ 💻 Server SSH   │ │ 🌐 GitHub       │ │
│ └─────────────────┘ └─────────────────┘ │
│                                         │
│            [+ New Group]                │
└─────────────────────────────────────────┘
```

## ⚙️ Requirements

- macOS 12.0 (Monterey) or later
- For VS Code links: [Visual Studio Code](https://code.visualstudio.com/) with `code` command installed
- For Chrome links: Google Chrome browser

## 🛠️ Building

### Prerequisites
- Xcode Command Line Tools: `xcode-select --install`

### Build Commands
```bash
# Build the app
./build.sh

# Run the app
./run.sh

# Create DMG for distribution
./create-dmg.sh

# Sign and notarize (requires Apple Developer account)
source .notarization-credentials.sh
./notarize.sh
```

## 🔐 Code Signing & Notarization

For distribution outside the App Store, you'll need:

1. **Apple Developer Program** ($99/year)
2. **Developer ID certificate** in Keychain
3. **App-specific password** from [appleid.apple.com](https://appleid.apple.com/account/manage)

Create `.notarization-credentials.sh` (git-ignored):
```bash
#!/bin/bash
export APPLE_ID="your-email@example.com"
export APPLE_PASSWORD="xxxx-xxxx-xxxx-xxxx"
export TEAM_ID="YOUR_TEAM_ID"
export DEVELOPER_ID="Developer ID Application: Your Name (TEAM_ID)"
```

Then run:
```bash
source .notarization-credentials.sh
./notarize.sh
```

This will create fully signed and notarized releases:
- `LauncherHub-v1.0.0-notarized.zip`
- `LauncherHub-v1.0.0.dmg`

## 📁 Project Structure

```
LauncherHub/
├── LauncherHub.swift      # Main Swift application
├── Resources/
│   ├── main.html          # Main window HTML/CSS/JS
│   └── dialog.html        # Add/Edit dialog HTML/CSS/JS
├── build.sh               # Build script
├── run.sh                 # Run script
├── create-dmg.sh          # DMG creation script
└── README.md
```

## 🔧 Customization

The UI is built with HTML/CSS/JavaScript, making it easy to customize:

- Edit `Resources/main.html` for the main window appearance
- Edit `Resources/dialog.html` for the add/edit dialog
- Run `./build.sh` after changes

## 📝 Data Storage

Your links and groups are stored in macOS UserDefaults at:
```
~/Library/Preferences/com.launcherhub.app.plist
```

To reset all data:
```bash
defaults delete com.launcherhub.app
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## � Publishing to GitHub

### Initial Setup

```bash
# 1. Initialize git repository (if not done)
cd /path/to/LauncherHub
git init

# 2. Add all files (respects .gitignore)
git add .

# 3. Create first commit
git commit -m "Initial commit - LauncherHub v1.0.0"

# 4. Create repository on GitHub
# Go to https://github.com/new
# Repository name: LauncherHub
# Description: Lightweight menu bar launcher for macOS
# Public repository
# DO NOT initialize with README (we have one)

# 5. Add GitHub remote
git remote add origin https://github.com/YOUR_USERNAME/LauncherHub.git

# 6. Push to GitHub
git branch -M main
git push -u origin main
```

### Creating a Release

```bash
# 1. Build and notarize
source .notarization-credentials.sh
./notarize.sh

# 2. Tag the version
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# 3. Create release on GitHub
# Go to: https://github.com/YOUR_USERNAME/LauncherHub/releases/new
# - Tag: v1.0.0
# - Title: LauncherHub v1.0.0
# - Description: (copy from CHANGELOG or describe features)
# - Upload: LauncherHub-v1.0.0.dmg and LauncherHub-v1.0.0-notarized.zip
# - Click "Publish release"
```

### Repository Setup Checklist

- [x] `.gitignore` configured (credentials excluded)
- [x] `README.md` with features and installation
- [x] `LICENSE` file (MIT)
- [x] Build scripts included
- [x] Notarization script (credentials git-ignored)
- [ ] Add screenshots to README
- [ ] Set repository topics: `macos`, `swift`, `launcher`, `menu-bar`, `productivity`
- [ ] Enable GitHub Discussions (optional)
- [ ] Add `CHANGELOG.md` for version history

### Recommended GitHub Settings

1. **About section**: Add description and website
2. **Topics**: `macos`, `swift`, `webkit`, `launcher`, `menu-bar-app`, `productivity`
3. **Social preview**: Upload a screenshot (1280x640px)
4. **Releases**: Enable for easy downloads
5. **Issues**: Enable for bug reports
6. **Wiki**: Optional, for extended documentation

## �📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with Swift and WebKit
- Icons from Unicode Emoji
- Inspired by the need for a simple, fast launcher

---

Made with ❤️ for the macOS community
