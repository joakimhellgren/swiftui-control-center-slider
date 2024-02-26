import SwiftUI

public struct CCSlider<V>: View where V : BinaryFloatingPoint, V.Stride : BinaryFloatingPoint {
    @GestureState var isDragging = false
    @State var animation: Animation? = .none
    
    let bounds: ClosedRange<V>
    let step: V.Stride?
    
    @Binding var value: V
    
    let onEditingChanged: (Bool) -> Void
    let onLongPress: (() -> Void)?
    
    let cornerRadius: CGFloat
    
    @State var fullHeight: CGFloat = .zero
    @State var currentHeight: CGFloat = .zero
    @State var previousHeight: CGFloat = .zero
    
    @State var yScale: CGFloat = 1.0
    
    public var body: some View {
        GeometryReader {
            let frame = $0.frame(in: .local)
            ZStack {
                Rectangle()
                    .fill(.bar)
                Rectangle()
                    .offset(y: fillOffset)
                    .frame(height: fillHeight)
                    .offset(y: fullHeight/2)
            }
            .frame(height: fullHeight)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .scaleEffect(x: 2.0 - yScale, y: yScale, anchor: yScaleAnchor)
            .animation(animation, value: currentHeight)
            .contentShape(Rectangle())
            .gesture(dragGesture)
            .task { @MainActor in
                layout(in: frame)
            }
        }
    }
}

// MARK: Init
public extension CCSlider {
    init (
        value: Binding<V>,
        in bounds: ClosedRange<V>,
        step: V.Stride?,
        cornerRadius: CGFloat,
        onEditingChanged: @escaping (Bool) -> Void,
        onLongPress: (() -> Void)?
    ) {
        self._value = value
        self.bounds = bounds
        self.step = step
        self.cornerRadius = cornerRadius
        self.onEditingChanged = onEditingChanged
        self.onLongPress = onLongPress
    }
    
    init(value: Binding<V>) {
        self._value = value
        self.bounds = 0...1.0
        self.step = nil
        self.cornerRadius = 25.0
        self.onEditingChanged = { _ in }
        self.onLongPress = nil
    }
    
    init(value: Binding<V>, in bounds: ClosedRange<V>) {
        self._value = value
        self.bounds = bounds
        self.step = nil
        self.cornerRadius = 25.0
        self.onEditingChanged = { _ in }
        self.onLongPress = nil
    }
    
    init(value: Binding<V>, in bounds: ClosedRange<V>, step: V.Stride) {
        self._value = value
        self.bounds = bounds
        self.step = step
        self.cornerRadius = 25.0
        self.onEditingChanged = { _ in }
        self.onLongPress = nil
    }
}
