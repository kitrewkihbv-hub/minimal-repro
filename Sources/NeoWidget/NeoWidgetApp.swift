import SwiftUI
import WidgetKit
#if canImport(NeoWidgetShared)
import NeoWidgetShared
#endif

@main
struct NeoWidgetApp: App {
    @StateObject private var store = WidgetStore()
    @StateObject private var liveData = LiveDataProvider.shared

    init() {
        LiveDataProvider.shared.startPolling()
    }

    var body: some Scene {
        WindowGroup {
            StudioEditorView()
                .environmentObject(store)
                .environmentObject(liveData)
                .frame(minWidth: 1100, minHeight: 720)
                .onOpenURL { url in
                    handleOpenURL(url)
                }
        }
        .windowStyle(.titleBar)
        .commands {
            CommandGroup(replacing: .newItem) { }
            CommandGroup(after: .importExport) {
                Button("Export .neowidget...") { store.exportCurrentSlot() }
                    .keyboardShortcut("e", modifiers: [.command, .shift])
                Button("Import .neowidget...") { store.importToCurrentSlot() }
                    .keyboardShortcut("i", modifiers: [.command, .shift])
                Divider()
                Button("Apply to Desktop Widget") {
                    store.save()
                    WidgetCenter.shared.reloadAllTimelines()
                }
                .keyboardShortcut("r", modifiers: [.command, .shift])
            }
        }
    }

    private func handleOpenURL(_ url: URL) {
        guard url.scheme == "neowidget" else { return }
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let slot = components.queryItems?.first(where: { $0.name == "slot" })?.value {
            if store.slots[slot] != nil {
                store.currentSlotId = slot
            }
        }
    }
}
