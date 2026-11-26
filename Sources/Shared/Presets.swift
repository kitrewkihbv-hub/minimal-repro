import Foundation
import SwiftUI

public enum NeoPresets {
    public static let slotNames: [String] = [
        "Slot 1", "Slot 2", "Slot 3", "Slot 4",
        "Slot 5", "Slot 6", "Slot 7", "Slot 8"
    ]

    public static func defaultSlots() -> [String: WidgetConfig] {
        var slots: [String: WidgetConfig] = [:]
        slots["Slot 1"] = tallNeonCyberClock()
        slots["Slot 2"] = ultraLongStretchedVerticalClock()
        slots["Slot 3"] = frostedMusicPlayer()
        slots["Slot 4"] = neonWeatherForecastCard()
        slots["Slot 5"] = retroHackerSystemMonitor()
        slots["Slot 6"] = aestheticPhotoFrame()
        slots["Slot 7"] = minimalAnalogNeonClock()
        slots["Slot 8"] = allInOneCyberDashboard()
        return slots
    }

    public static func presetGallery() -> [(id: String, name: String, icon: String, config: WidgetConfig)] {
        [
            ("p1", "Tall Neon Cyber Clock", "clock.fill", tallNeonCyberClock()),
            ("p2", "Ultra-Long Stretched Vertical Clock", "rectangle.expand.vertical", ultraLongStretchedVerticalClock()),
            ("p3", "Frosted Apple Music/Spotify Player", "music.note.list", frostedMusicPlayer()),
            ("p4", "Neon Weather & Forecast Card", "cloud.sun.fill", neonWeatherForecastCard()),
            ("p5", "Retro Hacker System Monitor", "terminal.fill", retroHackerSystemMonitor()),
            ("p6", "Aesthetic Photo Frame", "photo.fill", aestheticPhotoFrame()),
            ("p7", "Minimal Analog Neon Clock", "timer", minimalAnalogNeonClock()),
            ("p8", "All-in-One Cyber Dashboard", "square.grid.2x2.fill", allInOneCyberDashboard()),
        ]
    }

    // 1. Tall Neon Cyber Clock
    static func tallNeonCyberClock() -> WidgetConfig {
        WidgetConfig(name: "Tall Neon Cyber Clock", type: .clock, elements: [
            WidgetElement(type: .shape, content: "", x: 160, y: 210, width: 280, height: 380,
                          fillColor: CodableColor(red: 0.02, green: 0.02, blue: 0.06, opacity: 0.75),
                          useGradient: true, gradientColor2: CodableColor(red: 0.05, green: 0.0, blue: 0.12, opacity: 0.8),
                          gradientDirection: .vertical,
                          neonEnabled: true, neonColor: .cyan, neonRadius: 18, neonIntensity: 0.7,
                          glassBlur: 0, cornerRadius: 28, backgroundOpacity: 0.7,
                          borderWidth: 1.5, borderColor: CodableColor(red: 0, green: 0.94, blue: 1, opacity: 0.5)),
            WidgetElement(type: .text, content: "CYBER TIME", x: 160, y: 60, width: 240, height: 30,
                          fontName: "Avenir Next", fontSize: 14, fontWeight: "bold",
                          textColor: CodableColor(red: 0, green: 0.94, blue: 1, opacity: 0.8),
                          fillColor: .clear, neonEnabled: true, neonColor: .cyan, neonRadius: 6, neonIntensity: 0.6,
                          cornerRadius: 0, backgroundOpacity: 0),
            WidgetElement(type: .clock, content: "$df(hh:mm)$", x: 160, y: 170, width: 260, height: 140,
                          scaleX: 1.0, scaleY: 1.6,
                          fontName: "Avenir Next Condensed", fontSize: 72, fontWeight: "heavy",
                          textColor: .white, fillColor: .clear,
                          neonEnabled: true, neonColor: .cyan, neonRadius: 20, neonIntensity: 1.0,
                          cornerRadius: 0, backgroundOpacity: 0),
            WidgetElement(type: .clock, content: "$df(ss)$", x: 160, y: 250, width: 120, height: 40,
                          fontName: "Menlo", fontSize: 28, fontWeight: "bold",
                          textColor: .magenta, fillColor: .clear,
                          neonEnabled: true, neonColor: .magenta, neonRadius: 10, neonIntensity: 0.9,
                          cornerRadius: 0, backgroundOpacity: 0),
            WidgetElement(type: .clock, content: "$df(EEE, MMM d)$", x: 160, y: 320, width: 240, height: 30,
                          fontName: "Avenir Next", fontSize: 16, fontWeight: "medium",
                          textColor: CodableColor(red: 0.8, green: 0.9, blue: 1.0, opacity: 0.9),
                          fillColor: .clear, neonEnabled: false, neonColor: .cyan, neonRadius: 0, neonIntensity: 0,
                          cornerRadius: 0, backgroundOpacity: 0),
        ], canvasWidth: 320, canvasHeight: 420)
    }

    // 2. Ultra-Long Stretched Vertical Clock
    static func ultraLongStretchedVerticalClock() -> WidgetConfig {
        WidgetConfig(name: "Ultra-Long Stretched Vertical Clock", type: .clock, elements: [
            WidgetElement(type: .shape, content: "", x: 100, y: 260, width: 180, height: 500,
                          fillColor: CodableColor(red: 0.01, green: 0.01, blue: 0.02, opacity: 0.85),
                          useGradient: true, gradientColor2: CodableColor(red: 0.08, green: 0.0, blue: 0.18, opacity: 0.9),
                          gradientDirection: .vertical,
                          neonEnabled: true, neonColor: .purple, neonRadius: 16, neonIntensity: 0.6,
                          cornerRadius: 32, backgroundOpacity: 0.85,
                          borderWidth: 1, borderColor: CodableColor(red: 0.62, green: 0.2, blue: 1.0, opacity: 0.4)),
            WidgetElement(type: .clock, content: "$df(HH)$", x: 100, y: 130, width: 160, height: 140,
                          scaleX: 0.85, scaleY: 2.2,
                          fontName: "Futura", fontSize: 80, fontWeight: "black",
                          textColor: .white, fillColor: .clear,
                          neonEnabled: true, neonColor: .purple, neonRadius: 24, neonIntensity: 1.0,
                          cornerRadius: 0, backgroundOpacity: 0),
            WidgetElement(type: .shape, content: "", x: 100, y: 250, width: 60, height: 4,
                          fillColor: .magenta, neonEnabled: true, neonColor: .magenta, neonRadius: 8, neonIntensity: 1.0,
                          cornerRadius: 2, backgroundOpacity: 1),
            WidgetElement(type: .clock, content: "$df(mm)$", x: 100, y: 360, width: 160, height: 140,
                          scaleX: 0.85, scaleY: 2.2,
                          fontName: "Futura", fontSize: 80, fontWeight: "black",
                          textColor: .white, fillColor: .clear,
                          neonEnabled: true, neonColor: .magenta, neonRadius: 24, neonIntensity: 1.0,
                          cornerRadius: 0, backgroundOpacity: 0),
        ], canvasWidth: 200, canvasHeight: 520)
    }

    // 3. Frosted Apple Music/Spotify Player
    static func frostedMusicPlayer() -> WidgetConfig {
        WidgetConfig(name: "Frosted Apple Music/Spotify Player", type: .media, elements: [
            WidgetElement(type: .shape, content: "", x: 180, y: 90, width: 340, height: 160,
                          fillColor: CodableColor(red: 1, green: 1, blue: 1, opacity: 0.08),
                          useGradient: true, gradientColor2: CodableColor(red: 0.4, green: 0.2, blue: 0.8, opacity: 0.18),
                          gradientDirection: .diagonalDown,
                          neonEnabled: false, neonColor: .white, neonRadius: 0, neonIntensity: 0,
                          glassBlur: 18, cornerRadius: 24, backgroundOpacity: 0.2,
                          borderWidth: 1, borderColor: CodableColor(red: 1, green: 1, blue: 1, opacity: 0.2)),
            WidgetElement(type: .shape, content: "", x: 70, y: 90, width: 90, height: 90,
                          fillColor: CodableColor(red: 0.3, green: 0.1, blue: 0.5, opacity: 0.7),
                          useGradient: true, gradientColor2: CodableColor(red: 1, green: 0.2, blue: 0.5, opacity: 0.7),
                          neonEnabled: true, neonColor: .magenta, neonRadius: 10, neonIntensity: 0.5,
                          cornerRadius: 18, backgroundOpacity: 0.8),
            WidgetElement(type: .text, content: "♫", x: 70, y: 90, width: 60, height: 60,
                          fontName: "SF Pro Display", fontSize: 34, fontWeight: "bold",
                          textColor: .white, fillColor: .clear, neonEnabled: false, neonColor: .clear, neonRadius: 0, neonIntensity: 0,
                          cornerRadius: 0, backgroundOpacity: 0),
            WidgetElement(type: .media, content: "$mi(title)$", x: 230, y: 60, width: 210, height: 28,
                          fontName: "SF Pro Display", fontSize: 18, fontWeight: "semibold",
                          textColor: .white, fillColor: .clear,
                          neonEnabled: false, neonColor: .clear, neonRadius: 0, neonIntensity: 0,
                          cornerRadius: 0, backgroundOpacity: 0),
            WidgetElement(type: .media, content: "$mi(artist)$", x: 230, y: 86, width: 210, height: 22,
                          fontName: "SF Pro Text", fontSize: 13, fontWeight: "regular",
                          textColor: CodableColor(red: 1, green: 1, blue: 1, opacity: 0.7),
                          fillColor: .clear, neonEnabled: false, neonColor: .clear, neonRadius: 0, neonIntensity: 0,
                          cornerRadius: 0, backgroundOpacity: 0),
            WidgetElement(type: .text, content: "◀◀   ▶/❚❚   ▶▶", x: 230, y: 125, width: 210, height: 30,
                          fontName: "SF Pro Display", fontSize: 18, fontWeight: "medium",
                          textColor: .white, fillColor: .clear,
                          neonEnabled: true, neonColor: .white, neonRadius: 4, neonIntensity: 0.3,
                          cornerRadius: 0, backgroundOpacity: 0),
        ], canvasWidth: 360, canvasHeight: 180)
    }

    // 4. Neon Weather & Forecast Card
    static func neonWeatherForecastCard() -> WidgetConfig {
        WidgetConfig(name: "Neon Weather & Forecast Card", type: .weather, elements: [
            WidgetElement(type: .shape, content: "", x: 160, y: 160, width: 300, height: 300,
                          fillColor: CodableColor(red: 0.02, green: 0.05, blue: 0.12, opacity: 0.85),
                          useGradient: true, gradientColor2: CodableColor(red: 0.0, green: 0.12, blue: 0.25, opacity: 0.9),
                          gradientDirection: .vertical,
                          neonEnabled: true, neonColor: .blue, neonRadius: 14, neonIntensity: 0.6,
                          cornerRadius: 28, backgroundOpacity: 0.85,
                          borderWidth: 1, borderColor: CodableColor(red: 0.2, green: 0.45, blue: 1.0, opacity: 0.4)),
            WidgetElement(type: .text, content: "SEATTLE", x: 160, y: 45, width: 200, height: 24,
                          fontName: "Avenir Next", fontSize: 13, fontWeight: "bold",
                          textColor: CodableColor(red: 0.5, green: 0.7, blue: 1.0, opacity: 0.9),
                          fillColor: .clear, neonEnabled: false, neonColor: .clear, neonRadius: 0, neonIntensity: 0,
                          cornerRadius: 0, backgroundOpacity: 0),
            WidgetElement(type: .weather, content: "$wi(temp)$", x: 160, y: 120, width: 240, height: 90,
                          fontName: "Avenir Next", fontSize: 64, fontWeight: "heavy",
                          textColor: .white, fillColor: .clear,
                          neonEnabled: true, neonColor: .cyan, neonRadius: 18, neonIntensity: 0.9,
                          cornerRadius: 0, backgroundOpacity: 0),
            WidgetElement(type: .weather, content: "$wi(cond)$", x: 160, y: 180, width: 240, height: 30,
                          fontName: "Avenir Next", fontSize: 20, fontWeight: "medium",
                          textColor: CodableColor(red: 0.7, green: 0.85, blue: 1.0, opacity: 1),
                          fillColor: .clear, neonEnabled: false, neonColor: .clear, neonRadius: 0, neonIntensity: 0,
                          cornerRadius: 0, backgroundOpacity: 0),
            WidgetElement(type: .text, content: "☀  ☁  🌧  ⛈  ❄", x: 160, y: 250, width: 260, height: 30,
                          fontName: "SF Pro Display", fontSize: 20, fontWeight: "regular",
                          textColor: CodableColor(red: 1, green: 1, blue: 1, opacity: 0.6),
                          fillColor: .clear, neonEnabled: false, neonColor: .clear, neonRadius: 0, neonIntensity: 0,
                          cornerRadius: 0, backgroundOpacity: 0),
        ], canvasWidth: 320, canvasHeight: 320)
    }

    // 5. Retro Hacker System Monitor
    static func retroHackerSystemMonitor() -> WidgetConfig {
        WidgetConfig(name: "Retro Hacker System Monitor", type: .stats, elements: [
            WidgetElement(type: .shape, content: "", x: 180, y: 130, width: 340, height: 240,
                          fillColor: CodableColor(red: 0.0, green: 0.04, blue: 0.0, opacity: 0.92),
                          useGradient: false, gradientColor2: .green, gradientDirection: .vertical,
                          neonEnabled: true, neonColor: .green, neonRadius: 10, neonIntensity: 0.5,
                          cornerRadius: 12, backgroundOpacity: 0.92,
                          borderWidth: 1, borderColor: CodableColor(red: 0.2, green: 1.0, blue: 0.6, opacity: 0.35)),
            WidgetElement(type: .text, content: "> SYSTEM_MONITOR", x: 180, y: 35, width: 300, height: 24,
                          fontName: "Menlo", fontSize: 14, fontWeight: "bold",
                          textColor: .green, fillColor: .clear,
                          neonEnabled: true, neonColor: .green, neonRadius: 6, neonIntensity: 0.8,
                          cornerRadius: 0, backgroundOpacity: 0),
            WidgetElement(type: .stats, content: "CPU", x: 180, y: 85, width: 300, height: 44,
                          fontName: "Menlo", fontSize: 13, fontWeight: "regular",
                          textColor: .green, fillColor: .clear,
                          neonEnabled: true, neonColor: .green, neonRadius: 4, neonIntensity: 0.5,
                          cornerRadius: 0, backgroundOpacity: 0),
            WidgetElement(type: .stats, content: "RAM: $rm(cused)$", x: 180, y: 140, width: 300, height: 44,
                          fontName: "Menlo", fontSize: 13, fontWeight: "regular",
                          textColor: .green, fillColor: .clear,
                          neonEnabled: true, neonColor: .green, neonRadius: 4, neonIntensity: 0.5,
                          cornerRadius: 0, backgroundOpacity: 0),
            WidgetElement(type: .stats, content: "BAT: $bi(level)$", x: 180, y: 195, width: 300, height: 44,
                          fontName: "Menlo", fontSize: 13, fontWeight: "regular",
                          textColor: .green, fillColor: .clear,
                          neonEnabled: true, neonColor: .green, neonRadius: 4, neonIntensity: 0.5,
                          cornerRadius: 0, backgroundOpacity: 0),
        ], canvasWidth: 360, canvasHeight: 260)
    }

    // 6. Aesthetic Photo Frame
    static func aestheticPhotoFrame() -> WidgetConfig {
        WidgetConfig(name: "Aesthetic Photo Frame", type: .image, elements: [
            WidgetElement(type: .shape, content: "", x: 170, y: 170, width: 320, height: 320,
                          fillColor: CodableColor(red: 0.98, green: 0.96, blue: 0.92, opacity: 0.95),
                          useGradient: false, gradientColor2: .white, gradientDirection: .vertical,
                          neonEnabled: false, neonColor: .clear, neonRadius: 0, neonIntensity: 0,
                          glassBlur: 0, cornerRadius: 4, backgroundOpacity: 0.95,
                          borderWidth: 0, borderColor: .clear),
            WidgetElement(type: .image, content: "", x: 170, y: 150, width: 280, height: 240,
                          fillColor: CodableColor(red: 0.85, green: 0.82, blue: 0.78, opacity: 1),
                          neonEnabled: false, neonColor: .clear, neonRadius: 0, neonIntensity: 0,
                          cornerRadius: 2, backgroundOpacity: 1),
            WidgetElement(type: .text, content: "your memories here", x: 170, y: 295, width: 260, height: 24,
                          fontName: "Snell Roundhand", fontSize: 18, fontWeight: "regular",
                          textColor: CodableColor(red: 0.3, green: 0.25, blue: 0.2, opacity: 0.8),
                          fillColor: .clear, neonEnabled: false, neonColor: .clear, neonRadius: 0, neonIntensity: 0,
                          cornerRadius: 0, backgroundOpacity: 0),
        ], canvasWidth: 340, canvasHeight: 340)
    }

    // 7. Minimal Analog Neon Clock
    static func minimalAnalogNeonClock() -> WidgetConfig {
        WidgetConfig(name: "Minimal Analog Neon Clock", type: .analogClock, elements: [
            WidgetElement(type: .shape, content: "", x: 160, y: 160, width: 300, height: 300,
                          fillColor: CodableColor(red: 0.03, green: 0.03, blue: 0.06, opacity: 0.85),
                          useGradient: true, gradientColor2: CodableColor(red: 0.08, green: 0.02, blue: 0.02, opacity: 0.9),
                          gradientDirection: .diagonalDown,
                          neonEnabled: true, neonColor: .red, neonRadius: 14, neonIntensity: 0.5,
                          cornerRadius: 150, backgroundOpacity: 0.85,
                          borderWidth: 1.5, borderColor: CodableColor(red: 1.0, green: 0.22, blue: 0.35, opacity: 0.4)),
            WidgetElement(type: .analogClock, content: "", x: 160, y: 160, width: 260, height: 260,
                          fontName: "SF Pro Display", fontSize: 18, fontWeight: "medium",
                          textColor: .white, fillColor: .clear,
                          neonEnabled: true, neonColor: .red, neonRadius: 10, neonIntensity: 0.9,
                          cornerRadius: 0, backgroundOpacity: 0),
            WidgetElement(type: .text, content: "NEO", x: 160, y: 220, width: 80, height: 20,
                          fontName: "Avenir Next", fontSize: 11, fontWeight: "bold",
                          textColor: CodableColor(red: 1, green: 0.22, blue: 0.35, opacity: 0.7),
                          fillColor: .clear, neonEnabled: true, neonColor: .red, neonRadius: 4, neonIntensity: 0.6,
                          cornerRadius: 0, backgroundOpacity: 0),
        ], canvasWidth: 320, canvasHeight: 320)
    }

    // 8. All-in-One Cyber Dashboard
    static func allInOneCyberDashboard() -> WidgetConfig {
        WidgetConfig(name: "All-in-One Cyber Dashboard", type: .dashboard, elements: [
            WidgetElement(type: .shape, content: "", x: 190, y: 190, width: 360, height: 360,
                          fillColor: CodableColor(red: 0.02, green: 0.02, blue: 0.06, opacity: 0.82),
                          useGradient: true, gradientColor2: CodableColor(red: 0.06, green: 0.0, blue: 0.14, opacity: 0.85),
                          gradientDirection: .diagonalDown,
                          neonEnabled: true, neonColor: .cyan, neonRadius: 12, neonIntensity: 0.4,
                          cornerRadius: 26, backgroundOpacity: 0.82,
                          borderWidth: 1, borderColor: CodableColor(red: 0, green: 0.94, blue: 1, opacity: 0.25)),
            WidgetElement(type: .clock, content: "$df(hh:mm)$", x: 120, y: 75, width: 200, height: 70,
                          fontName: "Avenir Next Condensed", fontSize: 52, fontWeight: "heavy",
                          textColor: .white, fillColor: .clear,
                          neonEnabled: true, neonColor: .cyan, neonRadius: 16, neonIntensity: 1.0,
                          cornerRadius: 0, backgroundOpacity: 0),
            WidgetElement(type: .clock, content: "$df(EEE, MMM d)$", x: 120, y: 120, width: 200, height: 24,
                          fontName: "Avenir Next", fontSize: 13, fontWeight: "medium",
                          textColor: CodableColor(red: 0.7, green: 0.85, blue: 1.0, opacity: 0.9),
                          fillColor: .clear, neonEnabled: false, neonColor: .clear, neonRadius: 0, neonIntensity: 0,
                          cornerRadius: 0, backgroundOpacity: 0),
            WidgetElement(type: .weather, content: "$wi(temp)$  $wi(cond)$", x: 290, y: 80, width: 140, height: 50,
                          fontName: "Avenir Next", fontSize: 18, fontWeight: "semibold",
                          textColor: .white, fillColor: .clear,
                          neonEnabled: true, neonColor: .blue, neonRadius: 8, neonIntensity: 0.6,
                          cornerRadius: 0, backgroundOpacity: 0),
            WidgetElement(type: .stats, content: "RAM $rm(cused)$ | BAT $bi(level)$", x: 190, y: 175, width: 320, height: 28,
                          fontName: "Menlo", fontSize: 12, fontWeight: "regular",
                          textColor: .green, fillColor: .clear,
                          neonEnabled: true, neonColor: .green, neonRadius: 5, neonIntensity: 0.5,
                          cornerRadius: 0, backgroundOpacity: 0),
            WidgetElement(type: .media, content: "$mi(title)$ — $mi(artist)$", x: 190, y: 240, width: 320, height: 24,
                          fontName: "SF Pro Display", fontSize: 14, fontWeight: "medium",
                          textColor: .white, fillColor: .clear,
                          neonEnabled: true, neonColor: .magenta, neonRadius: 6, neonIntensity: 0.5,
                          cornerRadius: 0, backgroundOpacity: 0),
            WidgetElement(type: .shape, content: "", x: 190, y: 320, width: 320, height: 60,
                          fillColor: CodableColor(red: 1, green: 1, blue: 1, opacity: 0.05),
                          neonEnabled: true, neonColor: .purple, neonRadius: 6, neonIntensity: 0.3,
                          cornerRadius: 14, backgroundOpacity: 0.08,
                          borderWidth: 1, borderColor: CodableColor(red: 0.62, green: 0.2, blue: 1.0, opacity: 0.25)),
            WidgetElement(type: .text, content: "NEOWIDGET // LIVE", x: 190, y: 320, width: 280, height: 24,
                          fontName: "Menlo", fontSize: 11, fontWeight: "bold",
                          textColor: CodableColor(red: 0.62, green: 0.2, blue: 1.0, opacity: 0.9),
                          fillColor: .clear, neonEnabled: false, neonColor: .clear, neonRadius: 0, neonIntensity: 0,
                          cornerRadius: 0, backgroundOpacity: 0),
        ], canvasWidth: 380, canvasHeight: 380)
    }
}
