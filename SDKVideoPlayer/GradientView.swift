//
//  GradientView.swift
//  SDKVideoPlayer
//
//  Created by Zeus on 2024/7/15.
//

import Foundation
import UIKit

class GradientView: UIView {
    
    // Define the colors for your gradient
//    var startColor: UIColor = .white
//    var endColor: UIColor = .black
    
    // Define the colors for your gradient
       var startColor: UIColor = .white {
           didSet {
               updateGradientColors()
           }
       }
       
       var endColor: UIColor = .black {
           didSet {
               updateGradientColors()
           }
       }
    
    let gradientLayer = CAGradientLayer()
    
    
    override init(frame: CGRect) {
         super.init(frame: frame)
         commonInit()
     }
     
     required init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
         commonInit()
     }
      
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        backgroundColor = .clear
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        backgroundColor = .clear
//    }
    
//    override func draw(_ rect: CGRect) {
//        
//        gradientLayer.frame = bounds
//        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
//        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
//        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
//        // 设置颜色的分布位置
//        gradientLayer.locations = [0.0, 0.3, 1.0] // 0.0 表示顶部开始，1.0 表示底部结束
//           
//        layer.insertSublayer(gradientLayer, at: 0)
//    }
    
        private func commonInit() {
          backgroundColor = .clear
          setupGradientLayer()
      }
      
      private func setupGradientLayer() {
          gradientLayer.frame = bounds
          gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
          gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
          gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.locations = [0.0, 0.3, 1.0] // 0.0 表示顶部开始，1.0 表示底部结束
          layer.insertSublayer(gradientLayer, at: 0)
      }
    
    override func layoutSubviews() {
          super.layoutSubviews()
          gradientLayer.frame = bounds
      }
      
      private func updateGradientColors() {
          gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
      }
}
