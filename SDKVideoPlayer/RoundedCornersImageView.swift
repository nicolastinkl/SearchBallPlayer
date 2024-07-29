//
//  LRTopImageView.swift
//  SDKVideoPlayer
//
//  Created by Zeus on 2024/7/22.
//

import Foundation
 
import SDWebImage
import UIKit

class RoundedCornersImageView: SDAnimatedImageView {

    var cornerRadius2: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyRoundedCorners()
    }

    private func applyRoundedCorners() {
        // 创建一个路径
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: [.topLeft, .topRight],
                                cornerRadii: CGSize(width: cornerRadius2, height: cornerRadius2))

        // 创建一个形状层并设置路径
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath

        // 将形状层设置为UIImageView的mask
        layer.mask = maskLayer
    }
}
 
