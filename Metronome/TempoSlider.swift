//
//  TempoSlider.swift
//  Metronome
//
//  Created by Георгий Ступаков on 4/2/21.
//

import UIKit
import Foundation

class TempoSlider: UISlider {
    
    @IBInspectable var trackHeight: CGFloat = 1.6
    
    var bigImage = UIImageView()
    var indicatorSize: CGSize? = nil
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(origin: bounds.origin, size: CGSize(width: bounds.width, height: trackHeight))
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let imageTrackSmall = UIImage.circleSlider(diametr: 10, color: .white)
        self.setThumbImage(imageTrackSmall, for: .normal)
        //Назначает изображение нажатия на слайдер с указанным состояниям элемента управления.
        let imageTrackBig = UIImage.circleSlider(diametr: 20, color: .white)
        bigImage.contentMode = .scaleAspectFill
        bigImage.clipsToBounds = false //Логическое значение, определяющее, ограничены ли вложенные представления пределами представления
        bigImage.image = imageTrackBig
        
        self.addSubview(bigImage)
        self.bringSubviewToFront(bigImage)
    }
    
    //метод UISlider, который считает размеры для изображения индикатора позиции
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        
        let unadjustedThumbRect = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
        
        let origin = unadjustedThumbRect.origin //точка, указывающая координаты начала прямоугольника.
        let size = unadjustedThumbRect.size
        
        if indicatorSize == nil && unadjustedThumbRect.size.width > 0 {
            bigImage.frame = unadjustedThumbRect
            indicatorSize = size
        }
        
        let bigImageSize = bigImage.frame.size
        
        bigImage.frame.origin = CGPoint(
            x: origin.x - (bigImageSize.width/2 - size.width/2),
            y: origin.y - (bigImageSize.height/2 - size.height/2)
        )
        
        self.bringSubviewToFront(bigImage)
        
        return unadjustedThumbRect
    }

    override var isHighlighted: Bool {
        didSet {
            // avoid situation when indicator size didn't count yet
            guard indicatorSize != nil else { return }
            
            UIView.animate(withDuration: 0.3) {
                if self.isHighlighted == true {
                    self.bigImage.transform = CGAffineTransform(scaleX: 2, y: 2)
                } else {
                    self.bigImage.transform = CGAffineTransform(scaleX: 1, y: 1)
                }
            }
        }
    }
    
}

extension UIImage {
    
    class func circleSlider(diametr: CGFloat, color: UIColor) -> UIImage {
        
        //Создает графический контекст на основе растрового изображения с указанными параметрами.
        UIGraphicsBeginImageContextWithOptions(CGSize(width: diametr, height: diametr), false, 0)
        
        let imageContext = UIGraphicsGetCurrentContext() //инициализируем обект контекста
        imageContext!.saveGState() //сохраняем состояние контекста
        
        let rect = CGRect(x: 0, y: 0, width: diametr, height: diametr) // создаем прямоуголник
        imageContext!.setFillColor(color.cgColor) //Устанавливает текущий цвет заливки в графическом контексте с помощью CGColor
        imageContext!.fillEllipse(in: rect) //добавялем прямоугольник в контекст и преобразуем в круг используя цвет заливки
        
        imageContext!.restoreGState()
        //Устанавливает текущее состояние графики в последнее сохраненное состояние
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        //Возвращает изображение из содержимого текущего графического контекста на основе растрового изображения
        
        UIGraphicsEndImageContext()
        //Удаляет текущий контекст графики на основе растрового изображения из вершины стека
        
        return image!
    }

}
