//
// CCSlider.swift
// Control Center Slider
// https://www.github.com/joakimhellgren/swiftui-control-center-slider
// See LICENSE for license information.
//

import SwiftUI

public struct CCSlider<V, S>: View where V : BinaryFloatingPoint, V.Stride : BinaryFloatingPoint, S: ShapeStyle {
    @Binding var value: V
    
    let bounds: ClosedRange<V>
    let step: V.Stride?
    
    let onEditingChanged: (Bool) -> Void
    let onLongPress: (() -> Void)?
    
    let cornerRadius: CGFloat
    let backgroundStyle: S
    
    @State var fullHeight = 0.0
    @State var currentHeight = 0.0
    @State var previousHeight = 0.0
    
    @State var yScale: CGFloat = 1.0
    
    @State var animation: Animation? = .snappy
    @GestureState var isDragging = false
    
    public var body: some View {
        GeometryReader {
            let frame = $0.frame(in: .local)
            content
                .gesture(
                    onLongPress == nil ?
                    AnyGesture(withoutLongPress.map { _ in () }) :
                    AnyGesture(withLongPress.map { _ in () })
                )
                .sensoryFeedback(.decrease,
                                 trigger: atMin,
                                 condition: { $1 && $1 != $0 })
                .sensoryFeedback(.increase,
                                 trigger: atMax,
                                 condition: { $1 && $1 != $0 })
                .onChange(of: isDragging) {
                    onEditingChanged(isDragging)
                }
                .task(id: frame) {
                    layout(in: frame, animated: fullHeight > .zero)
                }
        }
    }
    
    private var content: some View {
        ZStack {
            backdrop
            marker
        }
        .frame(height: fullHeight)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .scaleEffect(x: 2.0 - yScale, y: yScale, anchor: yScaleAnchor)
        .contentShape(Rectangle())
        .animation(animation, value: currentHeight)
    }
    
    private var marker: some View {
        Rectangle()
            .offset(y: fillOffset)
            .frame(height: fillHeight)
            .offset(y: fullHeight/2)
    }
    
    private var backdrop: some View {
        Rectangle()
            .fill(backgroundStyle)
    }
}

// MARK: Init
public extension CCSlider {
    init (
        value: Binding<V>,
        in bounds: ClosedRange<V> = 0...1.0,
        step: V.Stride? = nil,
        cornerRadius: CGFloat = 40.0,
        backgroundStyle: S = Material.ultraThinMaterial,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onLongPress: (() -> Void)? = nil
    ) {
        self._value = value
        self.bounds = bounds
        self.step = step
        self.cornerRadius = cornerRadius
        self.backgroundStyle = backgroundStyle
        self.onEditingChanged = onEditingChanged
        self.onLongPress = onLongPress
    }
    
    init(value: Binding<V>, backgroundStyle: S = Material.ultraThinMaterial) {
        self._value = value
        self.bounds = 0...1.0
        self.step = nil
        self.cornerRadius = 40.0
        self.backgroundStyle = backgroundStyle
        self.onEditingChanged = { _ in }
        self.onLongPress = nil
    }
    
    init(value: Binding<V>, in bounds: ClosedRange<V>, backgroundStyle: S = Material.ultraThinMaterial) {
        self._value = value
        self.bounds = bounds
        self.step = nil
        self.cornerRadius = 40.0
        self.backgroundStyle = backgroundStyle
        self.onEditingChanged = { _ in }
        self.onLongPress = nil
    }
    
    init(value: Binding<V>, in bounds: ClosedRange<V>, step: V.Stride, backgroundStyle: S = Material.ultraThinMaterial) {
        self._value = value
        self.bounds = bounds
        self.step = step
        self.cornerRadius = 40.0
        self.backgroundStyle = backgroundStyle
        self.onEditingChanged = { _ in }
        self.onLongPress = nil
    }
}
