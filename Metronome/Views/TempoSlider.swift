//
//  TempoSlider.swift
//  Metronome
//
//  Created by Георгий Ступаков on 4/2/21.
//

import UIKit
import Foundation

class TempoSlider: UISlider {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.value = 180.0
        self.minimumValue = 30
        self.maximumValue = 360
    }
    
    @IBInspectable var trackHeight: CGFloat = 3
    @IBInspectable var thumbRadius: CGFloat = 36
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(origin: bounds.origin, size: CGSize(width: bounds.width, height: trackHeight))
    }
}
