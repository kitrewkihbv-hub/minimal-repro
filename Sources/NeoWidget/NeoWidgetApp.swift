import SwiftUI
import WidgetKit
import AppIntents

@main
struct NeoWidgetApp: App {
    @StateObject private var store = WidgetStore()
    
    var body: some Scene {
        WindowGroup {
            StudioEditorView()
                .environmentObject(store)
                .onOpenURL { url in
                    // Handle widgetURL click from desktop widget
                    if let slotId = url.queryParameters?["slot"] {
                        store.currentSlotId = slotId
                    }
                }
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Export .neowidget") { store.exportCurrent() }
                Button("Import .neowidget") { store.importCurrent() }
            }
        }
    }
}

// Shared Data Store (App Group / Shared Container)
class WidgetStore: ObservableObject {
    @Published var currentSlotId: String = "Slot 1"
    @Published var slots: [String: WidgetConfig] = [:]
    let containerURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("NeoWidget")
    
    init() {
        loadPresets()
    }
    
    func loadPresets() {
        // 8 Built-in Presets
        slots["Slot 1"] = WidgetConfig(name: "Tall Neon Cyber Clock", type: .clock, elements: [WidgetElement(type: .clock, content: "$df(hh:mm)$", neonColor: .cyan, scaleX: 1, scaleY: 2)])
        slots["Slot 2"] = WidgetConfig(name: "Ultra-Long Vertical Digital Clock", type: .clock, elements: [WidgetElement(type: .clock, content: "$df(hh:mm)$", neonColor: .purple, scaleX: 0.5, scaleY: 3)])
        slots["Slot 3"] = WidgetConfig(name: "Glass Apple Music/Spotify Player", type: .media, elements: [WidgetElement(type: .media, content: "Track - Artist", glassBlur: 10)])
        slots["Slot 4"] = WidgetConfig(name: "Neon Weather Card", type: .weather, elements: [WidgetElement(type: .weather, content: "22°C", neonColor: .blue)])
        slots["Slot 5"] = WidgetConfig(name: "Retro System Stats", type: .stats, elements: [WidgetElement(type: .text, content: "CPU: 12% | RAM: 4GB", neonColor: .green)])
        slots["Slot 6"] = WidgetConfig(name: "Aesthetic Photo Frame", type: .image, elements: [WidgetElement(type: .image, content: "photo.png", glassBlur: 0)])
        slots["Slot 7"] = WidgetConfig(name: "Minimal Analog Neon Clock", type: .clock, elements: [WidgetElement(type: .clock, content: "Analog", neonColor: .red, scaleX: 1, scaleY: 1)])
        slots["Slot 8"] = WidgetConfig(name: "All-in-One Cyber Dashboard", type: .dashboard, elements: [
            WidgetElement(type: .clock, content: "$df(hh:mm)$", neonColor: .cyan),
            WidgetElement(type: .weather, content: "22°C", neonColor: .blue),
            WidgetElement(type: .media, content: "Track", glassBlur: 5)
        ])
        save()
    }
    
    func save() {
        // Save to ~/Library/Application Support/NeoWidget/
        try? FileManager.default.createDirectory(at: containerURL, withIntermediateDirectories: true)
        let data = try? JSONEncoder().encode(slots)
        try? data?.write(to: containerURL.appendingPathComponent("data.json"))
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func exportCurrent() {
        // Export .neowidget logic
    }
    
    func importCurrent() {
        // Import .neowidget logic
    }
}

struct WidgetConfig: Codable {
    var name: String
    var type: WidgetType
    var elements: [WidgetElement]
}

enum WidgetType: String, Codable {
    case clock, media, weather, stats, image, dashboard
}

struct WidgetElement: Codable, Identifiable {
    var id = UUID()
    var type: WidgetType
    var content: String
    var neonColor: Color? = nil
    var glassBlur: CGFloat = 0
    var scaleX: CGFloat = 1
    var scaleY: CGFloat = 1
    var zIndex: Int = 0
}
