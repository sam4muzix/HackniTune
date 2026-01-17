import SwiftUI
import AppKit

// MARK: - Main App Entry
@main
struct HackinTuneApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            SetupView()
                .frame(width: 1000, height: 750)
                .background(Color(NSColor.windowBackgroundColor))
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowResizability(.contentSize)
        .commands {
            // Remove default commands if needed
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.windows.first?.center()
        NSApp.windows.first?.title = "Greenmix Futech - HackinTune Lifecycle"
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

// MARK: - Theme
struct GreenmixTheme {
    static let bg = Color(red: 0.1, green: 0.1, blue: 0.12)
    static let card = Color(red: 0.15, green: 0.15, blue: 0.18)
    static let accent = Color(red: 0.2, green: 0.8, blue: 0.4) // Greenmix Green
    static let gold = Color(red: 0.9, green: 0.8, blue: 0.4)
    static let text = Color.white
    static let secondary = Color.gray
}

// MARK: - Components

struct DashboardButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)
                    .frame(height: 40)
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(GreenmixTheme.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isHovering ? color.opacity(0.8) : Color.clear, lineWidth: 2)
                    )
            )
            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 4)
            .scaleEffect(isHovering ? 1.02 : 1.0)
            .animation(.spring(), value: isHovering)
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hover in
            isHovering = hover
        }
    }
}

// MARK: - Components

struct CommonHeader: View {
    var title: String = ""
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                if let path = Bundle.main.path(forResource: "logo", ofType: "png"),
                   let image = NSImage(contentsOfFile: path) {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 30)
                }
                
                Text("HackinTune")
                    .font(.largeTitle).fontWeight(.heavy)
                    .foregroundColor(GreenmixTheme.text)
                Spacer()
                Text("Powered by Greenmix Futech")
                    .font(.subheadline)
                    .foregroundColor(GreenmixTheme.accent)
            }
            if !title.isEmpty {
                 Text(title)
                     .font(.title2).bold()
                     .foregroundColor(.gray)
            }
            Divider().background(GreenmixTheme.accent)
        }
        .padding(.horizontal)
        .padding(.top)
    }
}


struct ContentView: View {
    var mode: SetupView.AppMode = .preInstall
    var onBack: () -> Void
    @State private var activeSheet: SheetType? = nil
    @State private var showingAudit = false
    @State private var auditReport = "Scanning..."
    
    enum SheetType: Identifiable {
        case picker, audit, support, fixPrompt([String]), textInfo(String, String)
        var id: Int {
            switch self {
            case .picker: return 1
            case .audit: return 2
            case .support: return 3
            case .fixPrompt: return 4
            case .textInfo: return 5
            }
        }
    }
    
    var body: some View {
        ZStack {
            GreenmixTheme.bg.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // ... (Detail omitted for brevity, logic unchanged) ...
                // Header
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(GreenmixTheme.accent)
                    }
                    .buttonStyle(PlainButtonStyle())

                    VStack(alignment: .leading) {
                        Text(mode == .preInstall ? "Pre-Install Builder" : "System Optimizer")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(GreenmixTheme.text)
                        Text("Powered by Greenmix Futech, Chennai")
                            .font(.headline)
                            .foregroundColor(GreenmixTheme.accent)
                    }
                    Spacer()
                    Image(systemName: mode == .preInstall ? "externaldrive" : "wrench.and.screwdriver")
                        .font(.system(size: 40))
                        .foregroundColor(GreenmixTheme.gold)
                }
                .padding(.horizontal, 30)
                .padding(.top, 30)
                
                Divider().background(Color.gray.opacity(0.3))
                
                if mode == .preInstall {
                    PreInstallDashboard(onBack: onBack)
                } else {
                // Grid (Main Features - 2 Rows of 3)
                LazyVGrid(columns: [

                    GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
                ], spacing: 20) {
                    
                    // Row 1
                    DashboardButton(title: "System Audit", subtitle: "Inspect Hardware & Config", icon: "doc.text.magnifyingglass", color: .blue) {
                        runAudit()
                    }
                    
                    DashboardButton(title: "Build PC", subtitle: "Golden Build Recommender", icon: "pc", color: GreenmixTheme.gold) {
                        activeSheet = .picker
                    }
                    
                    DashboardButton(title: "Clean Kexts", subtitle: "Remove Bloat & Backup", icon: "trash.circle", color: .red) {
                        runCleanup()
                    }
                    
                    // Row 2
                    DashboardButton(title: "Mount EFI", subtitle: "Open EFI Parition", icon: "internaldrive", color: .orange) {
                        mountEFI()
                    }
                    
                    DashboardButton(title: "Backup EFI", subtitle: "Zip EFI to Docs", icon: "externaldrive.badge.plus", color: .green) {
                        backupEFI()
                    }
                    
                    DashboardButton(title: "Validate", subtitle: "Dortania Checks", icon: "checkmark.shield", color: .purple) {
                        validateSystem()
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 10)
                }

                
                Spacer()
                
                // Secondary Actions (Support & Exit)
                HStack(spacing: 20) {
                    DashboardButton(title: "Support", subtitle: "Donate / UPI", icon: "heart.circle.fill", color: .pink) {
                        activeSheet = .support
                    }
                    .frame(height: 80) // Slightly smaller for footer
                    
                    DashboardButton(title: "Exit", subtitle: "Close App", icon: "power.circle.fill", color: .gray) {
                        NSApplication.shared.terminate(nil)
                    }
                    .frame(height: 80)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 10)
                
                // Footer
                VStack(spacing: 5) {
                    Text("⚠️ Note: Keep Internet Connected for latest Fixes & Updates")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("Dev: @shyam4muzix | v5.5")
                        .font(.caption2)
                        .foregroundColor(GreenmixTheme.accent.opacity(0.6))
                }
                .padding(.bottom)
            }
        }
        .sheet(item: $activeSheet) { item in
            switch item {
            case .picker:
                HardwarePickerView()
            case .audit:
                Text("Audit running...")
            case .support:
                SupportView()
            case .fixPrompt(let issues):
                VStack(spacing: 20) {
                    Text("Issues Detected").font(.title).foregroundColor(.red)
                    Divider()
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(issues, id: \.self) { i in 
                                Text(i)
                                    .foregroundColor(.white)
                                    .font(.headline)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                    
                    Divider()
                    
                    Text("HackinTune can fix these safely.")
                    Text("NOTE: We will backup your EFI first.").font(.caption).foregroundColor(.gray)
                    
                    HStack {
                        Button("Cancel") { activeSheet = nil }
                            .padding()
                        Button("Backup & Fix") {
                            activeSheet = nil
                            applyFixes(issues)
                        }
                        .padding()
                        .background(Color.blue) // Changed to Blue for better contrast
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .font(.headline)
                    }
                }
                .padding()
                .frame(width: 450, height: 450) // Increased height
                .background(GreenmixTheme.card)
                .cornerRadius(12)
                .shadow(radius: 20)
            case .textInfo(let title, let msg):
                VStack(spacing: 20) {
                    Text(title).font(.title2).bold()
                    ScrollView { Text(msg).font(.body) }
                    Button("Close") { activeSheet = nil }
                }
                .padding()
                .frame(width: 500, height: 400)
            }
        }
    }
    
    // MARK: - Logic
    
    func runCommand(_ cmd: String) -> String {
        let task = Process()
        let pipe = Pipe()
        task.standardOutput = pipe
        task.arguments = ["-c", cmd]
        task.launchPath = "/bin/bash"
        task.launch()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    
    func runAudit() {
        activeSheet = .audit // Show loading state
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Run expensive commands in background
            let serial = self.runCommand("system_profiler SPHardwareDataType | grep 'Serial Number' | awk -F ': ' '{print $2}'")
            let modelId = self.runCommand("sysctl -n hw.model")
            let boardId = self.runCommand("ioreg -l | grep board-id | awk -F '\"' '{print $4}'")
            let biosVer = self.runCommand("sysctl -n machdep.cpu.microcode_version") // Approximation or use system_profiler
            let macVer = self.runCommand("sw_vers -productVersion")
            let buildVer = self.runCommand("sw_vers -buildVersion")
            
            let cpu = self.runCommand("sysctl -n machdep.cpu.brand_string")
            let gpu = self.runCommand("system_profiler SPDisplaysDataType | grep 'Chipset Model' | awk -F ': ' '{print $2}' | xargs")
            let vram = self.runCommand("system_profiler SPDisplaysDataType | grep 'VRAM' | awk -F ': ' '{print $2}' | xargs")
            
            let ram = self.runCommand("sysctl -n hw.memsize | awk '{print $0/1073741824 \" GB\"}'")
            let ramDetails = self.runCommand("system_profiler SPMemoryDataType | grep 'Speed' | head -1 | awk -F ': ' '{print $2}'")
            
            let audio = self.runCommand("system_profiler SPAudioDataType | grep '        ' | grep ':' | sed 's/:$//' | xargs")
            let network = self.runCommand("networksetup -listallhardwareports | grep 'Device' -B 1 | grep 'Hardware Port' | awk -F ': ' '{print $2}' | xargs")
            
            let trim = self.runCommand("system_profiler SPStorageDataType | grep 'TRIM Support' | head -1 | awk -F ': ' '{print $2}'")
            
            let report = """
            DEEP SYSTEM HARDWARE AUDIT
            ==========================
            
            [SYSTEM IDENTITY]
            • Model:        \(modelId)
            • Serial:       \(serial)
            • Board ID:     \(boardId)
            • macOS:        \(macVer) (\(buildVer))
            
            [PROCESSOR]
            • CPU:          \(cpu)
            
            [GRAPHICS]
            • GPU:          \(gpu)
            • VRAM:         \(vram)
            
            [MEMORY]
            • RAM Size:     \(ram)
            • Speed:        \(ramDetails)
            
            [STORAGE]
            • TRIM:         \(trim)
            
            [PERIPHERALS]
            • Audio:        \(audio.isEmpty ? "No Devices Found" : audio)
            • Network:      \(network)
            """
            
            DispatchQueue.main.async {
                self.activeSheet = .textInfo("Deep System Audit", report)
            }
        }
    }
    
    // ... (rest of code) ...

    
    func mountEFI() {
        _ = runCommand("if [ ! -d '/Volumes/EFI/EFI' ]; then diskutil mount disk0s1; fi")
        _ = runCommand("open /Volumes/EFI")
    }
    
    func backupEFI() {
        let date = runCommand("date +%Y%m%d_%H%M%S")
        let dest = "~/Documents/Hackintosh_Backups/EFI_Backup_\(date).zip"
        _ = runCommand("mkdir -p ~/Documents/Hackintosh_Backups")
        _ = runCommand("cd /Volumes/EFI && zip -r -q \(dest) EFI")
        activeSheet = .textInfo("Backup Complete", "Saved to: \(dest)")
    }
    
    func validateSystem() {
        // 1. Run Checks
        let net = runCommand("ping -c 1 google.com > /dev/null && echo 'OK' || echo 'FAIL'")
        let trim = runCommand("system_profiler SPStorageDataType | grep 'TRIM Support' | head -1 | grep 'Yes' > /dev/null && echo 'OK' || echo 'FAIL'")
        let sip = runCommand("csrutil status | grep 'disabled' > /dev/null && echo 'OK' || echo 'FAIL'")
        
        var issues: [String] = []
        if net == "FAIL" { issues.append("- Network Offline") }
        if trim == "FAIL" { issues.append("- TRIM Disabled (SSD Speed/Life Risk)") }
        if sip == "FAIL" { issues.append("- SIP Enabled (May block unsigned Kexts)") }
        
        let report = """
        VALIDATION REPORT
        -----------------
        Network: \(net == "OK" ? "✅ Online" : "❌ Offline")
        TRIM:    \(trim == "OK" ? "✅ Enabled" : "❌ Disabled")
        SIP:     \(sip == "OK" ? "✅ Disabled (Good)" : "⚠️ Enabled (Caution)")
        """
        
        if issues.isEmpty {
            activeSheet = .textInfo("System Healthy", report + "\n\nNo critical issues found.")
        } else {
            // Issues Found -> Prompt Fix
            let fixMsg = report + "\n\nIssues Found:\n" + issues.joined(separator: "\n") + "\n\nWould you like to auto-fix applicable issues?"
            // In a real app we'd use an Alert with Button Actions. For this simplified view state:
            activeSheet = .textInfo("Issues Found", fixMsg)
            // Note: In this simple grid UI, we can trigger a follow-up. 
            // For now, let's inform user to use 'Clean/Fix' tools manually or we can automate.
            // Requirement: "Validate should also give Fix solutions... backup ... apply".
            // Since .textInfo is static, let's auto-transition or add a "Fix" button in a new sheet type.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Changing state to a Fix Prompt
                self.activeSheet = .fixPrompt(issues)
            }
        }
    }
    
    func runCleanup() {
        let script = "do shell script \"rm -rf /Volumes/EFI/EFI/OC/Kexts/IntelMausi.kext\" with administrator privileges"
        var error: NSDictionary?
        if let appleScript = NSAppleScript(source: script) {
            appleScript.executeAndReturnError(&error)
            if error == nil {
                activeSheet = .textInfo("Success", "Cleanup command sent. Please reboot if changed.")
            } else {
                activeSheet = .textInfo("Info", "Cleanup canceled or failed.")
            }
        }
    }
    
    func applyFixes(_ issues: [String]) {
        var fixLog = ""
        
        // 1. Force Backup Prompt
        let backup = runCommand("osascript -e 'button returned of (display dialog \"Safety First! Connect a USB Drive.\\n\\nBacking up EFI before applying fixes.\" buttons {\"Cancel\", \"Backup & Fix\"} default button \"Backup & Fix\" with icon caution)'")
        
        if backup.contains("Backup") {
            // Run Backup
            backupEFI() // Existing function
            
            // Apply Fixes
            if issues.contains(where: { $0.contains("TRIM") }) {
                _ = runCommand("sudo trimforce enable") // Requires interactive y/n usually, might skip for safety or use 'echo y | ...'
                 fixLog += "Attempted TRIM Enable (Reboot required).\n"
            }
            if issues.contains(where: { $0.contains("SIP") }) {
                fixLog += "SIP cannot be disabled from OS. Boot into Recovery -> Terminal -> 'csrutil disable'.\n"
            }
            if issues.contains(where: { $0.contains("Network") }) {
                _ = runCommand("sudo ifconfig en0 down && sudo ifconfig en0 up")
                fixLog += "Reset Network Interface.\n"
            }
            
            activeSheet = .textInfo("Fixes Applied", fixLog + "\nPlease Reboot to take effect.")
        }
    }
}

// MARK: - Hardware Picker View

struct HardwarePickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var budget = 100000.0
    @State private var isGenerating = false
    @State private var progressInfo = ""
    @State private var refreshToken = false
    
    struct Part { let type: String; let name: String; let tag: String?; let query: String }
    
    func pick(_ choices: [Part]) -> Part {
        return choices.randomElement()!
    }
    
    var parts: [Part] {
        let _ = refreshToken
        
        if budget < 45000 {
            return [
                pick([
                    Part(type: "CPU", name: "Intel Core i3-12100F", tag: "Best Value", query: "Intel Core i3-12100F processor"),
                    Part(type: "CPU", name: "Intel Core i3-10105F", tag: "Ultra Budget", query: "Intel Core i3-10105F processor")
                ]),
                Part(type: "Mobo", name: "MSI PRO H610M-E DDR4", tag: nil, query: "MSI PRO H610M-E DDR4 motherboard"),
                pick([
                    Part(type: "GPU", name: "AMD Radeon RX 6600 8GB", tag: "1080p King", query: "AMD Radeon RX 6600 8GB graphic card"),
                    Part(type: "GPU", name: "AMD Radeon RX 580 8GB", tag: "Used/Refurb", query: "AMD Radeon RX 580 8GB graphic card")
                ]),
                Part(type: "RAM", name: "Corsair Vengeance LPX 16GB", tag: nil, query: "Corsair Vengeance LPX 16GB DDR4 3200MHz"),
                Part(type: "SSD", name: "WD Blue SN570 500GB", tag: "Reliable", query: "WD Blue SN570 500GB NVMe"),
                Part(type: "PSU", name: "Deepcool PK550D", tag: "Bronze", query: "Deepcool PK550D 550W Power Supply"),
                Part(type: "Case", name: "Ant Esports ICE-110", tag: "RGB Budget", query: "Ant Esports ICE-110 Auto RGB Cabinet")
            ]
        } else if budget < 65000 {
            return [
                Part(type: "CPU", name: "Intel Core i5-12400F", tag: "Best Seller", query: "Intel Core i5-12400F processor"),
                Part(type: "Mobo", name: "MSI PRO B660M-A WiFi", tag: "Solid VRM", query: "MSI PRO B660M-A WiFi DDR4 motherboard"),
                pick([
                    Part(type: "GPU", name: "AMD Radeon RX 6600 8GB", tag: "Great Value", query: "AMD Radeon RX 6600 8GB graphic card"),
                    Part(type: "GPU", name: "Intel Arc A750", tag: "Alternative", query: "Intel Arc A750 Graphics")
                ]),
                Part(type: "RAM", name: "G.Skill Ripjaws V 16GB", tag: "3600MHz", query: "G.Skill Ripjaws V 16GB DDR4 3600MHz"),
                Part(type: "SSD", name: "Crucial P3 1TB", tag: "Value 1TB", query: "Crucial P3 1TB NVMe M.2"),
                Part(type: "PSU", name: "Cooler Master MWE 550", tag: "Bronze V2", query: "Cooler Master MWE 550W Bronze V2"),
                pick([
                    Part(type: "Case", name: "Galax Revolution 05", tag: "Mesh Flow", query: "Galax Revolution 05 Mesh Cabinet"),
                    Part(type: "Case", name: "Deepcool CC560", tag: "4 Fans", query: "Deepcool CC560 Mid Tower Cabinet")
                ])
            ]
        } else if budget < 90000 {
             return [
                pick([
                    Part(type: "CPU", name: "Intel Core i5-13400F", tag: "Evaluation", query: "Intel Core i5-13400F processor"),
                    Part(type: "CPU", name: "Intel Core i5-12600K", tag: "Overclock", query: "Intel Core i5-12600K processor")
                ]),
                Part(type: "Mobo", name: "MSI MAG B760M MORTAR WiFi", tag: "Premium Board", query: "MSI MAG B760M MORTAR WiFi"),
                pick([
                    Part(type: "GPU", name: "AMD Radeon RX 6650 XT", tag: "1080p Ultra", query: "AMD Radeon RX 6650 XT 8GB"),
                    Part(type: "GPU", name: "AMD Radeon RX 7600", tag: "New Gen", query: "AMD Radeon RX 7600 8GB")
                ]),
                Part(type: "RAM", name: "Corsair Vengeance RGB 32GB", tag: "16GBx2", query: "Corsair Vengeance RGB RS 32GB DDR4 3200MHz"),
                Part(type: "SSD", name: "WD Black SN770 1TB", tag: "Fast Gen4", query: "WD Black SN770 1TB NVMe Gen4"),
                Part(type: "PSU", name: "Deepcool PM650D Gold", tag: "Gold Rated", query: "Deepcool PM650D 650W 80 Plus Gold"),
                Part(type: "Cooler", name: "Deepcool AK400", tag: "Air Tower", query: "Deepcool AK400 CPU Cooler"),
                Part(type: "Case", name: "Ant Esports ICE-511MT", tag: "Mesh AutoRGB", query: "Ant Esports ICE-511MT Mesh Cabinet")
            ]
        } else if budget < 130000 {
            return [
                Part(type: "CPU", name: "Intel Core i5-13600K", tag: "Gaming Beast", query: "Intel Core i5-13600K processor"),
                Part(type: "Mobo", name: "MSI PRO Z790-P WiFi", tag: "DDR5", query: "MSI PRO Z790-P WiFi Motherboard"),
                pick([
                    Part(type: "GPU", name: "AMD Radeon RX 6750 XT", tag: "1440p Ready", query: "AMD Radeon RX 6750 XT 12GB"),
                    Part(type: "GPU", name: "AMD Radeon RX 6800", tag: "VRAM King", query: "AMD Radeon RX 6800 16GB")
                ]),
                Part(type: "RAM", name: "G.Skill Trident Z5 RGB 32GB", tag: "DDR5-6000", query: "G.Skill Trident Z5 RGB 32GB DDR5 6000MHz"),
                Part(type: "SSD", name: "Samsung 980 Pro 1TB", tag: "Top Tier", query: "Samsung 980 Pro 1TB NVMe Gen4"),
                Part(type: "PSU", name: "Corsair RM750e", tag: "ATX 3.0", query: "Corsair RM750e 750W 80 Plus Gold"),
                pick([
                    Part(type: "Cooler", name: "Deepcool LS520 SE", tag: "240mm AIO", query: "Deepcool LS520 SE ARGB Liquid Cooler"),
                    Part(type: "Cooler", name: "Cooler Master ML240L", tag: "Alt AIO", query: "Cooler Master MasterLiquid ML240L Core ARGB")
                ]),
                Part(type: "Case", name: "Lian Li Lancool 215", tag: "Big Fans", query: "Lian Li Lancool 215 Mesh Black")
            ]
        } else if budget < 180000 {
            return [
                pick([
                    Part(type: "CPU", name: "Intel Core i7-13700K", tag: "Productivity", query: "Intel Core i7-13700K processor"),
                    Part(type: "CPU", name: "Intel Core i7-14700K", tag: "New Gen", query: "Intel Core i7-14700K processor")
                ]),
                Part(type: "Mobo", name: "MSI MAG Z790 TOMAHAWK WiFi", tag: "Robust", query: "MSI MAG Z790 TOMAHAWK WiFi DDR5"),
                pick([
                    Part(type: "GPU", name: "AMD Radeon RX 6800 XT", tag: "4K Entry", query: "AMD Radeon RX 6800 XT 16GB"),
                    Part(type: "GPU", name: "AMD Radeon RX 7800 XT", tag: "New Sweetspot", query: "AMD Radeon RX 7800 XT 16GB")
                ]),
                Part(type: "RAM", name: "Corsair Vengeance RGB 32GB", tag: "DDR5-6400", query: "Corsair Vengeance RGB DDR5 32GB 6400MHz"),
                Part(type: "SSD", name: "WD Black SN850X 2TB", tag: "Gaming Pick", query: "WD Black SN850X 2TB NVMe"),
                Part(type: "PSU", name: "Corsair RM850x Shift", tag: "Side Cables", query: "Corsair RM850x Shift 850W Gold"),
                Part(type: "Cooler", name: "Deepcool LT720", tag: "360mm AIO", query: "Deepcool LT720 360mm Liquid Cooler"),
                Part(type: "Case", name: "NZXT H7 Flow RGB", tag: "Modern", query: "NZXT H7 Flow RGB Mid Tower")
            ]
        } else if budget < 250000 {
             return [
                Part(type: "CPU", name: "Intel Core i9-13900K", tag: "Powerhouse", query: "Intel Core i9-13900K processor"),
                Part(type: "Mobo", name: "Gigabyte Z790 AERO G", tag: "Creator White", query: "Gigabyte Z790 AERO G Motherboard"),
                pick([
                    Part(type: "GPU", name: "AMD Radeon RX 6950 XT", tag: "Raw Power", query: "AMD Radeon RX 6950 XT 16GB"),
                    Part(type: "GPU", name: "AMD Radeon RX 7900 XT", tag: "20GB VRAM", query: "AMD Radeon RX 7900 XT 20GB")
                ]),
                Part(type: "RAM", name: "G.Skill Trident Z5 RGB 64GB", tag: "32GBx2", query: "G.Skill Trident Z5 RGB 64GB DDR5 6000MHz"),
                Part(type: "SSD", name: "Samsung 990 Pro 2TB", tag: "The Best", query: "Samsung 990 Pro 2TB NVMe"),
                Part(type: "PSU", name: "Corsair RM1000x", tag: "1000W Gold", query: "Corsair RM1000x 1000W 80 Plus Gold"),
                Part(type: "Cooler", name: "NZXT Kraken 360 Elite", tag: "LCD Display", query: "NZXT Kraken 360 Elite RGB LCD"),
                Part(type: "Case", name: "Lian Li O11 Dynamic Evo", tag: "Showcase", query: "Lian Li O11 Dynamic EVO Black")
            ]
        } else if budget < 350000 {
            return [
                Part(type: "CPU", name: "Intel Core i9-14900K", tag: "Top Tier", query: "Intel Core i9-14900K processor"),
                Part(type: "Mobo", name: "ASUS ROG STRIX Z790-E", tag: "Extreme", query: "ASUS ROG STRIX Z790-E GAMING WIFI"),
                Part(type: "GPU", name: "AMD Radeon RX 7900 XTX", tag: "Flagship", query: "AMD Radeon RX 7900 XTX 24GB"),
                Part(type: "RAM", name: "Corsair Dominator Titanium 64GB", tag: "Premium", query: "Corsair Dominator Titanium DDR5 64GB"),
                Part(type: "SSD", name: "WD Black SN850X 4TB", tag: "Massive Storage", query: "WD Black SN850X 4TB NVMe"),
                Part(type: "PSU", name: "Corsair HX1200", tag: "Platinum", query: "Corsair HX1200 1200W Platinum"),
                Part(type: "Cooler", name: "Lian Li Galahad II LCD SL-INF", tag: "Fancy Fans", query: "Lian Li Galahad II LCD SL-INF 360"),
                Part(type: "Case", name: "Hyte Y70 Touch", tag: "Screen Case", query: "Hyte Y70 Touch Case")
            ]
        } else if budget < 450000 {
             return [
                Part(type: "CPU", name: "Intel Core i9-14900KS", tag: "Special Edition", query: "Intel Core i9-14900KS processor"),
                Part(type: "Mobo", name: "ASUS ProArt Z790-CREATOR", tag: "10G LAN", query: "ASUS ProArt Z790-CREATOR WIFI"),
                pick([
                    Part(type: "GPU", name: "AMD Radeon RX 7900 XTX", tag: "Sapphire Nitro+", query: "Sapphire Nitro+ AMD Radeon RX 7900 XTX"),
                    Part(type: "GPU", name: "AMD Radeon RX 7900 XTX", tag: "PowerColor Red Devil", query: "PowerColor Red Devil AMD Radeon RX 7900 XTX")
                ]),
                Part(type: "RAM", name: "G.Skill Trident Z5 RGB 96GB", tag: "48GBx2", query: "G.Skill Trident Z5 RGB 96GB DDR5 6400MHz"),
                Part(type: "SSD", name: "Samsung 990 Pro 4TB", tag: "Main Drive", query: "Samsung 990 Pro 4TB NVMe"),
                Part(type: "SSD", name: "Samsung 870 QVO 8TB", tag: "Archive", query: "Samsung 870 QVO 8TB SATA SSD"),
                Part(type: "PSU", name: "Corsair AX1600i", tag: "Titanium", query: "Corsair AX1600i 1600W Titanium"),
                Part(type: "Cooler", name: "ASUS ROG Ryujin III 360", tag: "Big Screen", query: "ASUS ROG Ryujin III 360 ARGB"),
                Part(type: "Case", name: "Lian Li V3000 Plus", tag: "Super Tower", query: "Lian Li V3000 Plus User Full Tower")
            ]
        } else if budget < 550000 {
             return [
                Part(type: "CPU", name: "Intel Core i9-14900KS", tag: "Binned", query: "Intel Core i9-14900KS processor"),
                Part(type: "Mobo", name: "ASUS ROG MAXIMUS Z790 HERO", tag: "Enthusiast", query: "ASUS ROG MAXIMUS Z790 HERO"),
                pick([
                    Part(type: "GPU", name: "AMD Radeon RX 7900 XTX", tag: "Liquid Cooling", query: "PowerColor Liquid Devil AMD Radeon RX 7900 XTX"),
                    Part(type: "GPU", name: "AMD Radeon RX 7900 XTX", tag: "Taichi White", query: "ASRock Radeon RX 7900 XTX Taichi White")
                ]),
                Part(type: "RAM", name: "Corsair Dominator Titanium 96GB", tag: "48GBx2", query: "Corsair Dominator Titanium DDR5 96GB 6600MHz"),
                Part(type: "SSD", name: "Sabrent Rocket 4 Plus 8TB", tag: "Extreme Space", query: "Sabrent Rocket 4 Plus 8TB NVMe"),
                Part(type: "PSU", name: "Corsair AX1600i", tag: "Titanium", query: "Corsair AX1600i 1600W Titanium"),
                pick([
                    Part(type: "Case", name: "Phanteks NV7", tag: "Showcase", query: "Phanteks NV7 Showcase Full Tower"),
                    Part(type: "Case", name: "Lian Li O11 Dynamic EVO XL", tag: "White Build", query: "Lian Li O11 Dynamic EVO XL White")
                ]),
                Part(type: "Cooler", name: "Lian Li Galahad II LCD SL-INF", tag: "Push-Pull", query: "Lian Li Galahad II LCD SL-INF 360")
            ]
        } else {
             // Ultimate Unlimited (Budget > 550k)
             return [
                Part(type: "CPU", name: "Intel Core i9-14900KS", tag: "Golden Chip", query: "Intel Core i9-14900KS processor"),
                Part(type: "Mobo", name: "MSI MEG Z790 GODLIKE", tag: "God Tier", query: "MSI MEG Z790 GODLIKE MAX"),
                pick([
                    Part(type: "GPU", name: "AMD Radeon RX 7900 XTX Liquid", tag: "Waterforce", query: "Gigabyte AORUS Radeon RX 7900 XTX Xtreme Waterforce"),
                    Part(type: "GPU", name: "ASUS ROG Strix 4090", tag: "Unsupported (Unix)", query: "ASUS ROG Strix GeForce RTX 4090 (Check OCLP)") // Joke/Warning
                ]),
                Part(type: "RAM", name: "G.Skill Trident Z5 RGB 96GB", tag: "Max Speed", query: "G.Skill Trident Z5 RGB 96GB DDR5 7200MHz"),
                pick([
                    Part(type: "SSD", name: "TeamGroup QX 15.3TB", tag: "Server Grade", query: "TeamGroup QX 15.3TB SATA SSD"),
                    Part(type: "SSD", name: "Sabrent Rocket 4 Plus 8TB (x2)", tag: "RAID 0", query: "Sabrent Rocket 4 Plus 8TB NVMe")
                ]),
                Part(type: "PSU", name: "Be Quiet! Dark Power Pro 13", tag: "1600W", query: "Be Quiet! Dark Power Pro 13 1600W"),
                pick([
                   Part(type: "Case", name: "Cooler Master HAF 700 EVO", tag: "Flagship", query: "Cooler Master HAF 700 EVO"),
                   Part(type: "Case", name: "InWin 309 Gaming Edition", tag: "Pixel Front", query: "InWin 309 Gaming Edition")
                ]),
                Part(type: "Cooler", name: "EK Nucleus AIO CR360", tag: "Performance", query: "EK Nucleus AIO CR360 Lux D-RGB")
            ]
        }
    }
    
    var tierName: String {
        if budget < 45000 { return "Entry Level (Web/Office)" }
        if budget < 65000 { return "Budget Gamer (1080p)" }
        if budget < 90000 { return "Mid-Range (1080p Ultra)" }
        if budget < 130000 { return "Performance (1440p)" }
        if budget < 180000 { return "Pro Level (4K Entry)" }
        if budget < 250000 { return "High-End (Content Creation)" }
        if budget < 350000 { return "Ultra Tier (Heavy Duty)" }
        if budget < 450000 { return "Extreme (Workshop)" }
        return "God Tier (Dream Build)"
    }
    
    var body: some View {
        ZStack { // ZStack for Overlay
            VStack {
                // Header with Refresh
                VStack(spacing: 10) {
                    CommonHeader(title: "")
                    
                    HStack {
                        Text("Hardware Builder")
                            .font(.title2).bold()
                            .foregroundColor(GreenmixTheme.text)
                        Spacer()
                        Button(action: {
                            withAnimation {
                                refreshToken.toggle()
                            }
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: "arrow.clockwise")
                                Text("Refresh Feed")
                            }
                            .font(.caption)
                            .padding(6)
                            .background(GreenmixTheme.card)
                            .cornerRadius(6)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal)
                }
                
                VStack {
                    HStack {
                        Text("Budget: ₹\(Int(budget))")
                            .font(.headline)
                            .foregroundColor(GreenmixTheme.gold)
                        Spacer()
                        Text(tierName)
                            .font(.subheadline)
                            .foregroundColor(GreenmixTheme.accent)
                    }
                    
                    Slider(value: $budget, in: 30000...600000, step: 2000)
                }
                .padding()
                .background(GreenmixTheme.card)
                .cornerRadius(10)
                .padding(.horizontal)
                
                List(parts, id: \.name) { part in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(part.type)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.gray)
                            if let tag = part.tag {
                                Text(tag)
                                    .font(.system(size: 8))
                                    .padding(2)
                                    .background(GreenmixTheme.accent.opacity(0.2))
                                    .cornerRadius(4)
                                    .foregroundColor(GreenmixTheme.accent)
                            }
                        }
                        .frame(width: 50, alignment: .leading)
                        
                        Text(part.name)
                            .fontWeight(.medium)
                            .font(.system(size: 13))
                        
                        Spacer()
                        
                        Button("Buy") {
                            openSearch(part.query)
                        }
                        .foregroundColor(.blue)
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(5)
                    }
                }
                
                Text("⚠️ Note: Estimate for CPU Unit only. Monitor & Peripherals excluded.")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 5)
                
                Button(action: {
                    generateEFI()
                }) {
                    HStack {
                        Image(systemName: "folder.badge.gearshape")
                        Text("Generate Tuned EFI (Downloader)")
                    }
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(GreenmixTheme.gold) // Solid Gold as requested
                    .foregroundColor(.black)
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
                .padding(.bottom, 10)
                .disabled(isGenerating)
                
                Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding(.bottom)
                .disabled(isGenerating)
            }
            .frame(width: 650, height: 600)
            
            // Progress Overlay
            if isGenerating {
                Color.black.opacity(0.8)
                VStack(spacing: 20) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: GreenmixTheme.accent))
                        .scaleEffect(1.5)
                    Text("Generating Tuned EFI...")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(progressInfo)
                        .font(.caption) // Live Status
                        .foregroundColor(.gray)
                }
                .frame(width: 200, height: 150)
                .background(GreenmixTheme.card)
                .cornerRadius(12)
                .shadow(radius: 20)
            }
        }
    }
    
    func openSearch(_ query: String) {
        // Targeted search to land on product page listing
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = URL(string: "https://www.amazon.in/s?k=\(encoded)&i=computers")!
        NSWorkspace.shared.open(url)
    }
    
    func generateEFI() {
        let folderName = "HackinTune_EFI_\(tierName.replacingOccurrences(of: " ", with: "_").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "-", with: "_").replacingOccurrences(of: "/", with: "_"))"
        
        // Determine Platform for Script
        let platform = budget < 45000 ? "intel_10_11" : "intel_12_plus"
        
        isGenerating = true
        progressInfo = "Initializing for \(platform)..."
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Locate Logic Script
            guard let scriptPath = Bundle.main.path(forResource: "efi_builder", ofType: "sh") else {
                DispatchQueue.main.async { self.isGenerating = false }
                return
            }
            
            DispatchQueue.main.async { self.progressInfo = "Creating Installer EFI..." }
            
            // Run Script with Arguments: Destination, Platform, WiFi (None for Installer to keep it safe)
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/bin/bash")
            task.arguments = [scriptPath, folderName, platform, "none"]
            
            try? task.run()
            task.waitUntilExit()
            
            DispatchQueue.main.async { self.progressInfo = "Refining Config.plist..." }
            
            // Post-Process: Add BIOS Text and Config.plist
            self.finishEFI(folderName: folderName)
            
            DispatchQueue.main.async {
                self.isGenerating = false
            }
        }
    }
    
    func finishEFI(folderName: String) {
        let fileManager = FileManager.default
        let desktop = fileManager.urls(for: .desktopDirectory, in: .userDomainMask).first!
        let destURL = desktop.appendingPathComponent(folderName)
        
        // 1. BIOS Instructions
        let biosText = """
        BIOS SETUP INSTRUCTIONS (\(tierName))
        ==================================================
        
        1.  **Secure Boot**: DISABLE (Critical)
        2.  **Intel SGX**: DISABLE
        3.  **Fast Boot**: DISABLE
        4.  **CSM**: DISABLE (UEFI Only)
        5.  **VT-d**: ENABLE (but Disable in config.plist if needed)
        6.  **XMP / EXPO**: ENABLE (Profile 1)
        7.  **Resize BAR**: ENABLE
        8.  **Above 4G Decoding**: ENABLE
        9.  **Serial Port**: DISABLE
        
        [ACTION REQUIRED]
        Please take a clear PHOTO of these settings on your BIOS screen 
        with your phone before Saving & Exiting.
        """
        try? biosText.write(to: destURL.appendingPathComponent("BIOS_SETTINGS.txt"), atomically: true, encoding: .utf8)
        
        // 2. Generate Base config.plist
        // Minimal valid structure for booting Installer
        let smbios = budget < 100000 ? "iMac20,1" : "MacPro7,1" // Simple logic: Entry=iMac, HighEnd=MacPro
        let bootArgs = "-v keepsyms=1 debug=0x100 agdpmod=pikera alcid=1"
        
        let configPlist = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>ACPI</key>
            <dict>
                <key>Add</key>
                <array>
                    <dict><key>Enabled</key><true/><key>Path</key><string>SSDT-AWAC.aml</string></dict>
                    <dict><key>Enabled</key><true/><key>Path</key><string>SSDT-EC-USBX-DESKTOP.aml</string></dict>
                    <dict><key>Enabled</key><true/><key>Path</key><string>SSDT-PLUG-ALT.aml</string></dict>
                    <dict><key>Enabled</key><true/><key>Path</key><string>SSDT-RHUB.aml</string></dict>
                </array>
            </dict>
            <key>Booter</key>
            <dict><key>Quirks</key><dict><key>AvoidRuntimeDefrag</key><true/><key>DevirtualiseMmio</key><true/><key>EnableSafeModeSlide</key><true/><key>ProvideCustomSlide</key><true/><key>RebuildAppleMemoryMap</key><true/><key>ResizeAppleGpuBars</key><integer>0</integer><key>SetupVirtualMap</key><true/><key>SyncRuntimePermissions</key><true/></dict></dict>
            <key>DeviceProperties</key>
            <dict><key>Add</key><dict></dict></dict>
            <key>Kernel</key>
            <dict>
                <key>Add</key>
                <array>
                    <dict><key>BundlePath</key><string>Lilu.kext</string><key>Enabled</key><true/><key>ExecutablePath</key><string>Contents/MacOS/Lilu</string><key>PlistPath</key><string>Contents/Info.plist</string></dict>
                    <dict><key>BundlePath</key><string>VirtualSMC.kext</string><key>Enabled</key><true/><key>ExecutablePath</key><string>Contents/MacOS/VirtualSMC</string><key>PlistPath</key><string>Contents/Info.plist</string></dict>
                    <dict><key>BundlePath</key><string>WhateverGreen.kext</string><key>Enabled</key><true/><key>ExecutablePath</key><string>Contents/MacOS/WhateverGreen</string><key>PlistPath</key><string>Contents/Info.plist</string></dict>
                    <dict><key>BundlePath</key><string>AppleALC.kext</string><key>Enabled</key><true/><key>ExecutablePath</key><string>Contents/MacOS/AppleALC</string><key>PlistPath</key><string>Contents/Info.plist</string></dict>
                </array>
                <key>Quirks</key>
                <dict><key>AppleXcpmCfgLock</key><true/><key>DisableIoMapper</key><true/><key>PanicNoKextDump</key><true/><key>PowerTimeoutKernelPanic</key><true/><key>XhciPortLimit</key><false/></dict>
            </dict>
            <key>NVRAM</key>
            <dict>
                <key>Add</key>
                <dict>
                    <key>7C436110-AB2A-4BBB-A880-FE41995C9F82</key>
                    <dict>
                        <key>boot-args</key>
                        <string>\(bootArgs)</string>
                        <key>csr-active-config</key>
                        <data>AAAAAA==</data>
                        <key>prev-lang:kbd</key>
                        <string>en-US:0</string>
                    </dict>
                </dict>
            </dict>
            <key>PlatformInfo</key>
            <dict>
                <key>Generic</key>
                <dict>
                    <key>SystemProductName</key>
                    <string>\(smbios)</string>
                    <key>SystemSerialNumber</key>
                    <string>GENERATE_ME</string>
                    <key>SystemUUID</key>
                    <string>GENERATE_ME</string>
                    <key>MLB</key>
                    <string>GENERATE_ME</string>
                </dict>
                <key>UpdateSMBIOS</key>
                <true/>
            </dict>
            <key>UEFI</key>
            <dict>
                <key>APFS</key>
                <dict><key>EnableJumpstart</key><true/><key>GlobalConnect</key><false/><key>HideVerbose</key><true/><key>JumpstartHotPlug</key><false/><key>MinDate</key><integer>0</integer><key>MinVersion</key><integer>0</integer></dict>
                <key>Drivers</key>
                <array>
                    <dict><key>Arguments</key><string></string><key>Comment</key><string></string><key>Enabled</key><true/><key>Path</key><string>OpenRuntime.efi</string></dict>
                    <dict><key>Arguments</key><string></string><key>Comment</key><string></string><key>Enabled</key><true/><key>Path</key><string>HfsPlus.efi</string></dict>
                </array>
                <key>Quirks</key>
                <dict><key>ReleaseUsbOwnership</key><true/><key>RequestBootVarRouting</key><true/></dict>
            </dict>
        </dict>
        </plist>
        """
        
        try? configPlist.write(to: destURL.appendingPathComponent("EFI/OC/config.plist"), atomically: true, encoding: .utf8)

        DispatchQueue.main.async {
            NSWorkspace.shared.activateFileViewerSelecting([destURL])
            
            let alertScript = """
            display dialog "EFI Generated Successfully!\\n\\n1. Copy this EFI to your USB Stick.\\n2. Boot and Install macOS.\\n3. IMPORTANT: RUN THIS APP AGAIN after installing to enable Wi-Fi, Audio, and Performance Tweaks." buttons {"OK"} default button "OK" with icon note
            """
            _ = NSAppleScript(source: alertScript)?.executeAndReturnError(nil)
        }
    }
}

struct SocialLink: View {
    let icon: String
    let label: String
    let url: String
    
    var body: some View {
        Button(action: {
            if let target = URL(string: url) {
                NSWorkspace.shared.open(target)
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(label)
            }
            .font(.caption.bold())
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(GreenmixTheme.card)
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(GreenmixTheme.accent.opacity(0.3), lineWidth: 1))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Support View

struct SupportView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Support HackinTune")
                    .font(.title).bold()
                
                if let path = Bundle.main.path(forResource: "qrcode", ofType: "png"),
                   let image = NSImage(contentsOfFile: path) {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 250, height: 250)
                } else {
                    Image(systemName: "qrcode")
                        .resizable()
                        .frame(width: 200, height: 200)
                }
                
                Text("Powered by Greenmix Futech, Chennai")
                    .foregroundColor(GreenmixTheme.accent)
                
                Text("UPI: shyam4muzix3@axl")
                    .font(.headline)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .onTapGesture {
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString("shyam4muzix3@axl", forType: .string)
                    }
                
                VStack(spacing: 12) {
                    Text("Connect with the Developer")
                        .font(.headline)
                        .foregroundColor(GreenmixTheme.text)
                    
                    HStack(spacing: 15) {
                        SocialLink(icon: "link", label: "GitHub", url: "https://github.com/sam4muzix")
                        SocialLink(icon: "camera", label: "Instagram", url: "https://www.instagram.com/shyam4muzix/")
                        SocialLink(icon: "envelope", label: "Gmail", url: "mailto:shyam4muzix@gmail.com")
                    }
                }
                .padding(.top, 10)
                
                Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding()
        }
        .frame(width: 450, height: 650)
    }
}

import SwiftUI

// MARK: - Setup View (New Landing Page)
struct SetupView: View {
    @State private var mode: AppMode? = nil
    
    enum AppMode {
        case preInstall
        case postInstall
    }
    
    var body: some View {
        if let currentMode = mode {
            switch currentMode {
            case .preInstall:
                ContentView(mode: .preInstall, onBack: { mode = nil })
            case .postInstall:
                PostInstallView(onBack: { mode = nil })
            }
        } else {
            // Landing Page
            ZStack {
                GreenmixTheme.bg.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 40) {
                    VStack(spacing: 10) {
                        if let path = Bundle.main.path(forResource: "logo", ofType: "png"),
                           let image = NSImage(contentsOfFile: path) {
                            Image(nsImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                        } else {
                            Image(systemName: "applelogo")
                                .font(.system(size: 80))
                                .foregroundColor(GreenmixTheme.text)
                        }
                        Text("HackinTune Cycle")
                            .font(.largeTitle).bold()
                            .foregroundColor(GreenmixTheme.text)
                        Text("Select your current stage")
                            .font(.headline)
                            .foregroundColor(GreenmixTheme.secondary)
                    }
                    
                    HStack(spacing: 30) {
                        // Option 1: Build Installer
                        Button(action: { mode = .preInstall }) {
                            VStack(spacing: 20) {
                                Image(systemName: "externaldrive.badge.plus")
                                    .font(.system(size: 50))
                                    .foregroundColor(GreenmixTheme.gold)
                                VStack {
                                    Text("Pre-Install")
                                        .font(.title2).bold()
                                        .foregroundColor(GreenmixTheme.text)
                                    Text("Build EFI for USB Installer")
                                        .font(.caption)
                                        .foregroundColor(GreenmixTheme.secondary)
                                }
                            }
                            .frame(width: 250, height: 250)
                            .background(GreenmixTheme.card)
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(GreenmixTheme.gold.opacity(0.5), lineWidth: 2))
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Option 2: Optimize System
                        Button(action: { mode = .postInstall }) {
                            VStack(spacing: 20) {
                                Image(systemName: "wrench.and.screwdriver.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(GreenmixTheme.accent)
                                VStack {
                                    Text("Post-Install")
                                        .font(.title2).bold()
                                        .foregroundColor(GreenmixTheme.text)
                                    Text("Install Drivers & Fixes")
                                        .font(.caption)
                                        .foregroundColor(GreenmixTheme.secondary)
                                }
                            }
                            .frame(width: 250, height: 250)
                            .background(GreenmixTheme.card)
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(GreenmixTheme.accent.opacity(0.5), lineWidth: 2))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    VStack {
                        Text("v5.0 Your Hackintosh Companion")
                            .font(.caption2)
                            .foregroundColor(GreenmixTheme.secondary.opacity(0.5))
                    }
                    .padding(.top, 50)
                }
            }
        }
    }
}

// MARK: - Utilities
struct Shell {
    static func run(_ cmd: String) -> String {
        let task = Process()
        let pipe = Pipe()
        task.standardOutput = pipe
        task.arguments = ["-c", cmd]
        task.launchPath = "/bin/bash"
        task.launch()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}

struct HardwareScanner {
    enum DeviceStatus {
        case compatible(String)
        case incompatible(String)
        case notFound
        
        var label: String {
            switch self {
            case .compatible(let name): return "Recommended: \(name)"
            case .incompatible(let name): return "Incompatible: \(name)"
            case .notFound: return "Not Detected"
            }
        }
        
        var color: Color {
            switch self {
            case .compatible: return .green
            case .incompatible: return .red
            case .notFound: return .gray
            }
        }
    }
    
    static func scanWifi() -> (status: DeviceStatus, vendor: String) {
        let ioWifi = Shell.run("ioreg -n AppleBCMWLANCore -r | grep -i vendor-id")
        if !ioWifi.isEmpty {
            return (.compatible("Broadcom (Native/Kext)"), "Broadcom")
        }
        
        let pciWifi = Shell.run("system_profiler SPNetworkDataType | grep -i 'Card Type'")
        if pciWifi.contains("Wi-Fi") {
             let details = Shell.run("system_profiler SPNetworkDataType | grep -i 'Firmware Version'")
             if details.contains("itlwm") || details.contains("Intel") {
                 return (.compatible("Intel Wireless"), "Intel")
             }
        }
        
        // USB Wi-Fi Detection
        let usbWifi = Shell.run("system_profiler SPUSBDataType | grep -Ei 'Realtek|Mediatek|Ralink|802.11'")
        if !usbWifi.isEmpty {
            if usbWifi.contains("Realtek") { return (.compatible("USB Wi-Fi (Realtek)"), "USB-Realtek") }
            if usbWifi.contains("Mediatek") || usbWifi.contains("Ralink") { return (.compatible("USB Wi-Fi (Mediatek)"), "USB-Mediatek") }
            return (.compatible("USB Wi-Fi (Generic)"), "USB-Generic")
        }
        
        // Final fallback to Vendor IDs via ioreg
        let vendor = Shell.run("ioreg -p IOUSB -p IOPCI | grep -Ei '8086|14e4' | head -1")
        if vendor.contains("8086") { return (.compatible("Intel Wifi"), "Intel") }
        if vendor.contains("14e4") { return (.compatible("Broadcom Wifi"), "Broadcom") }
        
        return (.notFound, "Unknown")
    }
    
    static func scanBT() -> (status: DeviceStatus, vendor: String) {
        let btDevice = Shell.run("system_profiler SPBluetoothDataType | grep -i 'Address'")
        
        let usbBT = Shell.run("system_profiler SPUSBDataType | grep -Ei 'Intel|Broadcom|Realtek|CSR|Cambridge'")
        if usbBT.contains("Intel") { return (.compatible("Intel Bluetooth"), "Intel") }
        if usbBT.contains("Broadcom") { return (.compatible("Broadcom Bluetooth"), "Broadcom") }
        if usbBT.contains("Realtek") { return (.incompatible("Realtek BT (Internal - Unsupported)"), "Realtek") }
        if usbBT.contains("CSR") || usbBT.contains("Cambridge") { return (.compatible("USB BT (CSR/Generic)"), "USB-Generic") }
        
        if btDevice.isEmpty { return (.notFound, "None") }
        return (.compatible("Generic Bluetooth"), "Generic")
    }
    
    static func isLaptop() -> Bool {
        let model = Shell.run("sysctl -n hw.model")
        return model.contains("Book")
    }
}

// MARK: - Stability & Performance Scanner
struct StabilityScanner {
    static func analyzeFreeze(completion: @escaping (String) -> Void) {
        DispatchQueue.global().async {
            let logs = Shell.run("log show --predicate 'eventMessage contains \"panic\"' --last 12h | grep -i 'panic' | tail -n 3")
            DispatchQueue.main.async {
                if logs.isEmpty {
                    completion("No recent Kernel Panics detected in the last 12h.")
                } else if logs.contains("IOPCIFamily") {
                    completion("Found Potential Freeze: IOPCIFamily error. Check GPU/Bus patches.")
                } else if logs.contains("AppleALC") {
                    completion("Found Potential Freeze: Audio driver conflict. Check alcid.")
                } else {
                    completion("Recent Panic Found! Check your drivers for compatibility.")
                }
            }
        }
    }
    
    static func checkSSDStatus() -> (health: String, trim: Bool) {
        let ssdInfo = Shell.run("system_profiler SPNVMeDataType SPStorageDataType | grep -Ei 'S.M.A.R.T|TRIM'")
        let trimStatus = ssdInfo.contains("TRIM Support: Yes")
        let health = ssdInfo.contains("Verified") ? "Verified (Healthy)" : "Check Required"
        return (health, trimStatus)
    }
    
    static func checkPowerManagement() -> String {
        let pm = Shell.run("pmset -g | grep -Ei 'sleep|hibernatemode'")
        if pm.contains("hibernatemode 0") { return "Power Management: Optimal for Hackintosh." }
        return "Power Management: Sub-optimal. Consider set hibernatemode 0."
    }
}

// MARK: - Advanced Tools & Premium Modules (v8.0)
struct AdvancedTools {
    struct SMBIOS {
        let model: String
        let serial: String
        let boardSerial: String
        let uuid: String
    }
    
    static func generateSMBIOS(model: String) -> SMBIOS {
        let letters = "ABCDEFGHJKLMNPQRSTUVWXYZ0123456789"
        let serial = String((0..<12).map{ _ in letters.randomElement()! })
        let boardSerial = serial + String((0..<5).map{ _ in letters.randomElement()! })
        let uuid = UUID().uuidString
        return SMBIOS(model: model, serial: serial, boardSerial: boardSerial, uuid: uuid)
    }
    
    static func getSIPStatus() -> String {
        let status = Shell.run("csrutil status")
        if status.contains("disabled") { return "SIP: Disabled (03000000)" }
        return "SIP: Enabled (Normal)"
    }
    
    static func getBootArgs() -> String {
        guard let efiPath = PostInstallView.sharedMountedPath() else { return "Unknown" }
        let configPath = "\(efiPath)/config.plist"
        let key = ":NVRAM:Add:7C436110-AB2A-4BBB-A880-FE41995C9F82:boot-args"
        return Shell.run("/usr/libexec/PlistBuddy -c \"Print \(key)\" \"\(configPath)\"").replacingOccurrences(of: "\"", with: "")
    }
    
    static func setBootArgs(_ args: String) {
        guard let efiPath = PostInstallView.sharedMountedPath() else { return }
        let configPath = "\(efiPath)/config.plist"
        let key = ":NVRAM:Add:7C436110-AB2A-4BBB-A880-FE41995C9F82:boot-args"
        _ = Shell.run("/usr/libexec/PlistBuddy -c \"Set \(key) \(args)\" \"\(configPath)\"")
    }

    static func checkKextUpdates() -> [String: String] {
        let kexts = ["Lilu", "WhateverGreen", "AppleALC", "VirtualSMC"]
        var updates: [String: String] = [:]
        for kext in kexts {
            let latest = Shell.run("curl -s https://api.github.com/repos/acidanthera/\(kext)/releases/latest | grep tag_name | cut -d '\"' -f 4")
            updates[kext] = latest.isEmpty ? "Check Failed" : latest
        }
        return updates
    }
    
    static func createVaultBackup() -> String {
        guard let efiPath = PostInstallView.sharedMountedPath() else { return "Mount EFI first" }
        let date = Int(Date().timeIntervalSince1970)
        let zipPath = "/tmp/EFI_Vault_\(date).zip"
        _ = Shell.run("cd \"\(efiPath)/..\" && zip -r \"\(zipPath)\" EFI")
        _ = Shell.run("mkdir -p ~/Documents/HackinTuneVault && cp \"\(zipPath)\" ~/Documents/HackinTuneVault/")
        return "Backup saved to Documents/HackinTuneVault/"
    }
    
    static func installModernTheme() -> String {
        guard let efiPath = PostInstallView.sharedMountedPath() else { return "EFI Needed" }
        let url = "https://github.com/acidanthera/OcBinaryData/archive/refs/heads/master.zip"
        _ = Shell.run("curl -L -o /tmp/themes.zip \(url) && unzip -q /tmp/themes.zip -d /tmp/themes")
        _ = Shell.run("cp -rf /tmp/themes/OcBinaryData-master/Resources/* \"\(efiPath)/Resources/\"")
        return "New Icons & Themes installed to Resources/"
    }
}

struct PremiumToolsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var smbios = AdvancedTools.generateSMBIOS(model: "iMac20,1")
    @State private var sipStatus = "Checking..."
    @State private var bootArgs = ""
    @State private var kextUpdates: [String: String] = [:]
    @State private var statusMsg = "Welcome to Premium ToolBox"
    
    var body: some View {
        ZStack {
            GreenmixTheme.bg.edgesIgnoringSafeArea(.all)
            VStack(spacing: 15) {
                CommonHeader(title: "Advanced ToolBox")
                
                if bootArgs == "Unknown" || bootArgs.isEmpty {
                    VStack {
                        Text("⚠️ EFI Not Detected").foregroundColor(.red).bold()
                        Button("Unlock EFI Access") {
                            PostInstallView.autoMountEFI { path in
                                bootArgs = AdvancedTools.getBootArgs()
                                sipStatus = AdvancedTools.getSIPStatus()
                            }
                        }
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.red, lineWidth: 1))
                    }
                    .padding()
                }
                
                HStack {
                    Button("Back") { presentationMode.wrappedValue.dismiss() }
                    Spacer()
                }.padding(.horizontal)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Section 1: SMBIOS
                        VStack(alignment: .leading) {
                            Text("SMBIOS Generator").font(.headline).foregroundColor(GreenmixTheme.gold)
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Serial: \(smbios.serial)").font(.system(size: 10, design: .monospaced))
                                    Text("Board: \(smbios.boardSerial)").font(.system(size: 10, design: .monospaced))
                                }
                                Spacer()
                                Button("New") { smbios = AdvancedTools.generateSMBIOS(model: "iMac20,1") }
                                Button("Copy") { 
                                    let pasteboard = NSPasteboard.general
                                    pasteboard.clearContents()
                                    pasteboard.setString("Serial: \(smbios.serial)\nBoard: \(smbios.boardSerial)\nUUID: \(smbios.uuid)", forType: .string)
                                    statusMsg = "Copies to Clipboard!"
                                }
                            }
                        }.padding().background(GreenmixTheme.card).cornerRadius(10)
                        
                        // Section 2: Boot-Args & SIP
                        VStack(alignment: .leading) {
                            Text("Security & Boot").font(.headline).foregroundColor(.cyan)
                            Text("Current: \(bootArgs)").font(.caption).foregroundColor(.gray)
                            
                            HStack {
                                Toggle("-v", isOn: Binding(get: { bootArgs.contains("-v") }, set: { if $0 { if !bootArgs.contains("-v") { bootArgs += " -v" } } else { bootArgs = bootArgs.replacingOccurrences(of: "-v", with: "").trimmingCharacters(in: .whitespaces) } }))
                                Toggle("Debug", isOn: Binding(get: { bootArgs.contains("debug=0x100") }, set: { if $0 { if !bootArgs.contains("debug=0x100") { bootArgs += " debug=0x100" } } else { bootArgs = bootArgs.replacingOccurrences(of: "debug=0x100", with: "").trimmingCharacters(in: .whitespaces) } }))
                                Toggle("Pikera", isOn: Binding(get: { bootArgs.contains("agdpmod=pikera") }, set: { if $0 { if !bootArgs.contains("agdpmod=pikera") { bootArgs += " agdpmod=pikera" } } else { bootArgs = bootArgs.replacingOccurrences(of: "agdpmod=pikera", with: "").trimmingCharacters(in: .whitespaces) } }))
                            }.font(.caption)

                            HStack {
                                TextField("Edit boot-args", text: $bootArgs)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Button("Apply") { AdvancedTools.setBootArgs(bootArgs); statusMsg = "Boot-args updated!" }
                            }
                            Text(sipStatus).font(.caption).bold().foregroundColor(.orange)
                        }.padding().background(GreenmixTheme.card).cornerRadius(10)
                        
                        // Section 3: Kext Updates
                        VStack(alignment: .leading) {
                            Text("Kext Update Checker").font(.headline).foregroundColor(.green)
                            ForEach(kextUpdates.sorted(by: <), id: \.key) { key, value in
                                Text("\(key): \(value)").font(.caption)
                            }
                            Button("Refresh Versions") {
                                statusMsg = "Checking GitHub..."
                                kextUpdates = AdvancedTools.checkKextUpdates()
                                statusMsg = "Versions Updated"
                            }
                        }.padding().background(GreenmixTheme.card).cornerRadius(10)
                        
                        // Section 4: Vault
                        Button(action: { statusMsg = AdvancedTools.createVaultBackup() }) {
                            HStack {
                                Image(systemName: "safe.fill")
                                Text("Create EFI Vault Backup")
                            }
                            .frame(maxWidth: .infinity)
                            .padding().background(Color.blue).cornerRadius(10)
                        }.buttonStyle(PlainButtonStyle())
                        
                    }.padding()
                }
                
                Text(statusMsg).foregroundColor(GreenmixTheme.accent).font(.caption)
                Spacer()
            }
        }.onAppear {
            sipStatus = AdvancedTools.getSIPStatus()
            bootArgs = AdvancedTools.getBootArgs()
        }
    }
}

// MARK: - Post Install View
struct PostInstallView: View {
    var onBack: () -> Void
    @State private var statusMessage = "Scanning System Hardware..."
    
    // Dynamic Hardware Labels
    @State private var audioName = "Audio"
    @State private var gpuName = "Graphics"
    
    @State private var wifiStatus: (status: HardwareScanner.DeviceStatus, vendor: String) = (.notFound, "Unknown")
    @State private var btStatus: (status: HardwareScanner.DeviceStatus, vendor: String) = (.notFound, "Unknown")
    
    @State private var showingPremiumTools = false
    @State private var isEFIMounted = false
    @State private var efiPath: String? = nil
    @State private var efiPartitions: [String] = []
    @State private var showingMountPicker = false
    
    static func sharedMountedPath() -> String? {
         // Check if already mounted first
         if FileManager.default.fileExists(atPath: "/Volumes/EFI/EFI/OC/config.plist") { return "/Volumes/EFI/EFI/OC" }
         if FileManager.default.fileExists(atPath: "/Volumes/ESP/EFI/OC/config.plist") { return "/Volumes/ESP/EFI/OC" }
         
         // If not found, check if a volume named 'EFI' or 'ESP' is mounted but maybe in the wrong spot
         let volumes = ["/Volumes/EFI", "/Volumes/ESP"]
         for vol in volumes {
             if FileManager.default.fileExists(atPath: "\(vol)/EFI/OC/config.plist") { return "\(vol)/EFI/OC" }
         }
         return nil
    }
    
    static func autoMountEFI(completion: @escaping (String?) -> Void) {
        DispatchQueue.global().async {
            let identifier = Shell.run("diskutil list | grep EFI | awk '{print $6}' | head -1").trimmingCharacters(in: .whitespacesAndNewlines)
            if identifier.isEmpty {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            let script = "do shell script \"diskutil mount \(identifier)\" with administrator privileges"
            _ = Shell.run("osascript -e '\(script)'")
            Thread.sleep(forTimeInterval: 1.5)
            
            DispatchQueue.main.async {
                completion(PostInstallView.sharedMountedPath())
            }
        }
    }
    
    static func listEFIPartitions() -> [String] {
        let output = Shell.run("diskutil list | grep EFI | awk '{print $6}'")
        return output.components(separatedBy: "\n").filter { !$0.isEmpty }
    }
    
    static func mountSpecific(identifier: String) -> Bool {
        let script = "do shell script \"diskutil mount \(identifier)\" with administrator privileges"
        _ = Shell.run("osascript -e '\(script)'")
        Thread.sleep(forTimeInterval: 1.0)
        return FileManager.default.fileExists(atPath: "/Volumes/EFI/EFI/OC/config.plist") || 
               FileManager.default.fileExists(atPath: "/Volumes/ESP/EFI/OC/config.plist")
    }
    
    func checkEFI() {
        efiPath = PostInstallView.sharedMountedPath()
        isEFIMounted = efiPath != nil
        efiPartitions = PostInstallView.listEFIPartitions()
        if !isEFIMounted {
            statusMessage = "⚠️ EFI not detected or unmounted. Please Mount it to enable fixes."
        }
    }
    
    func manualMount() {
        statusMessage = "Requesting permission to mount EFI..."
        PostInstallView.autoMountEFI { path in
            self.efiPath = path
            self.isEFIMounted = path != nil
            if isEFIMounted {
                statusMessage = "✅ EFI Mounted: \(path!)"
            } else {
                statusMessage = "❌ Auto-mount failed. Use the manual Picker."
            }
        }
    }
    
    var body: some View {
        ZStack {
            GreenmixTheme.bg.edgesIgnoringSafeArea(.all)
            
            VStack {
                CommonHeader(title: "System Optimizer")
                
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(GreenmixTheme.accent)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.leading)
                    
                    Spacer()
                    Image(systemName: "wrench.and.screwdriver")
                        .font(.title)
                        .foregroundColor(GreenmixTheme.accent)
                        .padding(.trailing)
                }
                
                Text(statusMessage)
                    .foregroundColor(isEFIMounted ? GreenmixTheme.secondary : .red)
                    .font(.caption)
                    .padding(.bottom)
                
                if !isEFIMounted {
                    VStack {
                        Button(action: manualMount) {
                            HStack {
                                Image(systemName: "externaldrive.fill.badge.plus")
                                Text("Auto-Mount EFI")
                            }
                            .padding()
                            .background(Color.red.opacity(0.2))
                            .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if !efiPartitions.isEmpty {
                            Menu {
                                ForEach(efiPartitions, id: \.self) { ident in
                                    Button("Mount \(ident)") {
                                        if PostInstallView.mountSpecific(identifier: ident) {
                                            checkEFI()
                                        }
                                    }
                                }
                            } label: {
                                Text("Or Pick Manually ▾")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .padding(5)
                            }
                        }
                    }
                    .padding(.bottom, 10)
                }
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        
                        VStack(spacing: 5) {
                            DashboardButton(title: wifiStatus.vendor.contains("USB") ? "USB Wi-Fi Setup" : "Install Intel Wi-Fi", 
                                            subtitle: wifiStatus.vendor.contains("USB") ? "Get USB Drivers" : "Inject AirportItlwm", 
                                            icon: "wifi", 
                                            color: wifiStatus.vendor.contains("USB") ? .orange : (wifiStatus.vendor == "Intel" ? .green : .blue)) {
                                if wifiStatus.vendor == "Intel" {
                                    injectKext(name: "AirportItlwm", url: "https://github.com/OpenIntelWireless/itlwm/releases/download/v2.3.0/AirportItlwm_v2.3.0_stable_Sonoma.kext.zip")
                                } else if wifiStatus.vendor.contains("USB") {
                                    statusMessage = "Opening USB Wi-Fi Driver Repository..."
                                    _ = Shell.run("open https://github.com/chris1111/Wireless-USB-Adapter-Clover")
                                } else {
                                    statusMessage = "Safety Block: Intel Wi-Fi Kext is NOT for your \(wifiStatus.vendor) card."
                                }
                            }
                            Text(wifiStatus.status.label)
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(wifiStatus.status.color)
                        }
                        
                        VStack(spacing: 5) {
                            DashboardButton(title: btStatus.vendor.contains("USB") ? "USB BT Setup" : "Install Intel BT", 
                                            subtitle: btStatus.vendor.contains("USB") ? "Generic CSR Support" : "Inject IntelBT", 
                                            icon: "wave.3.right", 
                                            color: btStatus.vendor.contains("USB") ? .orange : (btStatus.vendor == "Intel" ? .green : .blue)) {
                                if btStatus.vendor == "Intel" {
                                    injectKext(name: "IntelBluetoothFirmware", url: "https://github.com/OpenIntelWireless/IntelBluetoothFirmware/releases/download/v2.4.0/IntelBluetoothFirmware-v2.4.0.zip")
                                } else if btStatus.vendor.contains("USB") {
                                    statusMessage = "USB Bluetooth detected. These often work natively or via BlueToolFixup."
                                } else {
                                    statusMessage = "Safety Block: This BT driver is for Intel cards only."
                                }
                            }
                            Text(btStatus.status.label)
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(btStatus.status.color)
                        }
                        
                        DashboardButton(title: "Fix \(audioName)", subtitle: "Inject alcid=1", icon: "speaker.wave.3.fill", color: .pink) {
                             fixAudio()
                        }
                        
                        DashboardButton(title: "USB Map Tool", subtitle: "Download App", icon: "cable.connector", color: .white) {
                             downloadUSBTool()
                        }
                        
                        DashboardButton(title: "Validate \(gpuName)", subtitle: "Check Metal Support", icon: "checkmark.seal.fill", color: .green) {
                             let metal = Shell.run("system_profiler SPDisplaysDataType | grep 'Metal'")
                             statusMessage = metal.isEmpty ? "Accelaration: UNKNOWN" : "Result: \(metal)"
                        }
                        
                        // NEW ADVANCED ROW
                        DashboardButton(title: "Freeze Analysis", subtitle: "Scan Crash Logs", icon: "binoculars.fill", color: .purple) {
                            statusMessage = "Analyzing logs... Please wait."
                            StabilityScanner.analyzeFreeze { result in
                                statusMessage = result
                            }
                        }
                        
                        DashboardButton(title: "SSD Health", subtitle: "Check Health & TRIM", icon: "memorychip", color: .blue) {
                            let ssd = StabilityScanner.checkSSDStatus()
                            statusMessage = "SSD Health: \(ssd.health) | TRIM: \(ssd.trim ? "ON" : "OFF")"
                        }
                        
                        DashboardButton(title: "Toggle TRIM", subtitle: "Enable/Disable TRIM", icon: "scissors", color: .cyan) {
                             toggleTrim()
                        }
                        
                        DashboardButton(title: "Rebuild Cache", subtitle: "Fix Kext Permissions", icon: "arrow.triangle.2.circlepath", color: .yellow) {
                             statusMessage = "Clearing caches and rebuilding kext database..."
                             _ = Shell.run("sudo kextcache -i / && sudo kextcache -u /")
                             statusMessage = "Caches rebuilt. Restart recommended."
                        }
                        
                        DashboardButton(title: "Smart Optimizer", subtitle: "Fix Stability & PM", icon: "wand.and.rays", color: .orange) {
                            runSmartOptimization()
                        }
                        
                        DashboardButton(title: "Premium ToolBox", subtitle: "SMBIOS, SIP, Vault", icon: "crown.fill", color: GreenmixTheme.gold) {
                            showingPremiumTools = true
                        }
                        
                        if HardwareScanner.isLaptop() {
                            DashboardButton(title: "Laptop Fixes", subtitle: "Battery & Trackpad", icon: "laptopcomputer", color: .orange) {
                                injectKext(name: "SMCBatteryManager", url: "https://github.com/acidanthera/VirtualSMC/releases/download/1.3.2/VirtualSMC-1.3.2-RELEASE.zip")
                            }
                        }
                        
                        DashboardButton(title: "Install Themes", subtitle: "Apple Icons Pack", icon: "photo.on.rectangle", color: .purple) {
                            statusMessage = AdvancedTools.installModernTheme()
                        }
                    }
                    .padding()
                }
                .padding()
                .sheet(isPresented: $showingPremiumTools) {
                    PremiumToolsView()
                }
                
                Spacer()
                
                Button("Exit") {
                    NSApplication.shared.terminate(nil)
                }
                .padding()
            }
        }
        .onAppear {
            scanHardware()
            checkEFI()
        }
    }
    
    // MARK: - Logic Helpers
    
    func scanHardware() {
        DispatchQueue.global().async {
            // Audio Scan
            let audioVendor = Shell.run("ioreg -rxn IOHDACodecDevice | grep VendorID | awk '{print $4}'").trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Wi-Fi & BT Scan
            let wStatus = HardwareScanner.scanWifi()
            let bStatus = HardwareScanner.scanBT()
            
            DispatchQueue.main.async {
                if audioVendor.contains("10ec") { self.audioName = "Realtek Audio" }
                else if !audioVendor.isEmpty { self.audioName = "Audio (\(audioVendor))" }
                else { self.audioName = "Audio (Unknown)" }
                
                self.wifiStatus = wStatus
                self.btStatus = bStatus
                
                let usbFound = wStatus.vendor.contains("USB") || bStatus.vendor.contains("USB")
                let usbMsg = usbFound ? "" : " (No USB hardware detected)"
                statusMessage = "Scan Complete: Found \(wStatus.vendor) Wifi & \(bStatus.vendor) BT.\(usbMsg)"
            }
        }
    }
    
    func getEFIPath() -> String? {
         _ = Shell.run("diskutil list | grep EFI | awk '{print $6}' | head -1 | xargs sudo diskutil mount 2>/dev/null")
         Thread.sleep(forTimeInterval: 0.5)
         
         if FileManager.default.fileExists(atPath: "/Volumes/EFI/EFI/OC/config.plist") { return "/Volumes/EFI/EFI/OC" }
         if FileManager.default.fileExists(atPath: "/Volumes/ESP/EFI/OC/config.plist") { return "/Volumes/ESP/EFI/OC" }
         return nil
    }
    
    func fixAudio() {
        statusMessage = "Fixing Audio..."
        DispatchQueue.global().async {
            DispatchQueue.main.async { statusMessage = "Mounting EFI..." }
            
            guard let efiPath = getEFIPath() else {
                 DispatchQueue.main.async { statusMessage = "Error: EFI not found or could not mount." }
                 return
            }
            
            let configPath = "\(efiPath)/config.plist"
            DispatchQueue.main.async { statusMessage = "Injecting alcid=1 into boot-args..." }
            
            _ = Shell.run("cp \"\(configPath)\" \"\(configPath).bak\"")
            
            let key = ":NVRAM:Add:7C436110-AB2A-4BBB-A880-FE41995C9F82:boot-args"
            let currentArgs = Shell.run("/usr/libexec/PlistBuddy -c \"Print \(key)\" \"\(configPath)\"")
            
            if currentArgs.contains("alcid=") {
                DispatchQueue.main.async { statusMessage = "Audio layout already set: \(currentArgs)" }
                return
            }
            
            let newArgs = currentArgs.replacingOccurrences(of: "\"", with: "") + " alcid=1"
            _ = Shell.run("/usr/libexec/PlistBuddy -c \"Set \(key) '\(newArgs)'\" \"\(configPath)\"")
            
            DispatchQueue.main.async { statusMessage = "Success: alcid=1 injected. Restart to apply." }
        }
    }
    
    func runSmartOptimization() {
        statusMessage = "Starting Smart Optimization..."
        DispatchQueue.global().async {
            // 1. Check Power Management
            let pmStatus = StabilityScanner.checkPowerManagement()
            if pmStatus.contains("Sub-optimal") {
                DispatchQueue.main.async { statusMessage = "Optimizing Power: Setting hibernatemode 0..." }
                _ = Shell.run("sudo pmset -a hibernatemode 0")
            }
            
            // 2. EFI Safe Checks (TRIM / Quirks)
            DispatchQueue.main.async { statusMessage = "Checking EFI Quirks..." }
            guard let efiPath = getEFIPath() else {
                 DispatchQueue.main.async { statusMessage = "Optimization partial: Could not mount EFI for advanced fixes." }
                 return
            }
            
            let configPath = "\(efiPath)/config.plist"
            _ = Shell.run("cp \"\(configPath)\" \"\(configPath).bak\"")
            
            // Enable ThirdPartyDrives if TRIM is off
            let ssd = StabilityScanner.checkSSDStatus()
            if !ssd.trim {
                DispatchQueue.main.async { statusMessage = "Enabling ThirdPartyDrives (TRIM Support)..." }
                _ = Shell.run("/usr/libexec/PlistBuddy -c \"Set :Kernel:Quirks:ThirdPartyDrives true\" \"\(configPath)\"")
            }
            
            // Disable native TRIM timeout for stability on some SSDs
            _ = Shell.run("/usr/libexec/PlistBuddy -c \"Set :Kernel:Quirks:SetApfsTrimTimeout 0\" \"\(configPath)\"")
            
            // Performance Tuning - Inject CPU Friend if needed (Placeholder logic for now)
            // _ = Shell.run("cp -R \"\(Bundle.main.resourcePath!)/CPUFriend.kext\" \"\(efiPath)/Kexts/\"")
            
            DispatchQueue.main.async { statusMessage = "Optimization Complete: SSD, Power, and EFI Tweaked safely." }
        }
    }
    
    func toggleTrim() {
        statusMessage = "Toggling TRIM Quirk..."
        DispatchQueue.global().async {
            guard let efiPath = getEFIPath() else {
                 DispatchQueue.main.async { statusMessage = "Error: EFI not mounted." }
                 return
            }
            let configPath = "\(efiPath)/config.plist"
            _ = Shell.run("cp \"\(configPath)\" \"\(configPath).bak\"")
            
            let current = Shell.run("/usr/libexec/PlistBuddy -c \"Print :Kernel:Quirks:ThirdPartyDrives\" \"\(configPath)\"")
            let newState = current.contains("true") ? "false" : "true"
            _ = Shell.run("/usr/libexec/PlistBuddy -c \"Set :Kernel:Quirks:ThirdPartyDrives \(newState)\" \"\(configPath)\"")
            
            DispatchQueue.main.async { statusMessage = "Success: TRIM Quirk set to \(newState). Reboot required." }
        }
    }
    
    func clearKextCache() {
        statusMessage = "Clearing caches and rebuilding kext database..."
        DispatchQueue.global().async {
            _ = Shell.run("sudo kextcache -i / && sudo kextcache -u /")
            DispatchQueue.main.async {
                statusMessage = "Caches rebuilt. Restart recommended."
            }
        }
    }
    
    func downloadUSBTool() {
        statusMessage = "Downloading USBToolBox..."
        DispatchQueue.global(qos: .userInitiated).async {
            let url = "https://github.com/USBToolBox/tool/releases/download/0.1.1/macOS.zip"
            let downloadsFolder = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!.path
            let dest = "\(downloadsFolder)/USBToolBox"
            
            _ = Shell.run("mkdir -p \"\(dest)\"")
            _ = Shell.run("curl -L -o \"\(dest)/tool.zip\" \(url)")
            _ = Shell.run("unzip -q -o \"\(dest)/tool.zip\" -d \"\(dest)\"")
            
            if FileManager.default.fileExists(atPath: "\(dest)/macOS") {
                 _ = Shell.run("mv \"\(dest)/macOS\" \"\(dest)/USBToolBox\"")
            }
            
            _ = Shell.run("chmod +x \"\(dest)/USBToolBox\"")
            _ = Shell.run("xattr -cr \"\(dest)/USBToolBox\"")
            
            DispatchQueue.main.async {
                if FileManager.default.fileExists(atPath: "\(dest)/USBToolBox") {
                    statusMessage = "Launching USBToolBox..."
                    let launchCmd = "open -a Terminal \"\(dest)/USBToolBox\""
                    _ = Shell.run(launchCmd)
                } else {
                    statusMessage = "Error: Download failed or binary missing."
                }
            }
        }
    }
    
    func injectKext(name: String, url: String) {
        statusMessage = "Starting Injection Process for \(name)..."
        DispatchQueue.global().async {
            DispatchQueue.main.async { statusMessage = "Mounting EFI..." }
            
            guard let efiPath = getEFIPath() else {
                 DispatchQueue.main.async { statusMessage = "Error: EFI not found. Mount manually?" }
                 return
            }
            
            DispatchQueue.main.async { statusMessage = "Downloading \(name)..." }
            let temp = "/tmp/hackintune_driver"
            _ = Shell.run("rm -rf \(temp) && mkdir -p \(temp)")
            _ = Shell.run("curl -L -o \(temp)/\(name).zip \(url)")
            _ = Shell.run("unzip -q -o \(temp)/\(name).zip -d \(temp)")
            
            DispatchQueue.main.async { statusMessage = "Copying Kext to EFI..." }
            let kextSource = Shell.run("find \(temp) -name '*.kext' | head -1")
            
            if kextSource.isEmpty {
                 DispatchQueue.main.async { statusMessage = "Error: No Kext found in download." }
                 return
            }
            
            let kextName = URL(fileURLWithPath: kextSource).lastPathComponent
            let kextDest = "\(efiPath)/Kexts/\(kextName)"
            
            _ = Shell.run("cp -r \"\(kextSource)\" \"\(kextDest)\"")
            
            DispatchQueue.main.async { statusMessage = "Injecting into Config.plist..." }
            let configPath = "\(efiPath)/config.plist"
            _ = Shell.run("cp \"\(configPath)\" \"\(configPath).bak\"")
            
            let plistScript = """
            /usr/libexec/PlistBuddy -c "Add :Kernel:Add:0 dict" "\(configPath)"
            /usr/libexec/PlistBuddy -c "Add :Kernel:Add:0:BundlePath string \(kextName)" "\(configPath)"
            /usr/libexec/PlistBuddy -c "Add :Kernel:Add:0:Enabled bool true" "\(configPath)"
            /usr/libexec/PlistBuddy -c "Add :Kernel:Add:0:ExecutablePath string Contents/MacOS/\(kextName.replacingOccurrences(of: ".kext", with: ""))" "\(configPath)"
            /usr/libexec/PlistBuddy -c "Add :Kernel:Add:0:PlistPath string Contents/Info.plist" "\(configPath)"
            """
            _ = Shell.run(plistScript)
            
            DispatchQueue.main.async {
                statusMessage = "Success! \(kextName) injected. Please Reboot."
            }
        }
    }
}

// MARK: - Pre-Install Dashboard (v5.1)
struct PreInstallDashboard: View {
    var onBack: () -> Void
    @State private var showingEFIBuilder = false
    @State private var showingInstaller = false

    var body: some View {
        HStack(spacing: 30) {
            // Button 1: EFI Builder
            Button(action: { showingEFIBuilder = true }) {
                VStack(spacing: 20) {
                    Image(systemName: "cpu")
                        .font(.system(size: 50))
                        .foregroundColor(GreenmixTheme.gold)
                    Text("EFI Builder")
                        .font(.title2).bold()
                        .foregroundColor(GreenmixTheme.text)
                    Text("Select Parts & Generate")
                        .font(.caption)
                        .foregroundColor(GreenmixTheme.secondary)
                }
                .frame(width: 250, height: 250)
                .background(GreenmixTheme.card)
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(GreenmixTheme.gold.opacity(0.5), lineWidth: 2))
            }
            .buttonStyle(PlainButtonStyle())
            .sheet(isPresented: $showingEFIBuilder) {
                HardwarePickerView()
            }
            
            // Button 2: macOS Installer
            Button(action: { showingInstaller = true }) {
                VStack(spacing: 20) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    Text("OS Installer")
                        .font(.title2).bold()
                        .foregroundColor(GreenmixTheme.text)
                    Text("Download & Flash USB")
                        .font(.caption)
                        .foregroundColor(GreenmixTheme.secondary)
                }
                .frame(width: 250, height: 250)
                .background(GreenmixTheme.card)
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.blue.opacity(0.5), lineWidth: 2))
            }
            .buttonStyle(PlainButtonStyle())
            .sheet(isPresented: $showingInstaller) {
                InstallerCreatorView()
            }
        }
        .padding()
    }
}

// MARK: - Installer Creator View
struct InstallerCreatorView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var shell = AsyncShell()
    
    @State private var installers: [macOSInstaller] = []
    @State private var selectedInstaller: macOSInstaller? = nil
    @State private var status = "Scanning Apple Servers..."
    @State private var targetVolume = ""
    @State private var volumes: [String] = []
    @State private var isScanning = true
    
    struct macOSInstaller: Hashable, Identifiable {
        let id = UUID()
        let title: String
        let version: String
        let fullLabel: String
    }
    
    var body: some View {
        ZStack {
            GreenmixTheme.bg.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                CommonHeader(title: "")
                
                HStack {
                    Text("macOS USB Creator")
                        .font(.title).bold() // Reduced size slightly as it's a sub-header now
                        .foregroundColor(GreenmixTheme.text)
                    Spacer()
                    Button("Close") {
                         if shell.isRunning {
                             shell.cancel()
                         }
                         presentationMode.wrappedValue.dismiss()
                    }
                }
                .padding(.horizontal)
                
                // 1. Download
                VStack(alignment: .leading, spacing: 10) {
                    Text("1. Download macOS Installer").font(.headline).foregroundColor(GreenmixTheme.accent)
                    
                    if isScanning {
                        HStack {
                            ProgressView().scaleEffect(0.5)
                            Text("Fetching available versions...").font(.caption)
                        }
                    } else {
                        HStack {
                            if installers.isEmpty {
                                Text("No installers found.").foregroundColor(.red)
                            } else {
                                Picker("Version:", selection: $selectedInstaller) {
                                    ForEach(installers) { installer in
                                        Text(installer.fullLabel).tag(installer as macOSInstaller?)
                                    }
                                }
                                .frame(width: 250)
                                
                                Button("Download") {
                                    downloadInstaller()
                                }
                                .disabled(selectedInstaller == nil || shell.isRunning)
                                
                                if shell.isRunning {
                                    Button("Cancel") { shell.cancel() }
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(GreenmixTheme.card)
                .cornerRadius(10)
                
                // 2. Create USB
                VStack(alignment: .leading, spacing: 10) {
                    Text("2. Create Bootable USB").font(.headline).foregroundColor(GreenmixTheme.gold)
                    Text("Select your USB drive (Warning: Will be Erased)").font(.caption).foregroundColor(.gray)
                    
                    HStack {
                        Picker("Target USB:", selection: $targetVolume) {
                            if volumes.isEmpty {
                                Text("No External Drives").tag("")
                            } else {
                                ForEach(volumes, id: \.self) { vol in
                                    Text(vol).tag(vol)
                                }
                            }
                        }
                        .frame(width: 200)
                        
                        Button(action: { listVolumes() }) {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    
                    Button("Flash USB (Requires Password)") {
                         createMedia()
                    }
                    .disabled(targetVolume.isEmpty || targetVolume == "Macintosh HD" || shell.isRunning)
                    .foregroundColor(shell.isRunning ? .gray : (targetVolume.isEmpty ? .gray : .white))
                    .padding(8)
                    .background(targetVolume.isEmpty ? Color.gray.opacity(0.3) : Color.blue) // Changed to Blue for visibility
                    .cornerRadius(8)
                }
                .padding()
                .background(GreenmixTheme.card)
                .cornerRadius(10)
                
                ScrollView {
                    VStack(alignment: .leading) {
                        Text(status)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(GreenmixTheme.text)
                        
                        if !shell.output.isEmpty {
                            Text(shell.output)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                }
                .frame(height: 150)
                .background(Color.black.opacity(0.3))
                .cornerRadius(8)
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            listVolumes()
            fetchInstallers()
        }
    }
    
    func listVolumes() {
        let out = Shell.run("ls /Volumes")
        volumes = out.components(separatedBy: "\n").filter { 
            !$0.isEmpty && $0 != "Macintosh HD" && $0 != "Macintosh HD - Data" && !$0.contains("TimeMachine")
        }
        if let first = volumes.first { targetVolume = first }
        else { targetVolume = "" }
    }
    
    func fetchInstallers() {
        DispatchQueue.global().async {
            let output = Shell.run("softwareupdate --list-full-installers")
            var newInstallers: [macOSInstaller] = []
            let lines = output.components(separatedBy: "\n")
            for line in lines {
                if line.contains("Title:") && line.contains("Version:") {
                    let titlePart = line.components(separatedBy: "Title: ")[1].components(separatedBy: ",")[0]
                    let versionPart = line.components(separatedBy: "Version: ")[1].components(separatedBy: ",")[0]
                    let installer = macOSInstaller(title: titlePart, version: versionPart, fullLabel: "\(titlePart) (\(versionPart))")
                    newInstallers.append(installer)
                }
            }
            DispatchQueue.main.async {
                self.installers = newInstallers
                self.selectedInstaller = newInstallers.first
                self.isScanning = false
                self.status = "Found \(newInstallers.count) available installers."
            }
        }
    }
    
    func downloadInstaller() {
        guard let installer = selectedInstaller else { return }
        status = "Downloading \(installer.title)..."
        // Use AsyncShell for real-time progress
        shell.run("softwareupdate --fetch-full-installer --full-installer-version \(installer.version)")
    }
    
    func createMedia() {
        guard let installer = selectedInstaller else { return }
        let appName = "Install \(installer.title).app" 
        let path = "/Applications/\(appName)/Contents/Resources/createinstallmedia"
        let cmd = "sudo \"\(path)\" --volume \"/Volumes/\(targetVolume)\" --nointeraction"
        
        // sudo requires password. Since we use AsyncShell inside app, we can't easily interface with TTY sudo.
        // We must fallback to AppleScript for the SUDO part, but we can't get real-time output easily from AppleScript `do shell script`.
        // COMPROMISE: We will keep AppleScript for High Privileges, improving the status message.
        // OR: We can try running it via AsyncShell but we'd need to handle password input which is risky/complex.
        // Stick to AppleScript for Flash, AsyncShell for Download.
        
        let script = "do shell script \"\(cmd)\" with administrator privileges"
        status = "Flashing USB... (Check progress in Activity Monitor or wait ~20 mins)"
        
        DispatchQueue.global().async {
            var error: NSDictionary?
            if let scriptObject = NSAppleScript(source: script) {
                scriptObject.executeAndReturnError(&error)
            }
            DispatchQueue.main.async {
                if let err = error {
                    status = "Error: \(err)"
                } else {
                    status = "Success! Bootable USB Created."
                }
            }
        }
    }
}


// MARK: - Async Shell (v5.3 Process Handler)
class AsyncShell: ObservableObject {
    @Published var output: String = ""
    @Published var isRunning: Bool = false
    
    private var task: Process?
    private var pipe: Pipe?
    
    func run(_ command: String) {
        DispatchQueue.main.async {
            self.output = ""
            self.isRunning = true
        }
        
        task = Process()
        pipe = Pipe()
        
        task?.standardOutput = pipe
        task?.standardError = pipe
        task?.arguments = ["-c", command]
        task?.launchPath = "/bin/bash"
        
        let handle = pipe?.fileHandleForReading
        handle?.readabilityHandler = { [weak self] fileHandle in
            let data = fileHandle.availableData
            if data.count > 0 {
                if let str = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        self?.output += str
                    }
                }
            }
        }
        
        task?.terminationHandler = { [weak self] _ in
            DispatchQueue.main.async {
                self?.isRunning = false
            }
            try? handle?.close()
        }
        
        do {
            try task?.run()
        } catch {
            DispatchQueue.main.async {
                self.output += "\nError launching command: \(error)"
                self.isRunning = false
            }
        }
    }
    
    func cancel() {
        task?.terminate()
        DispatchQueue.main.async {
            self.output += "\n[Cancelled by User]"
            self.isRunning = false
        }
    }
}
