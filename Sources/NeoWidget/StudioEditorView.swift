import SwiftUI
import UniformTypeIdentifiers
#if canImport(NeoWidgetShared)
import NeoWidgetShared
#endif

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
                        let isSelected = element.id == selectedElementId
                        ElementView(element: element)
                            .position(x: 200, y: 200) // Simplified drag/stretch logic
                            .scaleEffect(
                                x: isSelected ? scaleX : element.scaleX,
                                y: isSelected ? scaleY : element.scaleY
                            )
                            .shadow(color: (isSelected ? neonColor : (element.neonColor?.color ?? .clear)), radius: 15, x: 0, y: 0)
                            .blur(radius: isSelected ? glassBlur : element.glassBlur)
                            .zIndex(Double(isSelected ? zIndex : element.zIndex))
                            .onTapGesture {
                                selectedElementId = element.id
                                // Sync sliders
                                neonColor = element.neonColor?.color ?? .cyan
                                glassBlur = element.glassBlur
                                scaleX = element.scaleX
                                scaleY = element.scaleY
                                zIndex = element.zIndex
                            }
                    }
                }
                
                // 8-Direction Handles (Visual Overlay for selected element)
                if let selectedId = selectedElementId, let config = store.slots[store.currentSlotId], config.elements.contains(where: { $0.id == selectedId }) {
                    HandlesOverlay(scaleX: $scaleX, scaleY: $scaleY)
                        .zIndex(Double(zIndex) + 1)
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
                    if let selectedId = selectedElementId,
                       var config = store.slots[store.currentSlotId],
                       let index = config.elements.firstIndex(where: { $0.id == selectedId }) {
                        config.elements[index].scaleX = scaleX
                        config.elements[index].scaleY = scaleY
                        config.elements[index].glassBlur = glassBlur
                        config.elements[index].zIndex = zIndex
                        config.elements[index].neonColor = CodableColor(neonColor)
                        store.slots[store.currentSlotId] = config
                    }
                    store.save()
                }
            }
        }
    }
}
