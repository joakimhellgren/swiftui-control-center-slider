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
            .onEnded { _ in self.previouOffset = self.offset }
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
            .onChanged { onChanged($0) }
            .onEnded{ onEnded($0) }
            .updating($isDragging) { _, gestureState, _ in
                gestureState = true
            }
    }
    
    private func onChanged(_ gesture: DragGesture.Value) {
        let offset: CGFloat = {
            let value = gesture.startLocation.y + self.previouOffset - gesture.location.y
            
            if let step {
                let increment = self.height*CGFloat(step)
                let bounds = 0...self.height+increment
                return .findNearest(value, within: bounds, spacing: increment)
            }
            
            return .adjustToRange(value, within: 0...self.height)
        }()
        
        let value: V = {
            let normalized: CGFloat = .normalize(offset, min: 0, max: self.height)
            let clamped = min(max(self.bounds.lowerBound, V(normalized)), self.bounds.upperBound)
            return clamped
        }()
        
        let yScale: CGFloat = {
            let value = gesture.startLocation.y + self.previouOffset - gesture.location.y
            let overflow = self.atMin ? 0.0 - value : self.atMax ? value - self.offset : 0.0
            let clamped = min(1.05, 1 + (0.0001 * overflow))
            return clamped
        }()
        
        self.offset = offset
        self.value = value
        self.yScale = yScale
        
        self.animation = self.step == nil ? .none : .snappy
    }
    
    private func onEnded(_ gesture: DragGesture.Value) {
        let offset: CGFloat = .adjustToRange(
            gesture.startLocation.y - gesture.predictedEndLocation.y + self.previouOffset,
            within: 0...self.height
        )
        
        let value: V = {
            let normalized: CGFloat = .normalize(offset, min: 0, max: self.height)
            let clamped = min(max(self.bounds.lowerBound, V(normalized)), self.bounds.upperBound)
            return clamped
        }()
        
        self.animation = .snappy
        self.offset = offset
        
        withAnimation(.snappy) {
            self.yScale = 1
            self.value = value
        }
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
        let nearest = stride(from: bounds.lowerBound, to: bounds.upperBound, by: spacing)
            .min(by: { abs($0 - targetValue) < abs($1 - targetValue) })
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
