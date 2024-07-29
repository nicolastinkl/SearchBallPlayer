//
//  MutiGradientImageBgView.swift
//  SDKVideoPlayer
//
//  Created by Zeus on 2024/7/29.
//

import Foundation

import UIKit

// 扩展UIColor以支持HSLA初始化
extension UIColor {
    convenience init(hsla: (hue: Int, saturation: Int, lightness: Int, alpha: CGFloat)) {
        let hue: CGFloat = CGFloat(hsla.hue) / 360
        let saturation: CGFloat = CGFloat(hsla.saturation) / 100
        let lightness: CGFloat = CGFloat(hsla.lightness) / 100
        let alpha: CGFloat = hsla.alpha
        
        self.init(hue: hue, saturation: saturation, brightness: lightness, alpha: alpha)
    }
}
class MutiGradientImageBgView : UIView {

    var cornerRadius2: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
  
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradientLayer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradientLayer()
    }
    
    private func setupGradientLayer() {
           let gradients: [(center: CGPoint, color: UIColor)] = [
               (CGPoint(x: 0.09, y: 0.10), UIColor(hsla: (324, 45, 24, 1))),
               (CGPoint(x: 0.70, y: 0.89), UIColor(hsla: (246, 33, 26, 1))),
               (CGPoint(x: 0.91, y: 0.11), UIColor(hsla: (348, 89, 57, 1))),
               (CGPoint(x: 0.12, y: 0.86), UIColor(hsla: (201, 97, 53, 1)))
           ]
           
           for (center, color) in gradients {
               let gradientLayer = CAGradientLayer()
               gradientLayer.frame = self.bounds
               gradientLayer.colors = [color.cgColor, UIColor.clear.cgColor]
               gradientLayer.startPoint = center
               gradientLayer.endPoint = CGPoint(x: 1 - center.x, y: 1 - center.y)
               gradientLayer.locations = [0.0, 0.5]
               
               self.layer.addSublayer(gradientLayer)
           }
       }
    
    private func setupGradientLayer2() {
            // 创建多个径向渐变层
            let gradients: [(UIColor, CGPoint, CGPoint)] = [
                (UIColor(hsla: (348, 91, 61, 1)), CGPoint(x: 0.86, y: 0.03), CGPoint(x: 0.14, y: 0.97)),
                (UIColor(hsla: (246, 33, 26, 1)), CGPoint(x: 0.0, y: 0.99), CGPoint(x: 1.0, y: 0.01)),
                (UIColor(hsla: (201, 97, 53, 1)), CGPoint(x: 0.0, y: 0.01), CGPoint(x: 1.0, y: 0.99)),
                (UIColor(hsla: (48, 100, 48, 1)), CGPoint(x: 0.91, y: 0.98), CGPoint(x: 0.09, y: 0.02)),
                (UIColor(hsla: (12, 60, 47, 1)), CGPoint(x: 0.88, y: 0.55), CGPoint(x: 0.12, y: 0.45))
            ]
            
            for (color, startPoint, endPoint) in gradients {
                let gradientLayer = CAGradientLayer()
                gradientLayer.frame = self.bounds
                gradientLayer.colors = [color.cgColor, UIColor.clear.cgColor]
                gradientLayer.startPoint = startPoint
                gradientLayer.endPoint = endPoint
                gradientLayer.locations = [0.0, 0.5]
                
                self.layer.addSublayer(gradientLayer)
            }
        }
    
    private func setupGradientBackground() {
        self.backgroundColor = UIColor(hue: 246.0/360.0, saturation: 0.33, brightness: 0.26, alpha: 1.0)

        let gradientLayer1 = createRadialGradientLayer(center: CGPoint(x: 0.86, y: 0.03), startColor: UIColor(hue: 348.0/360.0, saturation: 0.91, brightness: 0.61, alpha: 1.0).cgColor, endColor: UIColor.clear.cgColor)
        let gradientLayer2 = createRadialGradientLayer(center: CGPoint(x: 0.0, y: 0.99), startColor: UIColor(hue: 246.0/360.0, saturation: 0.33, brightness: 0.26, alpha: 1.0).cgColor, endColor: UIColor.clear.cgColor)
        let gradientLayer3 = createRadialGradientLayer(center: CGPoint(x: 0.0, y: 0.01), startColor: UIColor(hue: 201.0/360.0, saturation: 0.97, brightness: 0.53, alpha: 1.0).cgColor, endColor: UIColor.clear.cgColor)
        let gradientLayer4 = createRadialGradientLayer(center: CGPoint(x: 0.91, y: 0.98), startColor: UIColor(hue: 48.0/360.0, saturation: 1.0, brightness: 0.48, alpha: 1.0).cgColor, endColor: UIColor.clear.cgColor)
        let gradientLayer5 = createRadialGradientLayer(center: CGPoint(x: 0.88, y: 0.55), startColor: UIColor(hue: 12.0/360.0, saturation: 0.60, brightness: 0.47, alpha: 1.0).cgColor, endColor: UIColor.clear.cgColor)

        self.layer.addSublayer(gradientLayer1)
        self.layer.addSublayer(gradientLayer2)
        self.layer.addSublayer(gradientLayer3)
        self.layer.addSublayer(gradientLayer4)
        self.layer.addSublayer(gradientLayer5)
    }

    private func createRadialGradientLayer(center: CGPoint, startColor: CGColor, endColor: CGColor) -> CALayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.type = .radial
        gradientLayer.colors = [startColor, endColor]
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = center
        gradientLayer.endPoint = center
        gradientLayer.frame = self.bounds
        return gradientLayer
    }
 
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.sublayers?.forEach { $0.frame = self.bounds }
        self.layer.cornerRadius = self.cornerRadius2
    }
}

