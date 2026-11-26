import SwiftUI
import WidgetKit
import Foundation

// MARK: - CodableColor

public struct CodableColor: Codable, Equatable, Hashable {
    public var red: Double
    public var green: Double
    public var blue: Double
    public var opacity: Double

    public init(red: Double, green: Double, blue: Double, opacity: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.opacity = opacity
    }

    public init(_ color: Color, opacity: Double = 1.0) {
        #if canImport(AppKit)
        let ns = NSColor(color).usingColorSpace(.sRGB) ?? NSColor(SwiftUI.Color.cyan)
        self.red = Double(ns.redComponent)
        self.green = Double(ns.greenComponent)
        self.blue = Double(ns.blueComponent)
        self.opacity = Double(ns.alphaComponent) * opacity
        #else
        self.red = 0; self.green = 1; self.blue = 1; self.opacity = opacity
        #endif
    }

    public var color: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }

    public static let cyan    = CodableColor(red: 0.0, green: 0.94, blue: 1.0)
    public static let magenta = CodableColor(red: 1.0, green: 0.0, blue: 0.78)
    public static let purple  = CodableColor(red: 0.62, green: 0.2, blue: 1.0)
    public static let blue    = CodableColor(red: 0.2, green: 0.45, blue: 1.0)
    public static let green   = CodableColor(red: 0.2, green: 1.0, blue: 0.6)
    public static let red     = CodableColor(red: 1.0, green: 0.22, blue: 0.35)
    public static let orange  = CodableColor(red: 1.0, green: 0.55, blue: 0.1)
    public static let yellow  = CodableColor(red: 1.0, green: 0.92, blue: 0.2)
    public static let white   = CodableColor(red: 1.0, green: 1.0, blue: 1.0)
    public static let black   = CodableColor(red: 0.0, green: 0.0, blue: 0.0)
    public static let clear   = CodableColor(red: 0.0, green: 0.0, blue: 0.0, opacity: 0.0)
}

// MARK: - Enums

public enum WidgetType: String, Codable, CaseIterable, Identifiable {
    case clock
    case analogClock
    case media
    case weather
    case stats
    case text
    case shape
    case image
    case dashboard

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .clock: return "Tall Stretchable Clock"
        case .analogClock: return "Analog Clock"
        case .media: return "Live Music Player"
        case .weather: return "Live Weather Card"
        case .stats: return "System Stats"
        case .text: return "Custom Text"
        case .shape: return "Neon Shape/Box"
        case .image: return "Custom Image/GIF"
        case .dashboard: return "Dashboard"
        }
    }

    public var icon: String {
        switch self {
        case .clock: return "clock.fill"
        case .analogClock: return "timer"
        case .media: return "music.note.list"
        case .weather: return "cloud.sun.fill"
        case .stats: return "chart.bar.fill"
        case .text: return "textformat"
        case .shape: return "square.on.circle"
        case .image: return "photo"
        case .dashboard: return "square.grid.2x2"
        }
    }
}

public enum GradientDirection: String, Codable, CaseIterable, Identifiable {
    case vertical, horizontal, diagonalDown, diagonalUp
    public var id: String { rawValue }

    public var start: UnitPoint {
        switch self {
        case .vertical: return .top
        case .horizontal: return .leading
        case .diagonalDown: return .topLeading
        case .diagonalUp: return .bottomLeading
        }
    }
    public var end: UnitPoint {
        switch self {
        case .vertical: return .bottom
        case .horizontal: return .trailing
        case .diagonalDown: return .bottomTrailing
        case .diagonalUp: return .topTrailing
        }
    }
}

// MARK: - WidgetElement

public struct WidgetElement: Codable, Identifiable, Equatable {
    public var id: UUID
    public var type: WidgetType
    public var content: String
    public var x: CGFloat
    public var y: CGFloat
    public var width: CGFloat
    public var height: CGFloat
    public var scaleX: CGFloat
    public var scaleY: CGFloat
    public var rotation: Double
    public var zIndex: Int
    public var locked: Bool
    public var visible: Bool

    // Text / font
    public var fontName: String
    public var fontSize: CGFloat
    public var fontWeight: String
    public var textColor: CodableColor

    // Fill / gradient
    public var fillColor: CodableColor
    public var useGradient: Bool
    public var gradientColor2: CodableColor
    public var gradientDirection: GradientDirection

    // Neon / glow
    public var neonEnabled: Bool
    public var neonColor: CodableColor
    public var neonRadius: CGFloat
    public var neonIntensity: Double

    // Glass / background
    public var glassBlur: CGFloat
    public var cornerRadius: CGFloat
    public var backgroundOpacity: Double
    public var borderWidth: CGFloat
    public var borderColor: CodableColor

    // Image
    public var imagePath: String?

    public init(
        id: UUID = UUID(),
        type: WidgetType,
        content: String = "",
        x: CGFloat = 160,
        y: CGFloat = 120,
        width: CGFloat = 180,
        height: CGFloat = 80,
        scaleX: CGFloat = 1,
        scaleY: CGFloat = 1,
        rotation: Double = 0,
        zIndex: Int = 0,
        locked: Bool = false,
        visible: Bool = true,
        fontName: String = "SF Pro Display",
        fontSize: CGFloat = 36,
        fontWeight: String = "bold",
        textColor: CodableColor = .white,
        fillColor: CodableColor = CodableColor(red: 0.08, green: 0.08, blue: 0.12, opacity: 0.6),
        useGradient: Bool = false,
        gradientColor2: CodableColor = .purple,
        gradientDirection: GradientDirection = .diagonalDown,
        neonEnabled: Bool = true,
        neonColor: CodableColor = .cyan,
        neonRadius: CGFloat = 12,
        neonIntensity: Double = 0.8,
        glassBlur: CGFloat = 0,
        cornerRadius: CGFloat = 16,
        backgroundOpacity: Double = 0.35,
        borderWidth: CGFloat = 0,
        borderColor: CodableColor = .clear,
        imagePath: String? = nil
    ) {
        self.id = id
        self.type = type
        self.content = content
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.scaleX = scaleX
        self.scaleY = scaleY
        self.rotation = rotation
        self.zIndex = zIndex
        self.locked = locked
        self.visible = visible
        self.fontName = fontName
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.textColor = textColor
        self.fillColor = fillColor
        self.useGradient = useGradient
        self.gradientColor2 = gradientColor2
        self.gradientDirection = gradientDirection
        self.neonEnabled = neonEnabled
        self.neonColor = neonColor
        self.neonRadius = neonRadius
        self.neonIntensity = neonIntensity
        self.glassBlur = glassBlur
        self.cornerRadius = cornerRadius
        self.backgroundOpacity = backgroundOpacity
        self.borderWidth = borderWidth
        self.borderColor = borderColor
        self.imagePath = imagePath
    }

    public var swiftUIFontWeight: Font.Weight {
        switch fontWeight.lowercased() {
        case "ultralight": return .ultraLight
        case "thin": return .thin
        case "light": return .light
        case "regular": return .regular
        case "medium": return .medium
        case "semibold": return .semibold
        case "bold": return .bold
        case "heavy": return .heavy
        case "black": return .black
        default: return .bold
        }
    }
}

// MARK: - WidgetConfig

public struct WidgetConfig: Codable, Equatable {
    public var name: String
    public var type: WidgetType
    public var elements: [WidgetElement]
    public var canvasWidth: CGFloat
    public var canvasHeight: CGFloat

    public init(name: String, type: WidgetType, elements: [WidgetElement], canvasWidth: CGFloat = 360, canvasHeight: CGFloat = 360) {
        self.name = name
        self.type = type
        self.elements = elements
        self.canvasWidth = canvasWidth
        self.canvasHeight = canvasHeight
    }
}

// MARK: - Slot container

public struct SlotData: Codable {
    public var slots: [String: WidgetConfig]
    public init(slots: [String: WidgetConfig] = [:]) { self.slots = slots }
}
