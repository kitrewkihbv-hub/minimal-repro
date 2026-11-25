import SwiftUI
import WidgetKit
import AppIntents
#if canImport(NeoWidgetShared)
import NeoWidgetShared
#endif

@main
struct NeoWidgetApp: App {
    @StateObject private var store = WidgetStore()
    
    var body: some Scene {
        WindowGroup {
            StudioEditorView()
                .environmentObject(store)
                .onOpenURL { url in
                    // Handle widgetURL click from desktop widget
                    if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                       let slotId = components.queryItems?.first(where: { $0.name == "slot" })?.value {
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
