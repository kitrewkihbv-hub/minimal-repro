import SwiftUI
import WidgetKit
import Foundation

public struct CodableColor: Codable, Equatable {
    public var red: Double
    public var green: Double
    public var blue: Double
    public var opacity: Double

    public init(_ color: Color, opacity: Double = 1.0) {
        // Best-effort extraction for common static colors; fallback to cyan.
        // For runtime ColorPicker values, we store via the explicit init below.
        self.red = 0
        self.green = 1
        self.blue = 1
        self.opacity = opacity
        // Map known preset colors
        switch color {
        case .cyan:   self = CodableColor(red: 0, green: 1, blue: 1, opacity: opacity)
        case .purple: self = CodableColor(red: 0.5, green: 0, blue: 0.5, opacity: opacity)
        case .blue:   self = CodableColor(red: 0, green: 0, blue: 1, opacity: opacity)
        case .green:  self = CodableColor(red: 0, green: 1, blue: 0, opacity: opacity)
        case .red:    self = CodableColor(red: 1, green: 0, blue: 0, opacity: opacity)
        case .white:  self = CodableColor(red: 1, green: 1, blue: 1, opacity: opacity)
        case .clear:  self = CodableColor(red: 0, green: 0, blue: 0, opacity: 0)
        default:      self = CodableColor(red: 0, green: 1, blue: 1, opacity: opacity)
        }
    }

    public init(red: Double, green: Double, blue: Double, opacity: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.opacity = opacity
    }

    public var color: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }

    public static let cyan = CodableColor(red: 0, green: 1, blue: 1)
    public static let purple = CodableColor(red: 0.5, green: 0, blue: 0.5)
    public static let blue = CodableColor(red: 0, green: 0, blue: 1)
    public static let green = CodableColor(red: 0, green: 1, blue: 0)
    public static let red = CodableColor(red: 1, green: 0, blue: 0)
    public static let white = CodableColor(red: 1, green: 1, blue: 1)
    public static let clear = CodableColor(red: 0, green: 0, blue: 0, opacity: 0)
}

public struct WidgetConfig: Codable {
    public var name: String
    public var type: WidgetType
    public var elements: [WidgetElement]

    public init(name: String, type: WidgetType, elements: [WidgetElement]) {
        self.name = name
        self.type = type
        self.elements = elements
    }
}

public enum WidgetType: String, Codable {
    case clock, media, weather, stats, image, dashboard
}

public struct WidgetElement: Codable, Identifiable {
    public var id = UUID()
    public var type: WidgetType
    public var content: String
    public var neonColor: CodableColor? = nil
    public var glassBlur: CGFloat = 0
    public var scaleX: CGFloat = 1
    public var scaleY: CGFloat = 1
    public var zIndex: Int = 0

    public init(id: UUID = UUID(), type: WidgetType, content: String, neonColor: CodableColor? = nil, glassBlur: CGFloat = 0, scaleX: CGFloat = 1, scaleY: CGFloat = 1, zIndex: Int = 0) {
        self.id = id
        self.type = type
        self.content = content
        self.neonColor = neonColor
        self.glassBlur = glassBlur
        self.scaleX = scaleX
        self.scaleY = scaleY
        self.zIndex = zIndex
    }
}

// Shared Data Store (App Group / Shared Container)
public class WidgetStore: ObservableObject {
    @Published public var currentSlotId: String = "Slot 1"
    @Published public var slots: [String: WidgetConfig] = [:]
    public let containerURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("NeoWidget")

    public init() {
        loadPresets()
    }

    public func loadPresets() {
        // 8 Built-in Presets
        slots["Slot 1"] = WidgetConfig(name: "Tall Neon Cyber Clock", type: .clock, elements: [WidgetElement(type: .clock, content: "$df(hh:mm)$", neonColor: .cyan, scaleX: 1, scaleY: 2)])
        slots["Slot 2"] = WidgetConfig(name: "Ultra-Long Vertical Digital Clock", type: .clock, elements: [WidgetElement(type: .clock, content: "$df(hh:mm)$", neonColor: .purple, scaleX: 0.5, scaleY: 3)])
        slots["Slot 3"] = WidgetConfig(name: "Glass Apple Music/Spotify Player", type: .media, elements: [WidgetElement(type: .media, content: "Track - Artist", glassBlur: 10)])
        slots["Slot 4"] = WidgetConfig(name: "Neon Weather Card", type: .weather, elements: [WidgetElement(type: .weather, content: "22°C", neonColor: .blue)])
        slots["Slot 5"] = WidgetConfig(name: "Retro System Stats", type: .stats, elements: [WidgetElement(type: .stats, content: "CPU: 12% | RAM: 4GB", neonColor: .green)])
        slots["Slot 6"] = WidgetConfig(name: "Aesthetic Photo Frame", type: .image, elements: [WidgetElement(type: .image, content: "photo.png", glassBlur: 0)])
        slots["Slot 7"] = WidgetConfig(name: "Minimal Analog Neon Clock", type: .clock, elements: [WidgetElement(type: .clock, content: "Analog", neonColor: .red, scaleX: 1, scaleY: 1)])
        slots["Slot 8"] = WidgetConfig(name: "All-in-One Cyber Dashboard", type: .dashboard, elements: [
            WidgetElement(type: .clock, content: "$df(hh:mm)$", neonColor: .cyan),
            WidgetElement(type: .weather, content: "22°C", neonColor: .blue),
            WidgetElement(type: .media, content: "Track", glassBlur: 5)
        ])
        save()
    }

    public func save() {
        // Save to ~/Library/Application Support/NeoWidget/
        do {
            try FileManager.default.createDirectory(at: containerURL, withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(slots)
            try data.write(to: containerURL.appendingPathComponent("data.json"))
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("Failed to save widget data: \(error)")
        }
    }

    public func exportCurrent() {
        // Export .neowidget logic
        print("Exporting .neowidget for \(currentSlotId)")
    }

    public func importCurrent() {
        // Import .neowidget logic
        print("Importing .neowidget")
    }
}

public struct ElementView: View {
    public var element: WidgetElement

    public init(element: WidgetElement) {
        self.element = element
    }

    public var body: some View {
        Group {
            if element.type == .clock {
                Text("$df(hh:mm)$")
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
            } else if element.type == .media {
                VStack {
                    Text("🎵 Track Title")
                    Text("Artist Name")
                    ProgressView(value: 0.5)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(15)
            } else if element.type == .weather {
                Text("☁️ 22°C")
                    .font(.title)
            } else if element.type == .stats {
                Text("CPU: 12% | RAM: 4GB")
                    .font(.system(.caption, design: .monospaced))
            } else if element.type == .image {
                Image(systemName: "photo")
                    .resizable()
                    .frame(width: 100, height: 100)
            } else {
                Text("Dashboard")
            }
        }
        .foregroundColor(element.neonColor?.color ?? .white)
    }
}
