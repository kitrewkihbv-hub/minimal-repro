import WidgetKit
import SwiftUI
import AppIntents
#if canImport(NeoWidgetShared)
import NeoWidgetShared
#endif

struct NeoWidgetEntry: TimelineEntry {
    let date: Date
    let config: WidgetConfig?
    let slotId: String
}

struct NeoWidgetProvider: AppIntentTimelineProvider {
    typealias Entry = NeoWidgetEntry
    typealias Intent = SelectSlotIntent // Custom intent for slot selection
    
    func placeholder(in context: Context) -> NeoWidgetEntry {
        NeoWidgetEntry(date: Date(), config: nil, slotId: "Slot 1")
    }

    func snapshot(for intent: SelectSlotIntent, in context: Context) async -> NeoWidgetEntry {
        return NeoWidgetEntry(date: Date(), config: nil, slotId: intent.slot?.identifier ?? "Slot 1")
    }

    func timeline(for intent: SelectSlotIntent, in context: Context) async -> Timeline<NeoWidgetEntry> {
        let store = WidgetStore()
        let slotId = intent.slot?.identifier ?? "Slot 1"
        let config = store.slots[slotId]
        
        let entry = NeoWidgetEntry(date: Date(), config: config, slotId: slotId)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        return timeline
    }
}

// WidgetBundle for macOS Right-Click Desktop -> Edit Widgets
@main
struct NeoWidgetBundle: WidgetBundle {
    var body: some Widget {
        NeoWidgetSmall()
        NeoWidgetMedium()
        NeoWidgetLarge()
        NeoWidgetExtraLarge()
    }
}

struct NeoWidgetSmall: Widget {
    let kind: String = "NeoWidgetSmall"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectSlotIntent.self, provider: NeoWidgetProvider()) { entry in
            NeoWidgetView(entry: entry)
                .widgetURL(URL(string: "neowidget://editor?slot=\(entry.slotId)"))
        }
        .configurationDisplayName("NeoWidget Slot")
        .description("KWGT-style macOS Widget (Small)")
        .supportedFamilies([.accessoryCircular, .accessoryCorner, .accessoryInline, .accessoryRectangular, .systemSmall])
    }
}

struct NeoWidgetMedium: Widget {
    let kind: String = "NeoWidgetMedium"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectSlotIntent.self, provider: NeoWidgetProvider()) { entry in
            NeoWidgetView(entry: entry)
                .widgetURL(URL(string: "neowidget://editor?slot=\(entry.slotId)"))
        }
        .configurationDisplayName("NeoWidget Slot")
        .description("KWGT-style macOS Widget (Medium)")
        .supportedFamilies([.systemMedium])
    }
}

struct NeoWidgetLarge: Widget {
    let kind: String = "NeoWidgetLarge"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectSlotIntent.self, provider: NeoWidgetProvider()) { entry in
            NeoWidgetView(entry: entry)
                .widgetURL(URL(string: "neowidget://editor?slot=\(entry.slotId)"))
        }
        .configurationDisplayName("NeoWidget Slot")
        .description("KWGT-style macOS Widget (Large)")
        .supportedFamilies([.systemLarge])
    }
}

struct NeoWidgetExtraLarge: Widget {
    let kind: String = "NeoWidgetExtraLarge"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectSlotIntent.self, provider: NeoWidgetProvider()) { entry in
            NeoWidgetView(entry: entry)
                .widgetURL(URL(string: "neowidget://editor?slot=\(entry.slotId)"))
        }
        .configurationDisplayName("NeoWidget Slot")
        .description("KWGT-style macOS Widget (Extra Large)")
        .supportedFamilies([.systemExtraLarge])
    }
}

struct NeoWidgetView: View {
    var entry: NeoWidgetEntry
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
            if let config = entry.config {
                ForEach(config.elements) { element in
                    ElementView(element: element)
                        .scaleEffect(x: element.scaleX, y: element.scaleY)
                        .shadow(color: element.neonColor?.color ?? .clear, radius: 10)
                        .blur(radius: element.glassBlur)
                }
            } else {
                Text("Empty Slot \(entry.slotId)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

// Intent for slot selection in macOS Widget Gallery
struct SelectSlotIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Slot"
    static var description: LocalizedStringResource = "Choose which KWGT slot to display"
    
    @Parameter(title: "Slot")
    var slot: SlotEntity?
}

struct SlotEntity: AppEntity, Identifiable {
    var id: String { identifier }
    let identifier: String
    let displayString: String
    
    static var typeDisplayString: LocalizedStringResource = "Slot"
    static var allSlots: [SlotEntity] = [
        SlotEntity(identifier: "Slot 1", displayString: "Slot 1: Tall Neon Cyber Clock"),
        SlotEntity(identifier: "Slot 2", displayString: "Slot 2: Ultra-Long Vertical Digital Clock"),
        SlotEntity(identifier: "Slot 3", displayString: "Slot 3: Glass Apple Music/Spotify Player"),
        SlotEntity(identifier: "Slot 4", displayString: "Slot 4: Neon Weather Card"),
        SlotEntity(identifier: "Slot 5", displayString: "Slot 5: Retro System Stats"),
        SlotEntity(identifier: "Slot 6", displayString: "Slot 6: Aesthetic Photo Frame"),
        SlotEntity(identifier: "Slot 7", displayString: "Slot 7: Minimal Analog Neon Clock"),
        SlotEntity(identifier: "Slot 8", displayString: "Slot 8: All-in-One Cyber Dashboard")
    ]
    
    static func entities(for identifiers: [String]) async throws -> [SlotEntity] {
        return allSlots.filter { identifiers.contains($0.identifier) }
    }
    
    static var defaultQuery: some EntityQuery {
        StaticEntityQuery(allSlots)
    }
}
