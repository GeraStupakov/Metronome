//
//  CustomButton.swift
//  Metronome
//
//  Created by Георгий Ступаков on 6/1/21.
//

import UIKit
import AudioToolbox

class CustomButton: UIButton {
    
    var color: UIColor = .clear

    override func endTracking(_ touch: UITouch?,
                              with event: UIEvent?) {

        super .endTracking(touch, with: event)

//        UIView.animateKeyframes(withDuration: 0.6,
//                                delay: 0.0,
//                                options: [.beginFromCurrentState,
//                                          .allowUserInteraction],
//                                animations: {
//                                    self.backgroundColor = self.color.withAlphaComponent(self.isHighlighted ? 0.3 : 1)
//        })
        
        UIView.animateKeyframes(withDuration: 0.5, delay: 0.0, options: [.beginFromCurrentState, .allowUserInteraction]) {
            self.backgroundColor = self.backgroundColor?.withAlphaComponent(self.isHighlighted ? 0.3 : 1)
        } completion: { (true) in
            AudioServicesPlaySystemSound(1519)
        }

    }
}
