//
//  File.swift
//  
//
//  Created by Joakim Hellgren on 2024-02-26.
//

import SwiftUI

internal extension CCSlider {
    var fillHeight: CGFloat { fullHeight * 2 }
    var fillOffset: CGFloat { fullHeight - currentHeight }
    var yScaleAnchor: UnitPoint { value < 0.5 ? .top : .bottom }
    
    var atMax: Bool { value >= bounds.upperBound }
    var atMin: Bool { value <= bounds.lowerBound }
    
    func layout(in frame: CGRect) {
        fullHeight = frame.height
        currentHeight = frame.height * CGFloat(value)
        previousHeight = currentHeight
    }
}
