import SwiftUI

struct HandlesOverlay: View {
    enum HandleDirection: CaseIterable, Identifiable {
        case topLeft
        case top
        case topRight
        case right
        case bottomRight
        case bottom
        case bottomLeft
        case left

        var id: Self { self }

        var horizontalFactor: CGFloat {
            switch self {
            case .topLeft, .left, .bottomLeft:
                return -1
            case .top, .bottom:
                return 0
            case .topRight, .right, .bottomRight:
                return 1
            }
        }

        var verticalFactor: CGFloat {
            switch self {
            case .topLeft, .top, .topRight:
                return -1
            case .left, .right:
                return 0
            case .bottomLeft, .bottom, .bottomRight:
                return 1
            }
        }

        var isCorner: Bool {
            horizontalFactor != 0 && verticalFactor != 0
        }
    }

    @Binding var scaleX: CGFloat
    @Binding var scaleY: CGFloat
    private var widthBinding: Binding<CGFloat>?
    private var heightBinding: Binding<CGFloat>?
    var stretchScale: Bool

    var center: CGPoint
    var baseWidth: CGFloat
    var baseHeight: CGFloat

    @State private var localWidth: CGFloat
    @State private var localHeight: CGFloat
    @State private var activeHandle: HandleDirection?
    @State private var dragStartScaleX: CGFloat?
    @State private var dragStartScaleY: CGFloat?
    @State private var dragStartWidth: CGFloat?
    @State private var dragStartHeight: CGFloat?

    private let minScale: CGFloat = 0.1
    private let maxScale: CGFloat = 5.0
    private let minDimension: CGFloat = 24.0
    private let maxDimension: CGFloat = 1200.0
    private let handleSize: CGFloat = 10.0

    init(
        scaleX: Binding<CGFloat>,
        scaleY: Binding<CGFloat>,
        width: Binding<CGFloat>? = nil,
        height: Binding<CGFloat>? = nil,
        stretchScale: Bool = true,
        center: CGPoint = CGPoint(x: 200, y: 200),
        baseWidth: CGFloat = 160,
        baseHeight: CGFloat = 80
    ) {
        self._scaleX = scaleX
        self._scaleY = scaleY
        self.widthBinding = width
        self.heightBinding = height
        self.stretchScale = stretchScale
        self.center = center
        self.baseWidth = baseWidth
        self.baseHeight = baseHeight
        self._localWidth = State(initialValue: width?.wrappedValue ?? baseWidth)
        self._localHeight = State(initialValue: height?.wrappedValue ?? baseHeight)
    }

    private var currentBaseWidth: CGFloat {
        widthBinding?.wrappedValue ?? localWidth
    }

    private var currentBaseHeight: CGFloat {
        heightBinding?.wrappedValue ?? localHeight
    }

    private var effectiveWidth: CGFloat {
        max(minDimension, currentBaseWidth * scaleX)
    }

    private var effectiveHeight: CGFloat {
        max(minDimension, currentBaseHeight * scaleY)
    }

    var body: some View {
        ZStack {
            Rectangle()
                .strokeBorder(
                    Color.cyan.opacity(0.9),
                    style: StrokeStyle(lineWidth: 1.5, dash: [5, 3])
                )
                .frame(width: effectiveWidth, height: effectiveHeight)
                .position(center)
                .allowsHitTesting(false)

            ForEach(HandleDirection.allCases) { direction in
                handleView(for: direction)
                    .position(handlePosition(for: direction))
                    .gesture(resizeGesture(for: direction))
            }
        }
    }

    @ViewBuilder
    private func handleView(for direction: HandleDirection) -> some View {
        let isActive = activeHandle == direction
        Group {
            if direction.isCorner {
                Circle()
                    .fill(isActive ? Color.white : Color.cyan)
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.8), lineWidth: 1.5)
                    )
            } else {
                RoundedRectangle(cornerRadius: 2)
                    .fill(isActive ? Color.white : Color.cyan)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color.black.opacity(0.8), lineWidth: 1.5)
                    )
            }
        }
        .frame(width: handleSize, height: handleSize)
        .shadow(color: Color.cyan.opacity(0.8), radius: isActive ? 6 : 3)
        .contentShape(Rectangle().inset(by: -6))
    }

    private func handlePosition(for direction: HandleDirection) -> CGPoint {
        CGPoint(
            x: center.x + direction.horizontalFactor * (effectiveWidth / 2.0),
            y: center.y + direction.verticalFactor * (effectiveHeight / 2.0)
        )
    }

    private func resizeGesture(for direction: HandleDirection) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if activeHandle != direction {
                    activeHandle = direction
                    dragStartScaleX = scaleX
                    dragStartScaleY = scaleY
                    dragStartWidth = currentBaseWidth
                    dragStartHeight = currentBaseHeight
                }

                let startScaleX = dragStartScaleX ?? scaleX
                let startScaleY = dragStartScaleY ?? scaleY
                let startWidth = max(minDimension, dragStartWidth ?? currentBaseWidth)
                let startHeight = max(minDimension, dragStartHeight ?? currentBaseHeight)

                let deltaWidth = 2.0 * direction.horizontalFactor * value.translation.width
                let deltaHeight = 2.0 * direction.verticalFactor * value.translation.height

                if direction.horizontalFactor != 0 {
                    if let widthBinding = widthBinding {
                        let updatedWidth = clamp(
                            startWidth + (deltaWidth / max(startScaleX, minScale)),
                            min: minDimension,
                            max: maxDimension
                        )
                        widthBinding.wrappedValue = updatedWidth
                        localWidth = updatedWidth
                    } else if !stretchScale {
                        let updatedWidth = clamp(
                            startWidth + (deltaWidth / max(startScaleX, minScale)),
                            min: minDimension,
                            max: maxDimension
                        )
                        localWidth = updatedWidth
                    } else {
                        let startEffectiveWidth = startWidth * startScaleX
                        let updatedEffectiveWidth = max(minDimension * minScale, startEffectiveWidth + deltaWidth)
                        let updatedScaleX = clamp(updatedEffectiveWidth / startWidth, min: minScale, max: maxScale)
                        scaleX = updatedScaleX
                    }
                }

                if direction.verticalFactor != 0 {
                    if let heightBinding = heightBinding {
                        let updatedHeight = clamp(
                            startHeight + (deltaHeight / max(startScaleY, minScale)),
                            min: minDimension,
                            max: maxDimension
                        )
                        heightBinding.wrappedValue = updatedHeight
                        localHeight = updatedHeight
                    } else if !stretchScale {
                        let updatedHeight = clamp(
                            startHeight + (deltaHeight / max(startScaleY, minScale)),
                            min: minDimension,
                            max: maxDimension
                        )
                        localHeight = updatedHeight
                    } else {
                        let startEffectiveHeight = startHeight * startScaleY
                        let updatedEffectiveHeight = max(minDimension * minScale, startEffectiveHeight + deltaHeight)
                        let updatedScaleY = clamp(updatedEffectiveHeight / startHeight, min: minScale, max: maxScale)
                        scaleY = updatedScaleY
                    }
                }
            }
            .onEnded { _ in
                activeHandle = nil
                dragStartScaleX = nil
                dragStartScaleY = nil
                dragStartWidth = nil
                dragStartHeight = nil
            }
    }

    private func clamp(_ value: CGFloat, min lower: CGFloat, max upper: CGFloat) -> CGFloat {
        Swift.min(Swift.max(value, lower), upper)
    }
}
