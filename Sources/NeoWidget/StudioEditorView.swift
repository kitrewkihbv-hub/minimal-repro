import SwiftUI
import WidgetKit
import UniformTypeIdentifiers
#if canImport(AppKit)
import AppKit
#endif
#if canImport(NeoWidgetShared)
import NeoWidgetShared
#endif

struct StudioEditorView: View {
    @EnvironmentObject var store: WidgetStore
    @EnvironmentObject var liveData: LiveDataProvider

    @State private var inspectorTab: InspectorTab = .style
    @State private var showPresetGallery: Bool = true
    @State private var customFontName: String = ""
    @State private var canvasDragOffset: CGSize = .zero
    @State private var draggingElementId: UUID? = nil
    @State private var dragStart: CGPoint? = nil

    enum InspectorTab: String, CaseIterable { case style = "Style", layout = "Layout", content = "Content" }

    private let fonts: [String] = [
        "SF Pro Display", "SF Pro Text", "Avenir Next Condensed", "Avenir Next", "Futura", "Helvetica Neue",
        "Gill Sans", "Impact", "Bebas Neue", "DIN Condensed", "Copperplate", "Optima", "Didot", "Bodoni 72",
        "Georgia", "Times New Roman", "Palatino", "American Typewriter", "Courier New", "Menlo", "Monaco",
        "Chalkboard SE", "Marker Felt", "Snell Roundhand", "Brush Script MT", "Zapfino", "Noteworthy", "Papyrus"
    ]

    var body: some View {
        VStack(spacing: 0) {
            topBar
            Divider()
            HSplitView {
                leftSidebar
                    .frame(minWidth: 260, idealWidth: 290, maxWidth: 340)
                canvasArea
                    .frame(minWidth: 420)
                rightInspector
                    .frame(minWidth: 300, idealWidth: 330, maxWidth: 380)
            }
        }
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear { liveData.startPolling() }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(spacing: 12) {
            Text("NeoWidget Studio")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            Divider().frame(height: 24)
            Text("Slot")
                .font(.caption)
                .foregroundStyle(.secondary)
            Picker("Slot", selection: $store.currentSlotId) {
                ForEach(NeoPresets.slotNames, id: \.self) { slot in
                    Text(slot).tag(slot)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 520)
            .onChange(of: store.currentSlotId) { _, _ in
                store.selectedElementId = nil
            }

            Spacer()

            Button {
                store.save()
                WidgetCenter.shared.reloadAllTimelines()
            } label: {
                Label("Apply to Desktop Widget", systemImage: "sparkles.rectangle.stack")
                    .font(.system(size: 13, weight: .semibold))
            }
            .buttonStyle(.borderedProminent)
            .tint(.cyan)
            .help("Save and reload all WidgetKit timelines")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    // MARK: - Left Sidebar

    private var leftSidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    presetGallerySection
                    Divider()
                    addLayerSection
                    Divider()
                    layersListSection
                    Divider()
                    importExportSection
                }
                .padding(12)
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
    }

    private var presetGallerySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Preset Gallery", systemImage: "square.grid.2x2")
                    .font(.headline)
                Spacer()
                Button(showPresetGallery ? "Hide" : "Show") { showPresetGallery.toggle() }
                    .buttonStyle(.plain)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if showPresetGallery {
                ForEach(NeoPresets.presetGallery(), id: \.id) { preset in
                    Button {
                        store.applyPreset(preset.config, to: store.currentSlotId)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: preset.icon)
                                .frame(width: 20)
                                .foregroundStyle(.cyan)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(preset.name)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                Text("\(preset.config.elements.count) layers")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "arrow.down.circle")
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.04)))
                    }
                    .buttonStyle(.plain)
                    .help("Load into \(store.currentSlotId)")
                }
            }
        }
    }

    private var addLayerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Add Layer", systemImage: "plus.square.on.square")
                .font(.headline)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                addButton("Tall Clock", icon: "clock.fill", type: .clock, content: "$df(hh:mm)$", w: 160, h: 120, font: "Avenir Next Condensed", fontSize: 56, neon: .cyan, scaleY: 1.5)
                addButton("Analog Clock", icon: "timer", type: .analogClock, content: "", w: 160, h: 160, font: "SF Pro Display", fontSize: 18, neon: .red)
                addButton("Music Player", icon: "music.note.list", type: .media, content: "$mi(title)$", w: 260, h: 90, font: "SF Pro Display", fontSize: 16, neon: .magenta)
                addButton("Weather Card", icon: "cloud.sun.fill", type: .weather, content: "$wi(temp)$", w: 180, h: 100, font: "Avenir Next", fontSize: 40, neon: .blue)
                addButton("System Stats", icon: "chart.bar.fill", type: .stats, content: "RAM: $rm(cused)$\nBAT: $bi(level)$", w: 240, h: 110, font: "Menlo", fontSize: 12, neon: .green)
                addButton("Custom Text", icon: "textformat", type: .text, content: "Your Text", w: 180, h: 50, font: "SF Pro Display", fontSize: 28, neon: .white)
                addButton("Neon Shape", icon: "square.on.circle", type: .shape, content: "", w: 180, h: 120, font: "SF Pro Display", fontSize: 18, neon: .purple)
                addButton("Image/GIF", icon: "photo", type: .image, content: "", w: 180, h: 140, font: "SF Pro Display", fontSize: 14, neon: .clear)
            }
        }
    }

    private func addButton(_ title: String, icon: String, type: WidgetType, content: String, w: CGFloat, h: CGFloat, font: String, fontSize: CGFloat, neon: CodableColor, scaleX: CGFloat = 1, scaleY: CGFloat = 1) -> some View {
        Button {
            let el = WidgetElement(
                type: type, content: content,
                x: (store.currentConfig?.canvasWidth ?? 320) / 2,
                y: (store.currentConfig?.canvasHeight ?? 320) / 2,
                width: w, height: h, scaleX: scaleX, scaleY: scaleY,
                fontName: font, fontSize: fontSize, fontWeight: "bold",
                textColor: .white,
                fillColor: type == .shape ? CodableColor(red: 0.1, green: 0.1, blue: 0.18, opacity: 0.7) : .clear,
                neonEnabled: neon != .clear,
                neonColor: neon, neonRadius: neon == .clear ? 0 : 12, neonIntensity: neon == .clear ? 0 : 0.8,
                cornerRadius: type == .shape ? 18 : (type == .media ? 16 : 8),
                backgroundOpacity: type == .shape ? 0.6 : 0.0
            )
            store.addElement(el)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.caption)
                Text(title).font(.caption2).lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .buttonStyle(.bordered)
        .tint(.cyan.opacity(0.7))
    }

    private var layersListSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Layers", systemImage: "square.3.layers.3d")
                    .font(.headline)
                Spacer()
                if let cfg = store.currentConfig {
                    Text("\(cfg.elements.count)").font(.caption).foregroundStyle(.secondary)
                }
            }
            let elements = (store.currentConfig?.elements ?? []).sorted { $0.zIndex > $1.zIndex }
            if elements.isEmpty {
                Text("No layers. Add one above.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 4)
            } else {
                ForEach(elements) { el in
                    layerRow(el)
                }
            }
        }
    }

    private func layerRow(_ el: WidgetElement) -> some View {
        let isSelected = store.selectedElementId == el.id
        return HStack(spacing: 6) {
            Button { store.selectedElementId = el.id } label: {
                HStack(spacing: 6) {
                    Image(systemName: el.type.icon)
                        .frame(width: 16)
                        .foregroundStyle(isSelected ? .cyan : .secondary)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(el.type.label).font(.caption).lineLimit(1)
                        Text(layerSummary(el)).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
                    }
                    Spacer()
                }
            }
            .buttonStyle(.plain)

            Button { store.moveElement(id: el.id, direction: 1) } label: { Image(systemName: "arrow.up") }
                .buttonStyle(.borderless).help("Bring forward")
            Button { store.moveElement(id: el.id, direction: -1) } label: { Image(systemName: "arrow.down") }
                .buttonStyle(.borderless).help("Send backward")
            Button { store.duplicateElement(id: el.id) } label: { Image(systemName: "plus.square.on.square") }
                .buttonStyle(.borderless).help("Duplicate")
            Button { store.toggleLock(id: el.id) } label: { Image(systemName: el.locked ? "lock.fill" : "lock.open") }
                .buttonStyle(.borderless).help(el.locked ? "Unlock" : "Lock")
            Button(role: .destructive) { store.deleteElement(id: el.id) } label: { Image(systemName: "trash") }
                .buttonStyle(.borderless).help("Delete")
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(RoundedRectangle(cornerRadius: 8).fill(isSelected ? Color.cyan.opacity(0.12) : Color.white.opacity(0.03)))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(isSelected ? Color.cyan.opacity(0.5) : Color.clear, lineWidth: 1))
    }

    private func layerSummary(_ el: WidgetElement) -> String {
        let c = el.content.trimmingCharacters(in: .whitespacesAndNewlines)
        if c.isEmpty { return "z:\(el.zIndex)" }
        return String(c.prefix(22)) + (c.count > 22 ? "…" : "")
    }

    private var importExportSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Import / Export", systemImage: "square.and.arrow.up.on.square")
                .font(.headline)
            HStack {
                Button { store.exportCurrentSlot() } label: {
                    Label("Export .neowidget", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                Button { store.importToCurrentSlot() } label: {
                    Label("Import .neowidget", systemImage: "square.and.arrow.down")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    // MARK: - Canvas

    private var canvasArea: some View {
        VStack(spacing: 0) {
            HStack {
                Text(store.currentConfig?.name ?? store.currentSlotId)
                    .font(.subheadline).foregroundStyle(.secondary)
                Spacer()
                if let cfg = store.currentConfig {
                    Text("\(Int(cfg.canvasWidth))×\(Int(cfg.canvasHeight))")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))

            GeometryReader { geo in
                ZStack {
                    Color(red: 0.08, green: 0.08, blue: 0.1)
                    canvasGrid(in: geo.size)

                    if let cfg = store.currentConfig {
                        let scale = canvasScale(for: cfg, in: geo.size)
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.black.opacity(0.35))
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.08), lineWidth: 1))
                            canvasElements(cfg: cfg, canvasScale: scale)
                        }
                        .frame(width: cfg.canvasWidth, height: cfg.canvasHeight)
                        .scaleEffect(scale)
                        .frame(width: cfg.canvasWidth * scale, height: cfg.canvasHeight * scale)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { store.selectedElementId = nil }
            }
        }
    }

    private func canvasScale(for cfg: WidgetConfig, in size: CGSize) -> CGFloat {
        let pad: CGFloat = 40
        let w = max(1, size.width - pad)
        let h = max(1, size.height - pad)
        return min(w / max(cfg.canvasWidth, 1), h / max(cfg.canvasHeight, 1), 1.0)
    }

    @ViewBuilder
    private func canvasElements(cfg: WidgetConfig, canvasScale: CGFloat) -> some View {
        let sorted = cfg.elements.sorted { $0.zIndex < $1.zIndex }
        ForEach(sorted) { element in
            let isSelected = store.selectedElementId == element.id
            ZStack {
                ElementRenderer(element: element, date: Date(), provider: liveData, isPreview: true)
                    .position(x: element.x, y: element.y)
                    .opacity(element.locked ? 0.85 : 1.0)
                    .overlay {
                        if isSelected {
                            RoundedRectangle(cornerRadius: max(2, element.cornerRadius * min(element.scaleX, element.scaleY)))
                                .stroke(Color.cyan.opacity(0.5), lineWidth: 1)
                                .frame(width: element.width * element.scaleX, height: element.height * element.scaleY)
                                .position(x: element.x, y: element.y)
                                .allowsHitTesting(false)
                        }
                    }
                    .gesture(element.locked ? nil : DragGesture()
                        .onChanged { value in
                            if draggingElementId != element.id {
                                draggingElementId = element.id
                                dragStart = CGPoint(x: element.x, y: element.y)
                                store.selectedElementId = element.id
                            }
                            guard let start = dragStart else { return }
                            updateElement(element.id, save: false) { el in
                                el.x = start.x + value.translation.width / canvasScale
                                el.y = start.y + value.translation.height / canvasScale
                            }
                        }
                        .onEnded { _ in
                            draggingElementId = nil
                            dragStart = nil
                            store.save(reloadTimelines: false)
                        }
                    )
                    .onTapGesture {
                        store.selectedElementId = element.id
                    }

                if isSelected && !element.locked {
                    HandlesOverlay(
                        scaleX: bindingFor(element.id, keyPath: \.scaleX),
                        scaleY: bindingFor(element.id, keyPath: \.scaleY),
                        width: bindingFor(element.id, keyPath: \.width),
                        height: bindingFor(element.id, keyPath: \.height),
                        stretchScale: false,
                        center: CGPoint(x: element.x, y: element.y),
                        baseWidth: max(24, element.width),
                        baseHeight: max(24, element.height)
                    )
                    .allowsHitTesting(true)
                }
            }
        }
    }

    private func canvasGrid(in size: CGSize) -> some View {
        Canvas { context, sz in
            let step: CGFloat = 24
            for x in stride(from: 0, through: sz.width, by: step) {
                var p = Path(); p.move(to: CGPoint(x: x, y: 0)); p.addLine(to: CGPoint(x: x, y: sz.height))
                context.stroke(p, with: .color(.white.opacity(0.04)), lineWidth: 1)
            }
            for y in stride(from: 0, through: sz.height, by: step) {
                var p = Path(); p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: sz.width, y: y))
                context.stroke(p, with: .color(.white.opacity(0.04)), lineWidth: 1)
            }
        }
    }

    // MARK: - Right Inspector

    private var rightInspector: some View {
        VStack(alignment: .leading, spacing: 0) {
            Picker("Inspector", selection: $inspectorTab) {
                ForEach(InspectorTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(12)

            Divider()

            if let selectedId = store.selectedElementId,
               let element = store.currentConfig?.elements.first(where: { $0.id == selectedId }) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        inspectorHeader(element)
                        Divider()
                        switch inspectorTab {
                        case .content: contentInspector(element)
                        case .layout: layoutInspector(element)
                        case .style: styleInspector(element)
                        }
                    }
                    .padding(12)
                }
            } else {
                VStack(spacing: 10) {
                    Spacer()
                    Image(systemName: "cursorarrow.rays")
                        .font(.system(size: 32))
                        .foregroundStyle(.secondary)
                    Text("Select a layer to edit")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("Pick a layer from the list or click on the canvas.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
    }

    private func inspectorHeader(_ el: WidgetElement) -> some View {
        HStack {
            Image(systemName: el.type.icon).foregroundStyle(.cyan)
            VStack(alignment: .leading) {
                Text(el.type.label).font(.headline)
                Text("zIndex \(el.zIndex) • \(el.locked ? "Locked" : "Editable")")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Button { store.duplicateElement(id: el.id) } label: { Image(systemName: "plus.square.on.square") }
                .buttonStyle(.borderless)
            Button(role: .destructive) { store.deleteElement(id: el.id) } label: { Image(systemName: "trash") }
                .buttonStyle(.borderless)
        }
    }

    // MARK: - Content Inspector

    @ViewBuilder
    private func contentInspector(_ el: WidgetElement) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Content / Formula").font(.subheadline.weight(.semibold))
            TextEditor(text: bindingFor(el.id, keyPath: \.content))
                .font(.system(.body, design: .monospaced))
                .frame(minHeight: 70, maxHeight: 140)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.white.opacity(0.1)))
            Text("Formulas: $df(hh:mm)$ $df(hh:mm:ss)$ $df(EEE, MMM d)$ $bi(level)$ $rm(cused)$ $wi(temp)$ $wi(cond)$ $mi(title)$ $mi(artist)$")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if el.type == .image {
                Divider()
                Text("Image / GIF Path").font(.subheadline.weight(.semibold))
                TextField("Image path", text: Binding(
                    get: { el.imagePath ?? "" },
                    set: { newVal in updateElement(el.id) { $0.imagePath = newVal; store.save() } }
                ))
                .textFieldStyle(.roundedBorder)
                Button("Choose Image...") { pickImage(for: el.id) }
                    .buttonStyle(.bordered)
            }

            Divider()
            Text("Live Preview").font(.subheadline.weight(.semibold))
            let preview = FormulaEngine.evaluate(el.content, provider: liveData, date: Date())
            Text(preview.isEmpty ? "—" : preview)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.cyan)
                .textSelection(.enabled)
        }
    }

    private func pickImage(for id: UUID) {
        #if canImport(AppKit)
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image, .gif]
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        if panel.runModal() == .OK, let url = panel.url {
            updateElement(id) { $0.imagePath = url.path }
        }
        #endif
    }

    // MARK: - Layout Inspector

    @ViewBuilder
    private func layoutInspector(_ el: WidgetElement) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Group {
                Text("Position").font(.subheadline.weight(.semibold))
                HStack {
                    labeledField("X", value: bindingFor(el.id, keyPath: \.x))
                    labeledField("Y", value: bindingFor(el.id, keyPath: \.y))
                }
            }
            Divider()
            Group {
                Text("Size").font(.subheadline.weight(.semibold))
                sliderRow("Width", value: bindingFor(el.id, keyPath: \.width), range: 24...800)
                sliderRow("Height", value: bindingFor(el.id, keyPath: \.height), range: 24...800)
            }
            Divider()
            Group {
                Text("Stretch / Scale").font(.subheadline.weight(.semibold))
                sliderRow("Scale X", value: bindingFor(el.id, keyPath: \.scaleX), range: 0.1...5.0)
                sliderRow("Scale Y", value: bindingFor(el.id, keyPath: \.scaleY), range: 0.1...5.0)
                Text("Tip: stretch clocks super tall/long with Scale Y / Scale X.")
                    .font(.caption2).foregroundStyle(.secondary)
            }
            Divider()
            Group {
                Text("Layer").font(.subheadline.weight(.semibold))
                Stepper("zIndex: \(el.zIndex)", value: Binding(
                    get: { el.zIndex },
                    set: { newVal in updateElement(el.id) { $0.zIndex = newVal; store.save() } }
                ))
                rotationSlider(el)
            }
        }
    }

    private func rotationSlider(_ el: WidgetElement) -> some View {
        HStack {
            Text("Rotation").font(.caption)
            Slider(value: Binding(
                get: { el.rotation },
                set: { v in updateElement(el.id) { $0.rotation = v } }
            ), in: -180...180)
            Text("\(Int(el.rotation))°").font(.caption.monospacedDigit()).frame(width: 44)
        }
    }

    // MARK: - Style Inspector

    @ViewBuilder
    private func styleInspector(_ el: WidgetElement) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Font
            Group {
                Text("Font").font(.subheadline.weight(.semibold))
                Picker("Font", selection: bindingFor(el.id, keyPath: \.fontName)) {
                    ForEach(fonts, id: \.self) { f in Text(f).tag(f) }
                    if !fonts.contains(el.fontName) {
                        Text(el.fontName).tag(el.fontName)
                    }
                }
                .labelsHidden()
                HStack {
                    TextField("Custom font name", text: $customFontName)
                        .textFieldStyle(.roundedBorder)
                    Button("Apply") {
                        let name = customFontName.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !name.isEmpty { updateElement(el.id) { $0.fontName = name; store.save() } }
                    }
                    .buttonStyle(.bordered)
                }
                HStack {
                    Text("Size").font(.caption)
                    Slider(value: bindingFor(el.id, keyPath: \.fontSize), in: 8...140)
                    Text("\(Int(el.fontSize))").font(.caption.monospacedDigit()).frame(width: 36)
                }
                Picker("Weight", selection: bindingFor(el.id, keyPath: \.fontWeight)) {
                    ForEach(["ultraLight","thin","light","regular","medium","semibold","bold","heavy","black"], id: \.self) { w in
                        Text(w.capitalized).tag(w)
                    }
                }
                .pickerStyle(.menu)
            }

            Divider()
            // Colors
            Group {
                Text("Text & Fill").font(.subheadline.weight(.semibold))
                colorPickerRow("Text Color", color: colorBinding(el.id, keyPath: \.textColor))
                colorPickerRow("Fill Color", color: colorBinding(el.id, keyPath: \.fillColor))
                HStack {
                    Text("Background Opacity").font(.caption)
                    Slider(value: bindingFor(el.id, keyPath: \.backgroundOpacity), in: 0...1)
                    Text(String(format: "%.2f", el.backgroundOpacity)).font(.caption.monospacedDigit()).frame(width: 40)
                }
            }

            Divider()
            // Gradient
            Group {
                Toggle("2-Color Linear Gradient", isOn: bindingFor(el.id, keyPath: \.useGradient))
                    .toggleStyle(.switch)
                if el.useGradient {
                    colorPickerRow("Gradient Color 2", color: colorBinding(el.id, keyPath: \.gradientColor2))
                    Picker("Direction", selection: bindingFor(el.id, keyPath: \.gradientDirection)) {
                        ForEach(GradientDirection.allCases) { d in
                            Text(d.rawValue.capitalized).tag(d)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }

            Divider()
            // Neon
            Group {
                Text("Neon Glow").font(.subheadline.weight(.semibold))
                Toggle("Neon Enabled", isOn: bindingFor(el.id, keyPath: \.neonEnabled))
                colorPickerRow("Neon Color", color: colorBinding(el.id, keyPath: \.neonColor))
                HStack {
                    Text("Blur Radius").font(.caption)
                    Slider(value: bindingFor(el.id, keyPath: \.neonRadius), in: 0...60)
                    Text("\(Int(el.neonRadius))").font(.caption.monospacedDigit()).frame(width: 32)
                }
                HStack {
                    Text("Intensity").font(.caption)
                    Slider(value: bindingFor(el.id, keyPath: \.neonIntensity), in: 0...1)
                    Text(String(format: "%.2f", el.neonIntensity)).font(.caption.monospacedDigit()).frame(width: 40)
                }
            }

            Divider()
            // Glass / Shape
            Group {
                Text("Glass & Corners").font(.subheadline.weight(.semibold))
                HStack {
                    Text("Glass Blur").font(.caption)
                    Slider(value: bindingFor(el.id, keyPath: \.glassBlur), in: 0...40)
                    Text("\(Int(el.glassBlur))").font(.caption.monospacedDigit()).frame(width: 32)
                }
                HStack {
                    Text("Corner Radius").font(.caption)
                    Slider(value: bindingFor(el.id, keyPath: \.cornerRadius), in: 0...120)
                    Text("\(Int(el.cornerRadius))").font(.caption.monospacedDigit()).frame(width: 32)
                }
                HStack {
                    Text("Border Width").font(.caption)
                    Slider(value: bindingFor(el.id, keyPath: \.borderWidth), in: 0...12)
                    Text(String(format: "%.1f", el.borderWidth)).font(.caption.monospacedDigit()).frame(width: 36)
                }
                colorPickerRow("Border Color", color: colorBinding(el.id, keyPath: \.borderColor))
            }
        }
    }

    // MARK: - Helpers

    private func colorPickerRow(_ label: String, color: Binding<Color>) -> some View {
        HStack {
            Text(label).font(.caption)
            Spacer()
            ColorPicker("", selection: color, supportsOpacity: true)
                .labelsHidden()
        }
    }

    private func sliderRow(_ label: String, value: Binding<CGFloat>, range: ClosedRange<CGFloat>) -> some View {
        HStack {
            Text(label).font(.caption).frame(width: 58, alignment: .leading)
            Slider(value: value, in: range)
            Text("\(Int(value.wrappedValue))")
                .font(.caption.monospacedDigit())
                .frame(width: 44, alignment: .trailing)
        }
    }

    private func labeledField(_ label: String, value: Binding<CGFloat>) -> some View {
        HStack(spacing: 4) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            TextField(label, value: Binding(get: { Double(value.wrappedValue) }, set: { value.wrappedValue = CGFloat($0) }), format: .number)
                .textFieldStyle(.roundedBorder)
                .frame(width: 72)
        }
    }

    private func selectedElement() -> WidgetElement? {
        guard let id = store.selectedElementId else { return nil }
        return store.currentConfig?.elements.first(where: { $0.id == id })
    }

    private func updateElement(_ id: UUID, save: Bool = true, reloadTimelines: Bool = false, mutate: (inout WidgetElement) -> Void) {
        guard var cfg = store.slots[store.currentSlotId],
              let idx = cfg.elements.firstIndex(where: { $0.id == id }) else { return }
        mutate(&cfg.elements[idx])
        store.slots[store.currentSlotId] = cfg
        if save { store.save(reloadTimelines: reloadTimelines) }
    }

    private func bindingFor<T>(_ id: UUID, keyPath: WritableKeyPath<WidgetElement, T>) -> Binding<T> {
        Binding<T>(
            get: {
                store.slots[store.currentSlotId]?.elements.first(where: { $0.id == id })?[keyPath: keyPath]
                    ?? NeoPresets.defaultSlots()["Slot 1"]!.elements[0][keyPath: keyPath]
            },
            set: { newValue in
                guard var cfg = store.slots[store.currentSlotId],
                      let idx = cfg.elements.firstIndex(where: { $0.id == id }) else { return }
                cfg.elements[idx][keyPath: keyPath] = newValue
                store.slots[store.currentSlotId] = cfg
                store.save(reloadTimelines: false)
            }
        )
    }

    private func colorBinding(_ id: UUID, keyPath: WritableKeyPath<WidgetElement, CodableColor>) -> Binding<Color> {
        Binding<Color>(
            get: {
                let c = store.slots[store.currentSlotId]?.elements.first(where: { $0.id == id })?[keyPath: keyPath] ?? .white
                return c.color
            },
            set: { newColor in
                guard var cfg = store.slots[store.currentSlotId],
                      let idx = cfg.elements.firstIndex(where: { $0.id == id }) else { return }
                cfg.elements[idx][keyPath: keyPath] = CodableColor(newColor)
                store.slots[store.currentSlotId] = cfg
                store.save(reloadTimelines: false)
            }
        )
    }
}
