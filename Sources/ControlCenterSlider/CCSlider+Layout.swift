//
// CCSlider+Layout.swift
// Control Center Slider
// https://www.github.com/joakimhellgren/swiftui-control-center-slider
// See LICENSE for license information.
//


import SwiftUI

internal extension CCSlider {
    var fillHeight: CGFloat { fullHeight * 2 }
    var fillOffset: CGFloat { fullHeight - currentHeight }
    var yScaleAnchor: UnitPoint { value < 0.5 ? .top : .bottom }
    
    var atMax: Bool { value >= bounds.upperBound }
    var atMin: Bool { value <= bounds.lowerBound }
    
    func layout(in frame: CGRect, animated: Bool = true) {
        withAnimation(animated ? animation : nil) {
            fullHeight = frame.height
            currentHeight = frame.height * CGFloat(value)
            previousHeight = currentHeight
        }
    }
}
