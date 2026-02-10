import Cocoa
import WebKit

// MARK: - Data Model

struct QuickLink: Codable {
    var id: String
    var title: String
    var icon: String
    var color: String
    var actionType: String
    var payload: String
    
    init(title: String, icon: String = "🔗", color: String = "#3b82f6", actionType: String = "Finder", payload: String = "") {
        self.id = UUID().uuidString
        self.title = title
        self.icon = icon
        self.color = color
        self.actionType = actionType
        self.payload = payload
    }
}

struct LinkGroup: Codable {
    var id: String
    var title: String
    var x: Int
    var y: Int
    var links: [QuickLink]
    
    init(title: String, x: Int, y: Int, links: [QuickLink] = []) {
        self.id = UUID().uuidString
        self.title = title
        self.x = x
        self.y = y
        self.links = links
    }
}

// MARK: - Script Message Handler

class WebHandler: NSObject, WKScriptMessageHandler {
    weak var delegate: AppDelegate?
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any],
              let action = body["action"] as? String else { return }
        
        DispatchQueue.main.async {
            switch action {
            case "click":
                if let linkId = body["linkId"] as? String {
                    self.delegate?.executeLink(linkId: linkId)
                }
            case "addLink":
                if let groupId = body["groupId"] as? String {
                    self.delegate?.showAddDialog(groupId: groupId)
                }
            case "editLink":
                if let linkId = body["linkId"] as? String, let groupId = body["groupId"] as? String {
                    self.delegate?.showEditDialog(groupId: groupId, linkId: linkId)
                }
            case "moveGroup":
                if let groupId = body["groupId"] as? String,
                   let x = body["x"] as? Int,
                   let y = body["y"] as? Int {
                    self.delegate?.moveGroup(groupId: groupId, x: x, y: y)
                }
            case "moveLink":
                if let linkId = body["linkId"] as? String,
                   let fromGroupId = body["fromGroupId"] as? String,
                   let toGroupId = body["toGroupId"] as? String {
                    self.delegate?.moveLink(linkId: linkId, fromGroupId: fromGroupId, toGroupId: toGroupId)
                }
            case "reorderLink":
                if let groupId = body["groupId"] as? String,
                   let linkId = body["linkId"] as? String,
                   let newIndex = body["newIndex"] as? Int {
                    self.delegate?.reorderLink(groupId: groupId, linkId: linkId, newIndex: newIndex)
                }
            case "addGroup":
                self.delegate?.showAddGroupDialog()
            case "editGroup":
                if let groupId = body["groupId"] as? String {
                    self.delegate?.showEditGroupDialog(groupId: groupId)
                }
            case "deleteGroup":
                if let groupId = body["groupId"] as? String {
                    self.delegate?.deleteGroup(groupId: groupId)
                }
            case "quit":
                NSApp.terminate(nil)
            default:
                break
            }
        }
    }
}

// MARK: - Dialog WebView Handler

class DialogHandler: NSObject, WKScriptMessageHandler {
    weak var delegate: AppDelegate?
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any],
              let action = body["action"] as? String else { return }
        
        DispatchQueue.main.async {
            switch action {
            case "browse":
                if let actionType = body["actionType"] as? String {
                    self.delegate?.browseFolder(for: actionType)
                } else {
                    self.delegate?.browseFolder(for: "Finder")
                }
            case "browseApp":
                self.delegate?.browseApp()
            case "save":
                self.delegate?.saveFromDialog(body)
            case "cancel":
                self.delegate?.cancelDialog()
            case "delete":
                self.delegate?.deleteFromDialog()
            case "duplicate":
                self.delegate?.duplicateFromDialog(body)
            default:
                break
            }
        }
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var mainWindow: NSWindow!
    var webView: WKWebView!
    var groups: [LinkGroup] = []
    var webHandler = WebHandler()
    var dialogHandler = DialogHandler()
    var currentGroupId: String?
    var currentLinkId: String?
    var dialogWindow: NSWindow?
    var dialogWebView: WKWebView?
    var isEditMode = false
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        webHandler.delegate = self
        dialogHandler.delegate = self
        loadData()
        setupStatusBar()
        createWindow()
        
        // Show window immediately on launch
        mainWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.title = "🚀"
            button.action = #selector(toggleWindow)
            button.target = self
            button.sendAction(on: [.leftMouseDown])
        }
    }
    
    @objc func toggleWindow() {
        if mainWindow.isVisible && NSApp.isActive {
            mainWindow.orderOut(nil)
        } else {
            NSApp.activate(ignoringOtherApps: true)
            mainWindow.makeKeyAndOrderFront(nil)
        }
    }
    
    func createWindow() {
        mainWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 900, height: 650),
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        mainWindow.title = "Shortcuts Manager"
        mainWindow.center()
        mainWindow.isReleasedWhenClosed = false
        mainWindow.minSize = NSSize(width: 600, height: 400)
        
        let config = WKWebViewConfiguration()
        config.userContentController.add(webHandler, name: "swift")
        
        webView = WKWebView(frame: mainWindow.contentView!.bounds, configuration: config)
        webView.autoresizingMask = [.width, .height]
        mainWindow.contentView?.addSubview(webView)
        
        refreshWebView()
    }
    
    func refreshWebView() {
        let html = generateHTML()
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    // MARK: - HTML Generation
    
    func generateHTML() -> String {
        let groupsJSON = (try? JSONEncoder().encode(groups)).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        
        // Load from external HTML file
        if let htmlPath = Bundle.main.path(forResource: "main", ofType: "html"),
           let htmlTemplate = try? String(contentsOfFile: htmlPath, encoding: .utf8) {
            return htmlTemplate.replacingOccurrences(of: "{{GROUPS_JSON}}", with: groupsJSON)
        }
        
        // Fallback if file not found
        return "<html><body><h1>Error: main.html not found</h1></body></html>"
    }
    
    // MARK: - Actions from WebView
    
    func executeLink(linkId: String) {
        print("DEBUG: executeLink called with linkId: \(linkId)")
        for group in groups {
            if let link = group.links.first(where: { $0.id == linkId }) {
                let payload = link.payload
                print("DEBUG: Found link - type: \(link.actionType), payload: \(payload)")
                switch link.actionType {
                case "App":
                    runProcess("/usr/bin/open", ["-a", payload])
                case "VS Code":
                    runProcess("/usr/bin/open", ["-a", "Visual Studio Code", payload])
                case "Finder":
                    runProcess("/usr/bin/open", [payload])
                case "Chrome":
                    runProcess("/usr/bin/open", ["-a", "Google Chrome", payload])
                case "Terminal":
                    print("DEBUG: Executing Terminal command...")
                    // Use osascript to run command in Terminal
                    let escapedPayload = payload.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"")
                    print("DEBUG: Escaped payload: \(escapedPayload)")
                    let p = Process()
                    p.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
                    p.arguments = [
                        "-e", "tell application \"Terminal\"",
                        "-e", "activate",
                        "-e", "do script \"\(escapedPayload)\"",
                        "-e", "end tell"
                    ]
                    do {
                        try p.run()
                        print("DEBUG: osascript process started")
                    } catch {
                        print("DEBUG: osascript error: \(error)")
                    }
                case "Shell":
                    runProcess("/bin/zsh", ["-l", "-c", payload])
                default:
                    print("DEBUG: Unknown action type: \(link.actionType)")
                    break
                }
                return
            }
        }
        print("DEBUG: Link not found!")
    }
    
    func runProcess(_ path: String, _ args: [String]) {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: path)
        p.arguments = args
        try? p.run()
    }
    
    func moveGroup(groupId: String, x: Int, y: Int) {
        if let idx = groups.firstIndex(where: { $0.id == groupId }) {
            groups[idx].x = x
            groups[idx].y = y
            saveData()
        }
    }
    
    func moveLink(linkId: String, fromGroupId: String, toGroupId: String) {
        guard let fromIdx = groups.firstIndex(where: { $0.id == fromGroupId }),
              let toIdx = groups.firstIndex(where: { $0.id == toGroupId }),
              let linkIdx = groups[fromIdx].links.firstIndex(where: { $0.id == linkId }) else { return }
        
        let link = groups[fromIdx].links.remove(at: linkIdx)
        groups[toIdx].links.append(link)
        saveData()
    }
    
    func reorderLink(groupId: String, linkId: String, newIndex: Int) {
        guard let groupIdx = groups.firstIndex(where: { $0.id == groupId }),
              let linkIdx = groups[groupIdx].links.firstIndex(where: { $0.id == linkId }) else { return }
        
        let link = groups[groupIdx].links.remove(at: linkIdx)
        let safeIndex = min(newIndex, groups[groupIdx].links.count)
        groups[groupIdx].links.insert(link, at: safeIndex)
        saveData()
    }
    
    // MARK: - Dialogs
    
    func showAddGroupDialog() {
        let alert = NSAlert()
        alert.messageText = "Add New Group"
        alert.addButton(withTitle: "Add")
        alert.addButton(withTitle: "Cancel")
        
        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 250, height: 24))
        input.placeholderString = "Group name"
        alert.accessoryView = input
        
        if alert.runModal() == .alertFirstButtonReturn {
            let title = input.stringValue.trimmingCharacters(in: CharacterSet.whitespaces)
            if !title.isEmpty {
                let newGroup = LinkGroup(title: title, x: 50 + groups.count * 30, y: 50 + groups.count * 30)
                groups.append(newGroup)
                saveData()
                refreshWebView()
            }
        }
    }
    
    func showEditGroupDialog(groupId: String) {
        guard let idx = groups.firstIndex(where: { $0.id == groupId }) else { return }
        
        let alert = NSAlert()
        alert.messageText = "Edit Group"
        alert.addButton(withTitle: "Save")
        alert.addButton(withTitle: "Cancel")
        
        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 250, height: 24))
        input.stringValue = groups[idx].title
        alert.accessoryView = input
        
        if alert.runModal() == .alertFirstButtonReturn {
            let title = input.stringValue.trimmingCharacters(in: CharacterSet.whitespaces)
            if !title.isEmpty {
                groups[idx].title = title
                saveData()
                refreshWebView()
            }
        }
    }
    
    func deleteGroup(groupId: String) {
        let alert = NSAlert()
        alert.messageText = "Delete this group?"
        alert.informativeText = "All links in this group will be deleted."
        alert.addButton(withTitle: "Delete")
        alert.addButton(withTitle: "Cancel")
        
        if alert.runModal() == .alertFirstButtonReturn {
            groups.removeAll { $0.id == groupId }
            saveData()
            refreshWebView()
        }
    }
    
    func showAddDialog(groupId: String) {
        currentGroupId = groupId
        currentLinkId = nil
        isEditMode = false
        showLinkDialog(link: nil)
    }
    
    func showEditDialog(groupId: String, linkId: String) {
        guard let gi = groups.firstIndex(where: { $0.id == groupId }),
              let li = groups[gi].links.firstIndex(where: { $0.id == linkId }) else { return }
        
        currentGroupId = groupId
        currentLinkId = linkId
        isEditMode = true
        showLinkDialog(link: groups[gi].links[li])
    }
    
    func showLinkDialog(link: QuickLink?) {
        dialogWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 700, height: 580),
            styleMask: [.titled],
            backing: .buffered,
            defer: false
        )
        dialogWindow?.title = link == nil ? "Add New Link" : "Edit Link"
        
        let config = WKWebViewConfiguration()
        config.userContentController.add(dialogHandler, name: "swift")
        
        dialogWebView = WKWebView(frame: dialogWindow!.contentView!.bounds, configuration: config)
        dialogWebView?.autoresizingMask = [.width, .height]
        dialogWindow?.contentView?.addSubview(dialogWebView!)
        
        let html = generateDialogHTML(link: link, showDelete: isEditMode)
        dialogWebView?.loadHTMLString(html, baseURL: nil)
        
        mainWindow.beginSheet(dialogWindow!) { _ in }
    }
    
    func generateDialogHTML(link: QuickLink?, showDelete: Bool) -> String {
        let linkJSON = link.flatMap { try? JSONEncoder().encode($0) }.flatMap { String(data: $0, encoding: .utf8) } ?? "null"
        let dialogTitle = link == nil ? "Add New Link" : "Edit Link"
        var editButtons = ""
        if showDelete {
            editButtons = "<button class='btn btn-delete' onclick='deleteLink()'>Delete</button><button class='btn btn-duplicate' onclick='duplicateLink()'>Duplicate</button>"
        }
        
        // Load from external HTML file
        if let htmlPath = Bundle.main.path(forResource: "dialog", ofType: "html"),
           let htmlTemplate = try? String(contentsOfFile: htmlPath, encoding: .utf8) {
            return htmlTemplate
                .replacingOccurrences(of: "{{DIALOG_TITLE}}", with: dialogTitle)
                .replacingOccurrences(of: "{{LINK_JSON}}", with: linkJSON)
                .replacingOccurrences(of: "{{EDIT_BUTTONS}}", with: editButtons)
        }
        
        // Fallback if file not found
        return "<html><body><h1>Error: dialog.html not found</h1></body></html>"
    }
    
    func browseFolder(for actionType: String) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        
        // Restore last used path for this action type
        let lastPathKey = "lastBrowsePath_\(actionType)"
        if let lastPath = UserDefaults.standard.string(forKey: lastPathKey) {
            panel.directoryURL = URL(fileURLWithPath: lastPath)
        }
        
        if panel.runModal() == .OK, let url = panel.url {
            let path = url.path
            // Save the selected path for next time
            UserDefaults.standard.set(path, forKey: lastPathKey)
            dialogWebView?.evaluateJavaScript("setPath('\(path.replacingOccurrences(of: "'", with: "\\'"))')", completionHandler: nil)
        }
    }
    
    func browseApp() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.application]
        
        // Restore last used path for apps
        let lastPathKey = "lastBrowsePath_App"
        if let lastPath = UserDefaults.standard.string(forKey: lastPathKey) {
            panel.directoryURL = URL(fileURLWithPath: lastPath)
        } else {
            panel.directoryURL = URL(fileURLWithPath: "/Applications")
        }
        
        if panel.runModal() == .OK, let url = panel.url {
            // Save the parent directory for next time
            let parentPath = url.deletingLastPathComponent().path
            UserDefaults.standard.set(parentPath, forKey: lastPathKey)
            
            let appName = url.deletingPathExtension().lastPathComponent
            dialogWebView?.evaluateJavaScript("setAppName('\(appName.replacingOccurrences(of: "'", with: "\\'"))')", completionHandler: nil)
        }
    }
    
    func saveFromDialog(_ data: [String: Any]) {
        guard let title = data["title"] as? String,
              let actionType = data["actionType"] as? String,
              let payload = data["payload"] as? String,
              let icon = data["icon"] as? String,
              let color = data["color"] as? String,
              let groupId = currentGroupId else { return }
        
        if let linkId = currentLinkId {
            // Edit existing
            if let gi = groups.firstIndex(where: { $0.id == groupId }),
               let li = groups[gi].links.firstIndex(where: { $0.id == linkId }) {
                groups[gi].links[li].title = title
                groups[gi].links[li].actionType = actionType
                groups[gi].links[li].payload = payload
                groups[gi].links[li].icon = icon
                groups[gi].links[li].color = color
            }
        } else {
            // Add new
            let link = QuickLink(title: title, icon: icon, color: color, actionType: actionType, payload: payload)
            if let gi = groups.firstIndex(where: { $0.id == groupId }) {
                groups[gi].links.append(link)
            }
        }
        
        saveData()
        closeDialog()
        refreshWebView()
    }
    
    func cancelDialog() {
        closeDialog()
    }
    
    func deleteFromDialog() {
        let alert = NSAlert()
        alert.messageText = "Delete this link?"
        alert.informativeText = "This cannot be undone."
        alert.addButton(withTitle: "Delete")
        alert.addButton(withTitle: "Cancel")
        
        if alert.runModal() == .alertFirstButtonReturn {
            if let groupId = currentGroupId, let linkId = currentLinkId {
                if let gi = groups.firstIndex(where: { $0.id == groupId }) {
                    groups[gi].links.removeAll { $0.id == linkId }
                    saveData()
                }
            }
            closeDialog()
            refreshWebView()
        }
    }
    
    func duplicateFromDialog(_ body: [String: Any]) {
        guard let groupId = currentGroupId,
              let title = body["title"] as? String,
              let actionType = body["actionType"] as? String,
              let payload = body["payload"] as? String,
              let icon = body["icon"] as? String,
              let color = body["color"] as? String else { return }
        
        let newLink = QuickLink(title: title, icon: icon, color: color, actionType: actionType, payload: payload)
        
        if let gi = groups.firstIndex(where: { $0.id == groupId }) {
            groups[gi].links.append(newLink)
            saveData()
        }
        
        closeDialog()
        refreshWebView()
    }
    
    func closeDialog() {
        if let dw = dialogWindow {
            mainWindow.endSheet(dw)
            dialogWindow = nil
            dialogWebView = nil
        }
    }
    // MARK: - Persistence
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "shortcutGroups"),
           let decoded = try? JSONDecoder().decode([LinkGroup].self, from: data) {
            groups = decoded
        } else {
            groups = defaultGroups()
            saveData()
        }
    }
    
    func saveData() {
        if let data = try? JSONEncoder().encode(groups) {
            UserDefaults.standard.set(data, forKey: "shortcutGroups")
        }
    }
    
    func defaultGroups() -> [LinkGroup] {
        return [
            LinkGroup(title: "VSCode", x: 20, y: 20, links: [
                QuickLink(title: "Project01", icon: "📊", color: "#3b82f6", actionType: "VS Code", payload: "/Users"),
                QuickLink(title: "[BCKeys]", icon: "➕", color: "#22c55e", actionType: "VS Code", payload: "/Users"),
                QuickLink(title: "Config Files", icon: "📄", color: "#f97316", actionType: "Finder", payload: "/Users"),
                QuickLink(title: "Dev Docs", icon: "📝", color: "#a855f7", actionType: "Chrome", payload: "https://developer.apple.com")
            ]),
            LinkGroup(title: "Servers", x: 280, y: 20, links: [
                QuickLink(title: "192.168.1.10", icon: "💻", color: "#14b8a6", actionType: "Terminal", payload: "ssh user@192.168.1.10"),
                QuickLink(title: "DB Server", icon: "🗄️", color: "#ef4444", actionType: "Terminal", payload: "ssh db@server"),
                QuickLink(title: "AWS Console", icon: "☁️", color: "#eab308", actionType: "Chrome", payload: "https://aws.amazon.com/console"),
                QuickLink(title: "Prod Website", icon: "🌐", color: "#22c55e", actionType: "Chrome", payload: "https://example.com")
            ]),
            LinkGroup(title: "Segédappok", x: 540, y: 20, links: [
                QuickLink(title: "Képernyőfotó", icon: "📷", color: "#ec4899", actionType: "Shell", payload: "screencapture -i ~/Desktop/screenshot.png"),
                QuickLink(title: "Szöveg Converter", icon: "📦", color: "#14b8a6", actionType: "Finder", payload: "/Applications"),
                QuickLink(title: "SQL Tool", icon: "💿", color: "#3b82f6", actionType: "Finder", payload: "/Applications"),
                QuickLink(title: "Automator Script", icon: "⚙️", color: "#a855f7", actionType: "Shell", payload: "automator ~/Scripts/myscript.workflow")
            ]),
            LinkGroup(title: "Munka", x: 20, y: 300, links: [
                QuickLink(title: "Kliens Projekt", icon: "📧", color: "#3b82f6", actionType: "VS Code", payload: "/Users"),
                QuickLink(title: "Feladatok", icon: "🚀", color: "#ec4899", actionType: "Chrome", payload: "https://trello.com"),
                QuickLink(title: "Meeting Link", icon: "📩", color: "#22c55e", actionType: "Chrome", payload: "https://meet.google.com"),
                QuickLink(title: "Jegyzetek", icon: "📍", color: "#f97316", actionType: "Finder", payload: "~/Documents/Notes")
            ])
        ]
    }
}

// MARK: - NSColor Extension

extension NSColor {
    convenience init(hex: String) {
        var hexStr = hex.trimmingCharacters(in: CharacterSet.whitespaces)
        if hexStr.hasPrefix("#") {
            hexStr.removeFirst()
        }
        
        var rgb: UInt64 = 0
        Scanner(string: hexStr).scanHexInt64(&rgb)
        
        let r = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let g = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let b = CGFloat(rgb & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}

// MARK: - Entry Point

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
