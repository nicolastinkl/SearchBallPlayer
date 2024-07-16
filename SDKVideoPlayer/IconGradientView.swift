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



class ShadowButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        applyShadow()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyShadow()
    }
    
    private func applyShadow() {
        // 设置圆角为按钮宽度的一半，以保持圆形
        self.layer.cornerRadius = self.frame.size.width / 2
        
        // 设置阴影颜色
        self.layer.shadowColor = UIColor.black.cgColor
        
        // 设置阴影偏移量
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        // 设置阴影透明度
        self.layer.shadowOpacity = 0.9
        
        // 设置阴影半径，影响阴影的模糊程度
        self.layer.shadowRadius = 18
        
        // 确保阴影始终显示在按钮后面
        self.layer.masksToBounds = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 确保按钮的圆角是当前宽度的一半
        self.layer.cornerRadius = self.frame.size.width / 2
    }
}

