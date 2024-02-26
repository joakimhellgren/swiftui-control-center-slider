//
// CCSlider+Gesture.swift
// Control Center Slider
// https://www.github.com/joakimhellgren/swiftui-control-center-slider
// See LICENSE for license information.
//

import SwiftUI

internal extension CCSlider {
    var withoutLongPress: some Gesture {
        LongPressGesture(minimumDuration: 0)
            .onEnded { _ in previousHeight = currentHeight }
            .sequenced(before: dragGesture)
    }
    
    var withLongPress: some Gesture {
        LongPressGesture(maximumDistance: 0.0)
            .onChanged { _ in
                withAnimation(.smooth(duration: 2.0)) {
                    yScale = 0.9
                }
                
                Task {
                    try? await Task.sleep(for: .seconds(2))
                    await UIImpactFeedbackGenerator().impactOccurred()
                }
            }
            .onEnded { _ in
                onLongPress!()
                withAnimation(.snappy) {
                    yScale = 1.0
                }
            }
            .exclusively(before: withoutLongPress)
    }
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { dragChanged($0) }
            .onEnded{ dragEnded($0) }
            .updating($isDragging) { _, gestureState, _ in
                gestureState = true
            }
    }
    
    private func dragChanged(_ gestureValue: DragGesture.Value) {
        let startLocation = gestureValue.startLocation.y
        let currentLocation = gestureValue.location.y
        let offset = startLocation + previousHeight - currentLocation
        
        animation = step == nil ? .none : .snappy
        currentHeight = adjustFrame(offset: offset)
        withAnimation(.snappy) {
            yScale = adjustScale(offset: offset)
            value = adjustSliderValue()
        }
    }
    
    private func dragEnded(_ gestureValue: DragGesture.Value) {
        let startLocation = gestureValue.startLocation.y
        let endLocation = gestureValue.predictedEndLocation.y
        let offset = startLocation - endLocation + previousHeight
        
        currentHeight = adjustFrame(offset: offset)
        previousHeight = currentHeight
        animation = .snappy
        withAnimation(.snappy) {
            yScale = 1.0
            value = adjustSliderValue()
        }
    }
    
    private func adjustSliderValue() -> V {
        let normalized = CGFloat.normalize(currentHeight, min: 0.0, max: fullHeight)
        return min(max(bounds.lowerBound, V(normalized)), bounds.upperBound)
    }
    
    private func adjustFrame(offset: CGFloat) -> CGFloat {
        let spacing = step == nil ? 1.0 : fullHeight * CGFloat(step ?? .zero)
        let nearest: CGFloat
        if (atMax || atMin) && step == nil {
            nearest = CGFloat.adjustToRange(offset, within: 0.0...fullHeight)
        } else {
            nearest = CGFloat.findNearest(offset, within: 0.0...(fullHeight + spacing), spacing: spacing)
        }
        
        return nearest
    }
    
    private func adjustScale(offset: CGFloat) -> CGFloat {
        var overflow: CGFloat?
        
        if offset > fullHeight {
            overflow = offset - fullHeight
        } else if offset < .zero {
            overflow = 0.0 - offset
        }
        
        guard let overflow else {
            return 1.0
        }
        
        let scale = min(1.05, 1 + (0.0001 * overflow))
        return scale
    }
}

fileprivate extension BinaryFloatingPoint {
    // Adjusts a value to fit within a specified range using a sigmoidal transformation.
    // - Parameters:
    //   - value: The value to adjust.
    //   - range: The target range within which the value should fall.
    //   - stretchFactor: Controls the stretch of the sigmoid curve. Default is 12.
    // - Returns: The adjusted value that falls within the specified range.
    static func adjustToRange<V: BinaryFloatingPoint>(_ value: V, within range: ClosedRange<V>, stretchFactor: V = V(12.0)) -> V {
        guard !range.contains(value) else { return value }
        let threshold = (value > range.upperBound) ? range.upperBound : range.lowerBound
        let value = value - threshold
        let x = V(pow(M_E, Double(value) / Double(stretchFactor)))
        return -(2 * stretchFactor) / V(1 + x) + stretchFactor + threshold
    }
    
    // Finds the nearest value to a target value within a specified bounds with optional spacing.
    // - Parameters:
    //   - targetValue: The value to approximate.
    //   - bounds: The range within which to find the nearest value.
    //   - spacing: The increment between values in the range. Default is 1.
    // - Returns: The value within `bounds` nearest to `targetValue`.
    static func findNearest<V>(_ targetValue: V, within bounds: ClosedRange<V>, spacing: V.Stride = 1) -> V where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
        let nearest = stride(from: bounds.lowerBound, to: bounds.upperBound, by: spacing).min(by: { abs($0 - targetValue) < abs($1 - targetValue) })
        return nearest ?? bounds.lowerBound
    }
    
    // Finds the closest value to a target value within an array of values.
    // - Parameters:
    //   - targetValue: The value to approximate.
    //   - array: An array of values to search through.
    // - Returns: The value from `array` closest to `targetValue`.
    static func findClosest<V: BinaryFloatingPoint>(_ targetValue: V, in array: [V]) -> V {
        guard let first = array.first else { fatalError("Array cannot be empty") }
        return array.reduce(first) { (currentClosest, value) in
            abs(value - targetValue) < abs(currentClosest - targetValue) ? value : currentClosest
        }
    }
    
    /// Returns normalized value for the range between `a` and `b`
    /// - Parameters:
    ///   - min: minimum range of measurement
    ///   - max: maximum range of measurement
    ///   - a: minimum range of scale
    ///   - b: minimum range of scale
    static func normalize<V: BinaryFloatingPoint>(_ value: V, min: V, max: V, from a: V = 0, to b: V = 1) -> V {
        (b - a) * ((value - min) / (max - min)) + a
    }
}
