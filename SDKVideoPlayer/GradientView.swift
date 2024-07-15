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
    var startColor: UIColor = .white
    var endColor: UIColor = .black
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        // 设置颜色的分布位置
        gradientLayer.locations = [0.0, 0.3, 1.0] // 0.0 表示顶部开始，1.0 表示底部结束
           
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
