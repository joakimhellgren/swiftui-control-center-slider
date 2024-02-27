//
// CCSlider+Layout.swift
// Control Center Slider
// https://www.github.com/joakimhellgren/swiftui-control-center-slider
// See LICENSE for license information.
//

import SwiftUI

extension CCSlider {
    
    var atMax: Bool { self.offset >= self.height }
    var atMin: Bool { self.offset <= .zero }
    
    private var yScaleAnchor: UnitPoint { value < 0.5 ? .top : .bottom }
    
    private func layout(in frame: CGRect, animated: Bool = true) {
        withAnimation(animated ? animation : nil) {
            height = frame.height
            offset = frame.height * CGFloat(value)
            previouOffset = offset 
        }
    }
    
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
                    layout(in: frame, animated: height > .zero)
                }
        }
    }
    
    var content: some View {
        ZStack {
            Rectangle()
                .fill(backgroundStyle)
            Rectangle()
                .offset(y: height - offset)
                .frame(height: height*2)
                .offset(y: height/2)
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .scaleEffect(x: 2.0 - yScale, y: yScale, anchor: yScaleAnchor)
        .contentShape(Rectangle())
        .animation(animation, value: offset)
    }
}
