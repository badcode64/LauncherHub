# 🚀 LauncherHub

A lightweight, customizable menu bar launcher for macOS. Quick access to apps, folders, URLs, and commands from a beautiful dark-themed interface.

![macOS](https://img.shields.io/badge/macOS-12.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.0+-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

- **Menu Bar Integration** - Always accessible, one click away
- **6 Link Types**:
  - 🎯 **Applications** - Launch any macOS app
  - 📂 **VS Code** - Open folders in Visual Studio Code
  - 📁 **Finder** - Open folders or files
  - 🌐 **Chrome** - Open URLs in Google Chrome
  - 💻 **Terminal** - SSH connections and commands
  - ⚡ **Shell** - Execute shell scripts
- **Drag & Drop** - Reorder links within groups or move between groups
- **Smart Path Memory** - Remembers last used folder for each type
- **Dark Theme** - Modern, eye-friendly interface
- **Ultra-Compact UI** - 180px wide groups, optimized spacing
- **220+ Emoji Icons** - Huge icon collection
- **12 Color Schemes** - Customize each link
- **Native Swift** - No Electron, only ~113KB DMG!

## 📥 Installation

### Download
1. Download the latest **LauncherHub.dmg** from [Releases](https://github.com/badcode64/LauncherHub/releases)
2. Open the DMG file
3. Drag **LauncherHub** to **Applications** folder
4. Launch LauncherHub from Applications
5. **First launch**: Right-click → Open → Open (to bypass Gatekeeper)

### Build from Source
```bash
git clone https://github.com/badcode64/LauncherHub.git
cd LauncherHub
./build.sh
./run.sh
```

## 🎯 Usage

1. Click the **🚀** icon in the menu bar
2. Click **+ New Group** to create a group
3. Click **+** in a group to add links
4. **Drag groups** by their title bar to rearrange
5. **Drag links** to reorder or move between groups
6. **Click a link** to execute
7. **Click the edit button** (✎) to modify

## ⚙️ Requirements

- macOS 12.0 (Monterey) or later
- For VS Code links: Visual Studio Code with `code` command
- For Chrome links: Google Chrome browser

## 🔧 Building

### Prerequisites
```bash
xcode-select --install
```

### Commands
```bash
# Build
./build.sh

# Run
./run.sh

# Create DMG
./create-dmg.sh
```

## 📄 License

MIT License - see [LICENSE](LICENSE) file

## 🙏 Acknowledgments

Built with Swift and WebKit for the macOS community.

---

Made with ❤️ by [BadCode64](https://github.com/badcode64)
