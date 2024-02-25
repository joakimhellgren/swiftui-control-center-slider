import SwiftUI

@Observable
public final class CCSliderContext {
    var dragging = false
    var animation: Animation? = .snappy
    
    var currentHeight = 0.0
    var previousHeight = 0.0
    var maxHeight = 0.0
    
    var frameBounds: ClosedRange<Double> {
        0.0...maxHeight
    }
    
    var yScale = 1.0
    var yScaleAnchor = UnitPoint.center
    
    public init(
        dragging: Bool = false,
        animation: Animation? = nil,
        currentHeight: Double = 0.0,
        previousHeight: Double = 0.0,
        maxHeight: Double = 0.0,
        yScale: Double = 1.0,
        yScaleAnchor: SwiftUI.UnitPoint = UnitPoint.center
    ) {
        self.dragging = dragging
        self.animation = animation
        self.currentHeight = currentHeight
        self.previousHeight = previousHeight
        self.maxHeight = maxHeight
        self.yScale = yScale
        self.yScaleAnchor = yScaleAnchor
    }
}

public struct CCSlider: View {
    @Binding private var value: Double
    
    private let bounds: ClosedRange<Double>
    private let step: Double.Stride?
    private let cornerRadius: Double
    
    public init(
        value: Binding<Double>,
        in bounds: ClosedRange<Double>,
        step: Double.Stride? = nil,
        cornerRadius: Double = 25.0
    ) {
        self._value = value
        self.bounds = bounds
        self.step = step
        self.cornerRadius = cornerRadius
    }
    
    @State private var context = CCSliderContext()
    
    public var body: some View {
        GeometryReader {
            let frame = $0.frame(in: .local)
            ZStack {
                Rectangle()
                    .fill(.bar)
                Rectangle()
                    .offset(y: frame.height - context.currentHeight)
                    .frame(height: context.maxHeight * 2)
                    .offset(y: context.maxHeight/2)
            }
            .frame(height: context.maxHeight)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .scaleEffect(x: 2.0 - context.yScale, y: context.yScale, anchor: context.yScaleAnchor)
            .animation(context.animation, value: context.dragging)
            .animation(context.animation, value: context.yScale)
            .contentShape(Rectangle())
            .gesture(dragGesture)
            .task { @MainActor in
                context.maxHeight = frame.height
                context.currentHeight = frame.height * CGFloat(value)
                context.previousHeight = context.currentHeight
            }
        }
    }
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { dragChanged($0) }
            .onEnded { dragEnded($0) }
    }
    
    private func dragChanged(_ gestureValue: DragGesture.Value) {
        let startLocation = gestureValue.startLocation.y
        let currentLocation = gestureValue.location.y
        
        let distance = context.previousHeight - currentLocation
        let offset = startLocation + distance
        
        let lowerBound = context.frameBounds.lowerBound
        let upperBound = context.frameBounds.upperBound
        
        let nearest = Self.nearestMarkerWithinBounds(offset, bounds: context.frameBounds)
        let normalized = Self.normalize(nearest, min: lowerBound, max: upperBound)
        
        let outsideBounds = offset > upperBound || offset < lowerBound
        
        context.dragging = true
        context.animation = step == nil ? .none : .snappy
        
        context.currentHeight = nearest
        value = normalized
        
        context.yScaleAnchor = value < 0.5 ? .top : .bottom
        context.yScale = outsideBounds ? 1.05 : 1.0
    }
    
    private func dragEnded(_ gestureValue: DragGesture.Value) {
        let startLocation = gestureValue.startLocation.y
        let endLocation = gestureValue.predictedEndLocation.y
        
        let distance = startLocation - endLocation + context.previousHeight
        
        let lowerBound = context.frameBounds.lowerBound
        let upperBound = context.frameBounds.upperBound
        
        let adjusted = Self.adjustedWithinRange(distance, to: context.frameBounds)
        let normalized = Self.normalize(adjusted, min: lowerBound, max: upperBound)
        
        context.currentHeight = adjusted
        context.previousHeight = context.currentHeight
        
        context.dragging = false
        context.animation = .snappy
        
        context.yScale = 1.0
        
        withAnimation(.snappy) {
            value = normalized
        }
    }
    
    /// Adjusts the value to be within a given range, with optional stretching for values outside the range.
    static func adjustedWithinRange(_ value: Double, to range: ClosedRange<Double>, withStretch stretch: Double = 12.0) -> Double {
        if range.contains(value) {
            return value
        } else if value > range.upperBound {
            let excess = value - range.upperBound
            let scaledExcess = pow(M_E, excess / stretch)
            return -(2 * stretch) / (1 + scaledExcess) + stretch + range.upperBound
        } else {
            let deficit = value - range.lowerBound
            let scaledDeficit = pow(M_E, deficit / stretch)
            return -(2 * stretch) / (1 + scaledDeficit) + stretch + range.lowerBound
        }
    }
    
    /// Finds the nearest marker within a given bounds, using a specified spacing.
    static func nearestMarkerWithinBounds(_ value: Double, bounds: ClosedRange<Double>, withSpacing spacing: Double.Stride = 1) -> Double {
        let targetValue = value
        let markers = Array(stride(from: bounds.lowerBound, to: bounds.upperBound, by: spacing))
        guard let closestMarker = markers.min(by: { abs($0 - targetValue) < abs($1 - targetValue) }) else {
            return value
        }
        return closestMarker
    }
    
    /// Finds the marker closest to the value from a provided array of markers.
    static func closestToMarker(_ value: Double, from markers: [Double]) -> Double {
        let targetValue = value
        guard let closestMarker = markers.min(by: { abs($0 - targetValue) < abs($1 - targetValue) }) else {
            fatalError("Unable to find the closest marker.")
        }
        return closestMarker
    }
    
    /// Returns normalized value for the range between `a` and `b`
    /// - Parameters:
    ///   - min: minimum range of measurement
    ///   - max: maximum range of measurement
    ///   - a: minimum range of scale
    ///   - b: minimum range of scale
    static func normalize(_ value: Double, min: Double, max: Double, from a: Double = 0, to b: Double = 1) -> Double {
        (b - a) * ((value - min) / (max - min)) + a
    }
}
