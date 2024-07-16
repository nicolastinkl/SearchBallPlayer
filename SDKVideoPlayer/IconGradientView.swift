//
//  IconGradientView.swift
//  SDKVideoPlayer
//
//  Created by Zeus on 2024/7/16.
//

import Foundation
import UIKit

class IconGradientView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradientLayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradientLayer()
    }
    
    private func setupGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        
        // 设置渐变颜色，从紫色到白色
        gradientLayer.colors = [
            UIColor.MainColor().cgColor,   // 左边紫色
            UIColor.white.cgColor     // 右边白色
        ]
        
        // 设置渐变方向，从左到右
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        // 添加渐变层到视图的layer上
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 确保渐变层的frame与视图的bounds一致
        (self.layer.sublayers?.first as? CAGradientLayer)?.frame = self.bounds
    }
}
