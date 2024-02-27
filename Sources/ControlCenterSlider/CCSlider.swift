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
    
    @State var height = 0.0
    @State var offset = 0.0
    @State var previouOffset = 0.0
    
    @State var yScale: CGFloat = 1.0
    
    @State var animation: Animation? = .snappy
    @GestureState var isDragging = false
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
