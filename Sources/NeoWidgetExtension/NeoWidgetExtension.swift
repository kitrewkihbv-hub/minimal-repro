import WidgetKit
import SwiftUI
import AppIntents
#if canImport(NeoWidgetShared)
import NeoWidgetShared
#endif

// MARK: - Timeline Entry

struct NeoWidgetEntry: TimelineEntry {
    let date: Date
    let config: WidgetConfig?
    let slotId: String
    let snapshot: DataSnapshot
}

struct DataSnapshot {
    var battery: Int
    var ram: Int
    var weatherTemp: String
    var weatherCond: String
    var musicTitle: String
    var musicArtist: String

    static func from(_ p: LiveDataProvider) -> DataSnapshot {
        DataSnapshot(battery: p.batteryLevel, ram: p.ramUsedPercent,
                     weatherTemp: p.weatherTemp, weatherCond: p.weatherCond,
                     musicTitle: p.musicTitle, musicArtist: p.musicArtist)
    }

    func apply(to provider: LiveDataProvider) {
        provider.batteryLevel = battery
        provider.ramUsedPercent = ram
        provider.weatherTemp = weatherTemp
        provider.weatherCond = weatherCond
        provider.musicTitle = musicTitle
        provider.musicArtist = musicArtist
    }
}

// MARK: - Provider

struct NeoWidgetProvider: AppIntentTimelineProvider {
    typealias Entry = NeoWidgetEntry
    typealias Intent = SelectSlotIntent

    func placeholder(in context: Context) -> NeoWidgetEntry {
        NeoWidgetEntry(date: Date(), config: NeoPresets.defaultSlots()["Slot 1"], slotId: "Slot 1", snapshot: .from(LiveDataProvider.shared))
    }

    func snapshot(for configuration: SelectSlotIntent, in context: Context) async -> NeoWidgetEntry {
        let slotId = configuration.slot?.identifier ?? "Slot 1"
        let store = WidgetStore()
        let config = store.slots[slotId] ?? NeoPresets.defaultSlots()[slotId]
        let provider = LiveDataProvider.shared
        provider.refreshAll()
        return NeoWidgetEntry(date: Date(), config: config, slotId: slotId, snapshot: .from(provider))
    }

    func timeline(for configuration: SelectSlotIntent, in context: Context) async -> Timeline<NeoWidgetEntry> {
        let slotId = configuration.slot?.identifier ?? "Slot 1"
        let store = WidgetStore()
        let config = store.slots[slotId] ?? NeoPresets.defaultSlots()[slotId]

        let provider = LiveDataProvider.shared
        provider.refreshAll()
        // Give weather a moment to fetch if possible
        if provider.weatherCache == nil {
            provider.refreshWeatherIfNeeded(force: true)
            try? await Task.sleep(nanoseconds: 1_500_000_000)
        }
        let snap = DataSnapshot.from(provider)

        let now = Date()
        var entries: [NeoWidgetEntry] = []
        // Generate entries for the next hour, every 5 minutes, so clock/formulas update
        for offset in stride(from: 0, to: 60, by: 5) {
            let d = Calendar.current.date(byAdding: .minute, value: offset, to: now) ?? now
            entries.append(NeoWidgetEntry(date: d, config: config, slotId: slotId, snapshot: snap))
        }
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 15, to: now) ?? now.addingTimeInterval(900)
        return Timeline(entries: entries, policy: .after(nextRefresh))
    }
}

// MARK: - Widget View

struct NeoWidgetView: View {
    var entry: NeoWidgetEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        let provider = LiveDataProvider.shared
        let _ = entry.snapshot.apply(to: provider)

        GeometryReader { geo in
            ZStack {
                LinearGradient(colors: [Color(red: 0.05, green: 0.05, blue: 0.09),
                                        Color(red: 0.02, green: 0.02, blue: 0.04)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)

                if let config = entry.config {
                    let scale = min(geo.size.width / max(config.canvasWidth, 1),
                                    geo.size.height / max(config.canvasHeight, 1))
                    ZStack {
                        ForEach(config.elements.sorted(by: { $0.zIndex < $1.zIndex })) { element in
                            ElementRenderer(element: element, date: entry.date, provider: provider)
                                .position(x: element.x, y: element.y)
                        }
                    }
                    .frame(width: config.canvasWidth, height: config.canvasHeight)
                    .scaleEffect(scale)
                    .frame(width: geo.size.width, height: geo.size.height)
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "square.dashed")
                            .font(.system(size: 28))
                            .foregroundStyle(.secondary)
                        Text("Empty \(entry.slotId)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .containerBackground(for: .widget) {
            Color.black
        }
    }
}

// MARK: - Widget

struct NeoWidgetMain: Widget {
    let kind: String = "NeoWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectSlotIntent.self, provider: NeoWidgetProvider()) { entry in
            NeoWidgetView(entry: entry)
                .widgetURL(URL(string: "neowidget://editor?slot=\(entry.slotId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? entry.slotId)"))
        }
        .configurationDisplayName("NeoWidget")
        .description("KWGT-style custom widget. Choose one of 8 slots configured in NeoWidget Studio.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
        .contentMarginsDisabled()
    }
}

@main
struct NeoWidgetBundle: WidgetBundle {
    var body: some Widget {
        NeoWidgetMain()
    }
}

// MARK: - AppIntent: Slot Selection

struct SelectSlotIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select NeoWidget Slot"
    static var description = IntentDescription("Choose which NeoWidget slot to display on your desktop.")

    @Parameter(title: "Slot", default: SlotEntity.defaultSlot)
    var slot: SlotEntity?
}

struct SlotEntity: AppEntity, Identifiable, Hashable {
    var id: String { identifier }
    let identifier: String
    let displayString: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Widget Slot"
    static var defaultQuery = SlotQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(displayString)")
    }

    static let defaultSlot = SlotEntity(identifier: "Slot 1", displayString: "Slot 1 — Tall Neon Cyber Clock")

    static let allSlots: [SlotEntity] = [
        SlotEntity(identifier: "Slot 1", displayString: "Slot 1 — Tall Neon Cyber Clock"),
        SlotEntity(identifier: "Slot 2", displayString: "Slot 2 — Ultra-Long Stretched Vertical Clock"),
        SlotEntity(identifier: "Slot 3", displayString: "Slot 3 — Frosted Apple Music/Spotify Player"),
        SlotEntity(identifier: "Slot 4", displayString: "Slot 4 — Neon Weather & Forecast Card"),
        SlotEntity(identifier: "Slot 5", displayString: "Slot 5 — Retro Hacker System Monitor"),
        SlotEntity(identifier: "Slot 6", displayString: "Slot 6 — Aesthetic Photo Frame"),
        SlotEntity(identifier: "Slot 7", displayString: "Slot 7 — Minimal Analog Neon Clock"),
        SlotEntity(identifier: "Slot 8", displayString: "Slot 8 — All-in-One Cyber Dashboard"),
    ]
}

struct SlotQuery: EntityQuery {
    func entities(for identifiers: [SlotEntity.ID]) async throws -> [SlotEntity] {
        SlotEntity.allSlots.filter { identifiers.contains($0.identifier) }
    }

    func suggestedEntities() async throws -> [SlotEntity] {
        SlotEntity.allSlots
    }

    func defaultResult() async -> SlotEntity? {
        SlotEntity.defaultSlot
    }
}
