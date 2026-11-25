import SwiftUI
import WidgetKit
import Foundation
#if canImport(AppKit)
import AppKit
import UniformTypeIdentifiers
#endif

public final class WidgetStore: ObservableObject {
    @Published public var currentSlotId: String = "Slot 1"
    @Published public var slots: [String: WidgetConfig] = [:]
    @Published public var selectedElementId: UUID? = nil

    public let containerURL: URL
    private let fileName = "slots.json"

    public init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Library/Application Support")
        self.containerURL = appSupport.appendingPathComponent("NeoWidget", isDirectory: true)
        loadOrCreateDefaults()
    }

    public var currentConfig: WidgetConfig? {
        get { slots[currentSlotId] }
        set { if let v = newValue { slots[currentSlotId] = v } }
    }

    public func loadOrCreateDefaults() {
        do {
            try FileManager.default.createDirectory(at: containerURL, withIntermediateDirectories: true)
            let fileURL = containerURL.appendingPathComponent(fileName)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                let data = try Data(contentsOf: fileURL)
                let decoded = try JSONDecoder().decode(SlotData.self, from: data)
                if decoded.slots.isEmpty {
                    slots = NeoPresets.defaultSlots()
                    save()
                } else {
                    // Ensure all 8 slots exist
                    var merged = NeoPresets.defaultSlots()
                    for (k, v) in decoded.slots { merged[k] = v }
                    slots = merged
                }
            } else {
                slots = NeoPresets.defaultSlots()
                save()
            }
        } catch {
            print("WidgetStore load error: \(error)")
            slots = NeoPresets.defaultSlots()
        }
    }

    public func save(reloadTimelines: Bool = true) {
        do {
            try FileManager.default.createDirectory(at: containerURL, withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(SlotData(slots: slots))
            let fileURL = containerURL.appendingPathComponent(fileName)
            try data.write(to: fileURL, options: .atomic)
            // Also write a per-slot file for easy inspection / sharing
            for (slot, config) in slots {
                let safe = slot.replacingOccurrences(of: " ", with: "_").lowercased()
                let slotURL = containerURL.appendingPathComponent("\(safe).json")
                if let slotData = try? JSONEncoder().encode(config) {
                    try? slotData.write(to: slotURL, options: .atomic)
                }
            }
            if reloadTimelines {
                WidgetCenter.shared.reloadAllTimelines()
            }
        } catch {
            print("WidgetStore save error: \(error)")
        }
    }

    public func bindingForSlot(_ slot: String) -> Binding<WidgetConfig> {
        Binding(
            get: { self.slots[slot] ?? NeoPresets.defaultSlots()[slot]! },
            set: { self.slots[slot] = $0 }
        )
    }

    public func applyPreset(_ config: WidgetConfig, to slot: String? = nil) {
        let target = slot ?? currentSlotId
        var copy = config
        // fresh IDs so editor selection doesn't collide
        copy.elements = copy.elements.map { var e = $0; e.id = UUID(); return e }
        slots[target] = copy
        selectedElementId = nil
        save()
    }

    // MARK: - Element operations

    public func addElement(_ element: WidgetElement) {
        guard var cfg = slots[currentSlotId] else { return }
        var e = element
        e.zIndex = (cfg.elements.map(\.zIndex).max() ?? 0) + 1
        cfg.elements.append(e)
        slots[currentSlotId] = cfg
        selectedElementId = e.id
        save()
    }

    public func updateElement(_ element: WidgetElement) {
        guard var cfg = slots[currentSlotId],
              let idx = cfg.elements.firstIndex(where: { $0.id == element.id }) else { return }
        cfg.elements[idx] = element
        slots[currentSlotId] = cfg
    }

    public func deleteElement(id: UUID) {
        guard var cfg = slots[currentSlotId] else { return }
        cfg.elements.removeAll { $0.id == id }
        slots[currentSlotId] = cfg
        if selectedElementId == id { selectedElementId = nil }
        save()
    }

    public func duplicateElement(id: UUID) {
        guard var cfg = slots[currentSlotId],
              let idx = cfg.elements.firstIndex(where: { $0.id == id }) else { return }
        var copy = cfg.elements[idx]
        copy.id = UUID()
        copy.x += 20
        copy.y += 20
        copy.zIndex = (cfg.elements.map(\.zIndex).max() ?? 0) + 1
        copy.locked = false
        cfg.elements.append(copy)
        slots[currentSlotId] = cfg
        selectedElementId = copy.id
        save()
    }

    public func moveElement(id: UUID, direction: Int) {
        guard var cfg = slots[currentSlotId] else { return }
        guard let idx = cfg.elements.firstIndex(where: { $0.id == id }) else { return }
        let newIdx = idx + direction
        guard newIdx >= 0, newIdx < cfg.elements.count else { return }
        cfg.elements.swapAt(idx, newIdx)
        // reassign zIndex by order
        for i in cfg.elements.indices { cfg.elements[i].zIndex = i }
        slots[currentSlotId] = cfg
        save()
    }

    public func toggleLock(id: UUID) {
        guard var cfg = slots[currentSlotId],
              let idx = cfg.elements.firstIndex(where: { $0.id == id }) else { return }
        cfg.elements[idx].locked.toggle()
        slots[currentSlotId] = cfg
        save()
    }

    // MARK: - Import / Export .neowidget

    #if canImport(AppKit)
    public func exportCurrentSlot() {
        guard let config = slots[currentSlotId] else { return }
        let panel = NSSavePanel()
        if #available(macOS 14.0, *) {
            panel.allowedContentTypes = [UTType(filenameExtension: "neowidget") ?? .json]
        } else {
            panel.allowedFileTypes = ["neowidget"]
        }
        panel.nameFieldStringValue = "\(currentSlotId.replacingOccurrences(of: " ", with: "_")).neowidget"
        panel.canCreateDirectories = true
        panel.title = "Export NeoWidget Slot"
        if panel.runModal() == .OK, let url = panel.url {
            do {
                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
                let data = try encoder.encode(config)
                try data.write(to: url, options: .atomic)
            } catch {
                print("Export error: \(error)")
            }
        }
    }

    public func importToCurrentSlot() {
        let panel = NSOpenPanel()
        if #available(macOS 14.0, *) {
            panel.allowedContentTypes = [UTType(filenameExtension: "neowidget") ?? .json, .json]
        } else {
            panel.allowedFileTypes = ["neowidget", "json"]
        }
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.title = "Import .neowidget"
        if panel.runModal() == .OK, let url = panel.url {
            importFromURL(url)
        }
    }

    public func importFromURL(_ url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let config = try JSONDecoder().decode(WidgetConfig.self, from: data)
            applyPreset(config, to: currentSlotId)
        } catch {
            print("Import error: \(error)")
        }
    }
    #endif
}
