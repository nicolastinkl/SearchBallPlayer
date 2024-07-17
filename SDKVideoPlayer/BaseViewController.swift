//
//  BaseViewController.swift
//  SDKVideoPlayer
//
//  Created by Zeus on 2024/7/17.
//

import Foundation
import UIKit

class BaseViewController: UIViewController {
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // 检查颜色表现是否有变化
        if #available(iOS 13.0, *) ,traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection){
            
            updateTheme()
        }
    }
    
    // 这个方法可以被所有子类重写以自定义主题更新逻辑
    func updateTheme() {
        // 默认的主题更新逻辑
        print("Theme changed to: \(traitCollection.userInterfaceStyle == .dark ? "Dark" : "Light")")
        // 例如，可以在这里更新视图的背景颜色、字体颜色等
    }
}
