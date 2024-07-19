//
//  ThemeManager.swift
//  SDKVideoPlayer
//
//  Created by Zeus on 2024/7/17.
//

import Foundation
import UIKit

class ThemeManager {
    
    static let shared = ThemeManager()
    
    private init() {}
    
    // 获取当前的用户界面样式
    var currentUserInterfaceStyle: UIUserInterfaceStyle {
        return UITraitCollection.current.userInterfaceStyle
    }
    
    // 根据用户界面样式返回不同的字体颜色
    var fontColor: UIColor {
        
//        if UserDefaults.standard.bool(forKey: "isDarkMode") {
//            return UIColor.white
//        }else{
//            return UIColor.black
//        }
        
        switch currentUserInterfaceStyle {
        case .dark:
            return UIColor.white
        case .light:
            return UIColor.black
        default:
            return UIColor.black
        }
    }
    
    var fontColor2: UIColor {
        
//        if UserDefaults.standard.bool(forKey: "isDarkMode") {
//            return UIColor.white
//        }else{
//            return UIColor.black.withAlphaComponent(0.5)
//        }
//        
        
        switch currentUserInterfaceStyle {
        case .dark:
            return UIColor.white
        case .light:
            return UIColor.black.withAlphaComponent(0.5)
        default:
            return UIColor.black.withAlphaComponent(0.5)
        }
    }
    
    
    // 根据用户界面样式返回不同的视图背景颜色
    var viewBackgroundColor: UIColor {
        
//        if UserDefaults.standard.bool(forKey: "isDarkMode") {
//            return UIColor.black
//        }else{
//            return UIColor.white
//        }
        
        
        switch currentUserInterfaceStyle {
        case .dark:
            return UIColor.black
        case .light:
            return UIColor.white
        default:
            return UIColor.white
        }
    }
}
