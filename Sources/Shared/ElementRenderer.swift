import SwiftUI
#if canImport(AppKit)
import AppKit
#endif
#if os(macOS)
import Darwin
#endif

public struct ElementRenderer: View {
    public let element: WidgetElement
    public let date: Date
    public let provider: LiveDataProvider
    public var isPreview: Bool

    public init(element: WidgetElement, date: Date = Date(), provider: LiveDataProvider = .shared, isPreview: Bool = false) {
        self.element = element
        self.date = date
        self.provider = provider
        self.isPreview = isPreview
    }

    public var body: some View {
        if !element.visible { EmptyView() }
        else {
            content
                .frame(width: element.width, height: element.height)
                .background(backgroundView)
                .clipShape(RoundedRectangle(cornerRadius: element.cornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: element.cornerRadius, style: .continuous)
                        .stroke(element.borderColor.color, lineWidth: element.borderWidth)
                )
                .shadow(color: element.neonEnabled ? element.neonColor.color.opacity(element.neonIntensity) : .clear,
                        radius: element.neonEnabled ? element.neonRadius : 0)
                .shadow(color: element.neonEnabled ? element.neonColor.color.opacity(element.neonIntensity * 0.5) : .clear,
                        radius: element.neonEnabled ? element.neonRadius * 2.2 : 0)
                .scaleEffect(x: element.scaleX, y: element.scaleY)
                .rotationEffect(.degrees(element.rotation))
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        if element.type == .shape || element.type == .image || element.glassBlur > 0 || element.backgroundOpacity > 0.01 {
            let base = element.useGradient
                ? AnyShapeStyle(LinearGradient(colors: [element.fillColor.color.opacity(element.backgroundOpacity),
                                                         element.gradientColor2.color.opacity(element.backgroundOpacity)],
                                               startPoint: element.gradientDirection.start,
                                               endPoint: element.gradientDirection.end))
                : AnyShapeStyle(element.fillColor.color.opacity(element.backgroundOpacity))
            RoundedRectangle(cornerRadius: element.cornerRadius, style: .continuous)
                .fill(base)
        } else {
            Color.clear
        }
    }

    @ViewBuilder
    private var content: some View {
        switch element.type {
        case .clock:
            clockView()
        case .analogClock:
            AnalogClockView(element: element, date: date)
        case .media:
            mediaView
        case .weather:
            weatherView
        case .stats:
            statsView
        case .text:
            textView(element.content)
        case .shape:
            shapeView
        case .image:
            imageView
        case .dashboard:
            textView(FormulaEngine.evaluate(element.content, provider: provider, date: date))
        }
    }

    private func resolved(_ s: String) -> String {
        FormulaEngine.evaluate(s, provider: provider, date: date)
    }

    @ViewBuilder
    private func clockView() -> some View {
        let txt = resolved(element.content.isEmpty ? "$df(hh:mm)$" : element.content)
        Text(txt)
            .font(customFont(name: element.fontName, size: element.fontSize, weight: element.swiftUIFontWeight))
            .foregroundStyle(textFillStyle)
            .lineLimit(1)
            .minimumScaleFactor(0.2)
            .padding(4)
    }

    @ViewBuilder
    private func textView(_ s: String) -> some View {
        Text(resolved(s))
            .font(customFont(name: element.fontName, size: element.fontSize, weight: element.swiftUIFontWeight))
            .foregroundStyle(textFillStyle)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.3)
            .padding(6)
    }

    private var textFillStyle: AnyShapeStyle {
        if element.useGradient {
            return AnyShapeStyle(LinearGradient(colors: [element.textColor.color, element.gradientColor2.color],
                                                startPoint: element.gradientDirection.start,
                                                endPoint: element.gradientDirection.end))
        }
        return AnyShapeStyle(element.textColor.color)
    }

    @ViewBuilder
    private var mediaView: some View {
        VStack(alignment: .leading, spacing: 4) {
            let title = resolved(element.content.contains("$mi(") ? element.content : "$mi(title)$")
            let showArtist = !element.content.contains("$mi(artist)$") && !element.content.contains("$mi(title)$")
            Text(resolved(element.content.isEmpty ? "$mi(title)$" : element.content))
                .font(customFont(name: element.fontName, size: element.fontSize, weight: .semibold))
                .foregroundStyle(element.textColor.color)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            if showArtist {
                Text(resolved("$mi(artist)$"))
                    .font(customFont(name: element.fontName, size: max(10, element.fontSize * 0.65), weight: .regular))
                    .foregroundStyle(element.textColor.color.opacity(0.75))
                    .lineLimit(1)
            }
            HStack(spacing: 18) {
                Image(systemName: "backward.fill")
                Image(systemName: "playpause.fill")
                Image(systemName: "forward.fill")
            }
            .font(.system(size: max(10, element.fontSize * 0.55)))
            .foregroundStyle(element.textColor.color.opacity(0.9))
            .padding(.top, 2)
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var weatherView: some View {
        let txt = resolved(element.content.isEmpty ? "$wi(temp)$" : element.content)
        VStack(spacing: 2) {
            Text(txt)
                .font(customFont(name: element.fontName, size: element.fontSize, weight: element.swiftUIFontWeight))
                .foregroundStyle(textFillStyle)
                .lineLimit(1)
                .minimumScaleFactor(0.3)
            if !element.content.contains("$wi(cond)$") && element.content.isEmpty {
                Text(resolved("$wi(cond)$"))
                    .font(customFont(name: element.fontName, size: max(10, element.fontSize * 0.35), weight: .medium))
                    .foregroundStyle(element.textColor.color.opacity(0.8))
            }
        }
        .padding(6)
    }

    @ViewBuilder
    private var statsView: some View {
        VStack(alignment: .leading, spacing: 6) {
            let c = resolved(element.content)
            if c.contains("CPU") || element.content == "CPU" {
                statBar(label: "CPU", value: cpuValue(), color: element.neonColor.color)
            }
            if c.contains("RAM") || c.contains("$rm") {
                statBar(label: "RAM", value: Double(provider.ramUsedPercent) / 100.0, color: element.neonColor.color, valueText: "\(provider.ramUsedPercent)%")
            }
            if c.contains("BAT") || c.contains("$bi") {
                statBar(label: "BAT", value: Double(provider.batteryLevel) / 100.0, color: element.neonColor.color, valueText: "\(provider.batteryLevel)%")
            }
            if !c.contains("CPU") && !c.contains("RAM") && !c.contains("$rm") && !c.contains("BAT") && !c.contains("$bi") {
                Text(c)
                    .font(customFont(name: element.fontName, size: element.fontSize, weight: element.swiftUIFontWeight))
                    .foregroundStyle(element.textColor.color)
                    .minimumScaleFactor(0.4)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private func cpuValue() -> Double {
        // Best-effort: no direct CPU% without host_processor_info; show RAM-adjacent proxy is misleading.
        // Use a simple load average proxy.
        var load: Double = 0
        var loads: [Double] = [0, 0, 0]
        if getloadavg(&loads, 3) == 3 {
            let cores = Double(ProcessInfo.processInfo.processorCount)
            load = min(1.0, max(0.0, loads[0] / max(1, cores)))
        }
        return load
    }

    @ViewBuilder
    private func statBar(label: String, value: Double, color: Color, valueText: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(label)
                    .font(customFont(name: element.fontName, size: max(9, element.fontSize * 0.7), weight: .bold))
                Spacer()
                Text(valueText ?? "\(Int(value * 100))%")
                    .font(customFont(name: element.fontName, size: max(9, element.fontSize * 0.7), weight: .regular))
            }
            .foregroundStyle(element.textColor.color)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3).fill(element.textColor.color.opacity(0.15))
                    RoundedRectangle(cornerRadius: 3).fill(color)
                        .frame(width: max(0, geo.size.width * min(1, max(0, value))))
                        .shadow(color: color.opacity(0.8), radius: 4)
                }
            }
            .frame(height: 8)
        }
    }

    @ViewBuilder
    private var shapeView: some View {
        // Shape is mostly background; optional content label
        if !element.content.isEmpty {
            Text(resolved(element.content))
                .font(customFont(name: element.fontName, size: element.fontSize, weight: element.swiftUIFontWeight))
                .foregroundStyle(textFillStyle)
        } else {
            Color.clear
        }
    }

    @ViewBuilder
    private var imageView: some View {
        #if canImport(AppKit)
        if let path = element.imagePath, !path.isEmpty {
            let url = URL(fileURLWithPath: (path as NSString).expandingTildeInPath)
            if let nsImg = NSImage(contentsOf: url) {
                Image(nsImage: nsImg)
                    .resizable()
                    .scaledToFill()
                    .frame(width: element.width, height: element.height)
                    .clipped()
            } else {
                imagePlaceholder
            }
        } else {
            imagePlaceholder
        }
        #else
        imagePlaceholder
        #endif
    }

    private var imagePlaceholder: some View {
        ZStack {
            Color.white.opacity(0.05)
            VStack(spacing: 6) {
                Image(systemName: "photo")
                    .font(.system(size: 28))
                    .foregroundStyle(.white.opacity(0.5))
                Text("Image / GIF")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
    }

    private func customFont(name: String, size: CGFloat, weight: Font.Weight) -> Font {
        if name == "SF Pro Display" || name == "SF Pro Text" || name == "System" {
            return .system(size: size, weight: weight, design: .default)
        }
        if name.lowercased().contains("mono") || name == "Menlo" || name == "Courier" {
            if name == "Menlo" || name == "Courier" { return Font.custom(name, size: size) }
            return .system(size: size, weight: weight, design: .monospaced)
        }
        return Font.custom(name, size: size)
    }
}

// MARK: - Analog Clock

public struct AnalogClockView: View {
    let element: WidgetElement
    let date: Date

    public init(element: WidgetElement, date: Date) {
        self.element = element
        self.date = date
    }

    public var body: some View {
        let cal = Calendar.current
        let hour = Double(cal.component(.hour, from: date) % 12)
        let minute = Double(cal.component(.minute, from: date))
        let second = Double(cal.component(.second, from: date))
        let hourAngle = Angle.degrees((hour + minute / 60.0) * 30.0)
        let minuteAngle = Angle.degrees((minute + second / 60.0) * 6.0)
        let secondAngle = Angle.degrees(second * 6.0)

        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let cx = geo.size.width / 2
            let cy = geo.size.height / 2
            ZStack {
                Circle()
                    .stroke(element.neonColor.color.opacity(0.35), lineWidth: 2)
                    .frame(width: size * 0.95, height: size * 0.95)
                ForEach(0..<12, id: \.self) { i in
                    Rectangle()
                        .fill(element.textColor.color.opacity(i % 3 == 0 ? 0.9 : 0.4))
                        .frame(width: i % 3 == 0 ? 2 : 1, height: i % 3 == 0 ? size * 0.08 : size * 0.04)
                        .offset(y: -size * 0.42)
                        .rotationEffect(.degrees(Double(i) * 30))
                }
                // hour
                Capsule().fill(element.textColor.color)
                    .frame(width: 4, height: size * 0.25)
                    .offset(y: -size * 0.125)
                    .rotationEffect(hourAngle)
                // minute
                Capsule().fill(element.textColor.color.opacity(0.9))
                    .frame(width: 3, height: size * 0.35)
                    .offset(y: -size * 0.175)
                    .rotationEffect(minuteAngle)
                // second
                Capsule().fill(element.neonColor.color)
                    .frame(width: 1.5, height: size * 0.38)
                    .offset(y: -size * 0.15)
                    .rotationEffect(secondAngle)
                Circle().fill(element.neonColor.color).frame(width: 8, height: 8)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .position(x: cx, y: cy)
        }
    }
}
