import SwiftUI

struct StudioEditorView: View {
    @EnvironmentObject var store: WidgetStore
    @State private var selectedElementId: UUID?
    @State private var neonColor: Color = .cyan
    @State private var glassBlur: CGFloat = 0
    @State private var scaleX: CGFloat = 1
    @State private var scaleY: CGFloat = 1
    @State private var zIndex: Int = 0
    
    // 30+ Fonts (Mocked names for SwiftUI)
    let fonts = ["Courier", "Impact", "Pixel", "HelveticaNeue-CondensedBlack", "Georgia", "BrushScriptMT", "Menlo", "Futura", "AvenirNext-UltraLight", "Zapfino", "ChalkboardSE-Bold", "Papyrus", "Copperplate", "Noteworthy", "SnellRoundhand", "AmericanTypewriter", "Baskerville", "BodoniSvtyTwoITCTT-Book", "BradleyHandITCTT-Bold", "Chalkduster", "Cochin", "DevanagariSangamMN", "Didot", "EuphemiaUCAS", "Farah", "GeezaPro", "GujaratiSangamMN", "HeitiSC", "HiraginoSans", "Kailasa"]
    
    var body: some View {
        HSplitView {
            // Sidebar: Preset Library & Import/Export
            VStack(alignment: .leading, spacing: 15) {
                Text("Preset Library").font(.headline)
                ScrollView {
                    ForEach(["Slot 1", "Slot 2", "Slot 3", "Slot 4", "Slot 5", "Slot 6", "Slot 7", "Slot 8"], id: \.self) { slot in
                        Button(slot) {
                            store.currentSlotId = slot
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.cyan)
                    }
                }
                
                Divider()
                
                Text("Import/Export").font(.headline)
                Button("Export .neowidget") { store.exportCurrent() }
                Button("Import .neowidget") { store.importCurrent() }
                
                Divider()
                
                Text("Neon Engine").font(.headline)
                ColorPicker("Glow Color", selection: $neonColor)
                Slider(value: $glassBlur, in: 0...50, step: 1) { Text("Glass Blur") }
                Slider(value: $scaleX, in: 0.1...5, step: 0.1) { Text("Scale X") }
                Slider(value: $scaleY, in: 0.1...5, step: 0.1) { Text("Scale Y") }
                Stepper("Z-Index: \(zIndex)", value: $zIndex)
                
                Picker("Font", selection: .constant("Courier")) {
                    ForEach(fonts, id: \.self) { font in
                        Text(font).tag(font)
                    }
                }
                
                Spacer()
            }
            .padding()
            .frame(width: 250)
            
            // Interactive Canvas
            ZStack {
                Color.black.opacity(0.8)
                
                if let config = store.slots[store.currentSlotId] {
                    ForEach(config.elements) { element in
                        ElementView(element: element)
                            .position(x: 200, y: 200) // Simplified drag/stretch logic
                            .scaleEffect(x: element.scaleX, y: element.scaleY)
                            .shadow(color: element.neonColor ?? .clear, radius: 15, x: 0, y: 0)
                            .blur(radius: element.glassBlur)
                            .zIndex(Double(element.zIndex))
                            .onTapGesture {
                                selectedElementId = element.id
                                // Sync sliders
                                neonColor = element.neonColor ?? .cyan
                                glassBlur = element.glassBlur
                                scaleX = element.scaleX
                                scaleY = element.scaleY
                                zIndex = element.zIndex
                            }
                    }
                }
                
                // 8-Direction Handles (Visual Overlay for selected element)
                if let selectedId = selectedElementId, let config = store.slots[store.currentSlotId], let el = config.elements.first(where: { $0.id == selectedId }) {
                    HandlesOverlay(scaleX: $scaleX, scaleY: $scaleY)
                }
            }
            .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                // Handle .neowidget import drop
                return true
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button("Apply to Desktop Widget") {
                    store.save()
                }
            }
        }
    }
}

struct ElementView: View {
    var element: WidgetElement
    var body: some View {
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
        .foregroundColor(element.neonColor ?? .white)
    }
}

struct HandlesOverlay: View {
    @Binding var scaleX: CGFloat
    @Binding var scaleY: CGFloat
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // 8 Handles
                Circle().fill(Color.cyan).frame(width: 10, height: 10).position(x: 0, y: 0) // NW
                Circle().fill(Color.cyan).frame(width: 10, height: 10).position(x: geo.size.width, y: 0) // NE
                Circle().fill(Color.cyan).frame(width: 10, height: 10).position(x: 0, y: geo.size.height) // SW
                Circle().fill(Color.cyan).frame(width: 10, height: 10).position(x: geo.size.width, y: geo.size.height) // SE
                // Edge handles
                Circle().fill(Color.cyan).frame(width: 10, height: 10).position(x: geo.size.width/2, y: 0) // N
                Circle().fill(Color.cyan).frame(width: 10, height: 10).position(x: geo.size.width/2, y: geo.size.height) // S
                Circle().fill(Color.cyan).frame(width: 10, height: 10).position(x: 0, y: geo.size.height/2) // W
                Circle().fill(Color.cyan).frame(width: 10, height: 10).position(x: geo.size.width, y: geo.size.height/2) // E
            }
        }
    }
}
