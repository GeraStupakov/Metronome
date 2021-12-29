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
        
//        let sz = CGSize(width: 60, height: 60)
//        let r = UIGraphicsImageRenderer(size: sz)
//
//        let reducedImage = r.image { _ in
//            UIImage(named: "thumb")?.draw(in:CGRect(origin:.zero, size:sz))
//        }
//
//        self.setThumbImage(reducedImage, for: .normal)
//        self.setThumbImage(reducedImage, for: .highlighted)
        
        if let thumbImage = UIImage(named: "thumb") {
            self.setThumbImage(thumbImage, for: .normal)
            self.setThumbImage(thumbImage, for: .highlighted)
        }
    }
    
    @IBInspectable var trackHeight: CGFloat = 3
    @IBInspectable var thumbRadius: CGFloat = 40
    
//    private lazy var thumbView: UIView = {
//        let thumb = UIView()
//        thumb.backgroundColor = .white //UIColor(named: "TextColor")
//        //thumb.layer.borderWidth = 0.4
//        //thumb.layer.borderColor = UIColor.darkGray.cgColor
//        return thumb
//    }()
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        let thumb = thumbImage(radius: thumbRadius)
//        setThumbImage(thumb, for: .normal)
//        setThumbImage(thumb, for: .highlighted)
//    }
//
//    private func thumbImage(radius: CGFloat) -> UIImage {
//
//        thumbView.frame = CGRect(x: 0, y: radius * 2, width: radius, height: radius)
//        thumbView.layer.cornerRadius = radius / 2
//
//        let renderer = UIGraphicsImageRenderer(bounds: thumbView.bounds)
//        return renderer.image { rendererContext in
//            thumbView.layer.render(in: rendererContext.cgContext)
//        }
//    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(origin: bounds.origin, size: CGSize(width: bounds.width, height: trackHeight))
    }

}
