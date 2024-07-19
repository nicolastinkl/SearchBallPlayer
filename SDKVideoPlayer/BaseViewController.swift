//
//  BaseViewController.swift
//  SDKVideoPlayer
//
//  Created by Zeus on 2024/7/17.
//

import Foundation
import UIKit

class BaseViewController: UIViewController {
    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//        
//        // 检查颜色表现是否有变化
//        if #available(iOS 13.0, *) ,traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection){
//            
//            updateTheme()
//        }
//    }
//    
//    override func viewDidLoad() {
//          super.viewDidLoad()
//          
//          // 监听主题变更通知
//          NotificationCenter.default.addObserver(self, selector: #selector(handleThemeChanged), name: .themeChanged, object: nil)
//          
//          // 应用当前主题
//          applyTheme()
//      }
//    
//    deinit {
//           // 移除通知监听
//           NotificationCenter.default.removeObserver(self, name: .themeChanged, object: nil)
//       }
//       
//    @objc private func handleThemeChanged() {
//          // 当接收到主题变更通知时，更新界面
//          applyTheme()
//      }
//      
//      func applyTheme() {
//          let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
//          
//          if isDarkMode {
//              view.backgroundColor = .black
//              navigationController?.navigationBar.barTintColor = .black
//              navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
//          } else {
//              view.backgroundColor = .white
//              navigationController?.navigationBar.barTintColor = .white
//              navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
//          }
//      }
//    
//    // 这个方法可以被所有子类重写以自定义主题更新逻辑
//    func updateTheme() {
//        // 默认的主题更新逻辑
//        print("Theme changed to: \(traitCollection.userInterfaceStyle == .dark ? "Dark" : "Light")")
//        // 例如，可以在这里更新视图的背景颜色、字体颜色等
//    }
}
