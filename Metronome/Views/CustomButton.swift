//
//  CustomButton.swift
//  Metronome
//
//  Created by Георгий Ступаков on 6/1/21.
//

import UIKit

class CustomButton: UIButton {
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {

        super.endTracking(touch, with: event)
        
        UIView.animateKeyframes(withDuration: 0.5,
                                delay: 0.0,
                                options: [.beginFromCurrentState, .allowUserInteraction]) {
            self.backgroundColor = self.backgroundColor?.withAlphaComponent(self.isHighlighted ? 0.3 : 1)
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
}
