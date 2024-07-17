//
//  Utitils.swift
//  SDKVideoPlayer
//
//  Created by abc123456 on 2024/7/10.
//

import Foundation
import UIKit


// 定义一个错误处理的枚举类型
enum SearchError: Error {
    case networkError
    case notFound
    case unknown
    case errorWith(String) // 存储输入错误的具体信息
    // 更新 LocalizedError 以处理新的输入错误情况
       var errorDescription: String? {
           switch self {
           case .networkError:
               return "Network error occurred. Please check your connection and try again."
           case .notFound:
               return "No results found. Please try a different query."
           case .unknown:
               return "An unknown error occurred. Please try again later."
           case .errorWith(let input):
               return "Invalid input error: '\(input)' is not a valid input."
           }
       }
}

 

extension UIViewController{
    
    // 创建一个函数来显示搜索错误弹窗
    func showSearchErrorAlert(on viewController: UIViewController, error: String) {
        // 根据错误类型创建UIAlertController
        let alertController = UIAlertController(title: "搜索失败", message: error, preferredStyle: .alert)
        
        // 添加一个'OK'按钮，用于关闭弹窗
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // 确保在主线程中呈现弹窗
        DispatchQueue.main.async {
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
}


extension Notification.Name {
    static let historyItemsUpdated = Notification.Name("RecentlyWatchVideoItemsUpdated")
}


class LocalStore{
    static    func saveToUserDefaults(RecentlyWatchVideo: Video) {
        
        
        //Array Object/
       /*  if var savedHistoryItems = UserDefaults.standard.array(forKey: "Recently_watched_history") {
            savedHistoryItems.insert(RecentlyWatchVideo, at: 0)
            UserDefaults.standard.setValue(savedHistoryItems, forKey: "Recently_watched_HHistory")
        }else{
            UserDefaults.standard.setValue([RecentlyWatchVideo], forKey: "Recently_watched_HHistory")
        } */
        
        
        
        //JSONArray Object/
      let encoder = JSONEncoder()
          
        if let savedHistoryItems = UserDefaults.standard.data(forKey: "Recently_watched_history") {
            let decoder = JSONDecoder()
            if var loadedHistoryItems = try? decoder.decode([Video].self, from: savedHistoryItems) {
                loadedHistoryItems.insert(RecentlyWatchVideo, at: 0)
                
                if let encoded = try? encoder.encode(loadedHistoryItems) {
                    UserDefaults.standard.set(encoded, forKey: "Recently_watched_history")
                }                
            }
        }else{
            let arraryVideo:[Video] = [RecentlyWatchVideo]
            if let encoded = try? encoder.encode(arraryVideo) {
                UserDefaults.standard.set(encoded, forKey: "Recently_watched_history")
            }
        }
         
    }
    
    static  func getFromUserDefaults()->[Video]? {
        
        //Array Object/
        /* if let savedHistoryItems = UserDefaults.standard.array(forKey: "Recently_watched_HHistory") {
              return savedHistoryItems as? [Video]
        }
        
        return nil */
        

        //JSONArray Object/
        if let savedHistoryItems = UserDefaults.standard.data(forKey: "Recently_watched_history") {
            let decoder = JSONDecoder()
            if let loadedHistoryItems = try? decoder.decode([Video].self, from: savedHistoryItems) {
                return loadedHistoryItems
            }
        }
        return nil
        
        
    }
    
    
}

extension UIColor {
    static func MainColor() -> UIColor{
        return UIColor.systemPurple
//     return UIColor(fromHex: "#9c45ac")
    }
        
        /// Initialises UIColor from a hexadecimal string. Color is clear if string is invalid.
        /// - Parameter fromHex: supported formats are "#RGB", "#RGBA", "#RRGGBB", "#RRGGBBAA", with or without the # character
        public convenience init(fromHex:String) {
            var r = 0, g = 0, b = 0, a = 255
            let offset = fromHex.hasPrefix("#") ? 1 : 0
            let ch = fromHex.map{$0}
            switch(ch.count - offset) {
            case 8:
                a = 16 * (ch[offset+6].hexDigitValue ?? 0) + (ch[offset+7].hexDigitValue ?? 0)
                fallthrough
            case 6:
                r = 16 * (ch[offset+0].hexDigitValue ?? 0) + (ch[offset+1].hexDigitValue ?? 0)
                g = 16 * (ch[offset+2].hexDigitValue ?? 0) + (ch[offset+3].hexDigitValue ?? 0)
                b = 16 * (ch[offset+4].hexDigitValue ?? 0) + (ch[offset+5].hexDigitValue ?? 0)
                break
            case 4:
                a = 16 * (ch[offset+3].hexDigitValue ?? 0) + (ch[offset+3].hexDigitValue ?? 0)
                fallthrough
            case 3:  // Three digit #0D3 is the same as six digit #00DD33
                r = 16 * (ch[offset+0].hexDigitValue ?? 0) + (ch[offset+0].hexDigitValue ?? 0)
                g = 16 * (ch[offset+1].hexDigitValue ?? 0) + (ch[offset+1].hexDigitValue ?? 0)
                b = 16 * (ch[offset+2].hexDigitValue ?? 0) + (ch[offset+2].hexDigitValue ?? 0)
                break
            default:
                a = 0
                break
            }
            self.init(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: CGFloat(a)/255)
            
        }
}
    // Author: Andrew Kingdom


private var clickBlockKey: UInt8 = 10
private var errorViewKey: UInt8 = 11
private var isShowingErrorViewKey: UInt8 = 12

extension UIViewController {
    
    private var privateClickBlock: (() -> Void)? {
         get {
             return objc_getAssociatedObject(self, &clickBlockKey) as? (() -> Void)
         }
         set {
             objc_setAssociatedObject(self, &clickBlockKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
         }
     }
    
    private var errorView: UIView? {
         get {
             return objc_getAssociatedObject(self, &errorViewKey) as? UIView
         }
         set {
             objc_setAssociatedObject(self, &errorViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
         }
     }
    
    private var isShowingErrorView: Bool {
          get {
              return objc_getAssociatedObject(self, &isShowingErrorViewKey) as? Bool ?? false
          }
          set {
              objc_setAssociatedObject(self, &isShowingErrorViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
          }
      }
    
     
    func showNetworkErrorView(errormsg: String,clickBlock: @escaping () -> Void) {
        
        self.privateClickBlock = clickBlock
          // 创建背景视图
    
        guard !isShowingErrorView else { return }
               self.isShowingErrorView = true
        // 创建背景视图
       let errorView = UIView()
       view.addSubview(errorView)
        errorView.backgroundColor = ThemeManager.shared.viewBackgroundColor
        errorView.translatesAutoresizingMaskIntoConstraints = false
        
       self.errorView = errorView

        errorView.backgroundColor = ThemeManager.shared.viewBackgroundColor
        errorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorView)
        
        // 添加约束以确保 errorView 填充整个视图
        NSLayoutConstraint.activate([
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 创建并添加图像视图
        let imageView = UIImageView()
        imageView.image = UIImage(named: "disconnect") // 请将图片资源添加到项目中
        imageView.translatesAutoresizingMaskIntoConstraints = false
        errorView.addSubview(imageView)
        
        // 创建并添加标题标签
        let titleLabel = UILabel()
        titleLabel.text = "数据异常"
        titleLabel.textColor = ThemeManager.shared.fontColor
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        errorView.addSubview(titleLabel)
        
        // 创建并添加描述标签
        let descriptionLabel = UILabel()
        descriptionLabel.text = errormsg
        descriptionLabel.textColor = ThemeManager.shared.fontColor2
        descriptionLabel.font = UIFont.systemFont(ofSize: 15)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        errorView.addSubview(descriptionLabel)
        
        // 创建并添加重试按钮
        let retryButton = UIButton(type: .system)
        retryButton.setTitle("重试", for: .normal)
        retryButton.setTitleColor(UIColor.MainColor(), for: .normal)
        retryButton.backgroundColor = ThemeManager.shared.fontColor.withAlphaComponent(0.1) // UIColor(white: 1.0, alpha: 0.1)
        retryButton.layer.cornerRadius = 20
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        errorView.addSubview(retryButton)
        
        // 添加约束
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: errorView.centerYAnchor, constant: -100),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.trailingAnchor.constraint(equalTo: errorView.trailingAnchor,constant: -30),
            descriptionLabel.leadingAnchor.constraint(equalTo: errorView.leadingAnchor,constant: 30),
            descriptionLabel.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            
            retryButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            retryButton.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            retryButton.widthAnchor.constraint(equalToConstant: 100),
            retryButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
          
      }
      
      @objc func retryButtonTapped() {
          // 在这里处理重试按钮的点击事件
          errorView?.removeFromSuperview()
          isShowingErrorView = false

          privateClickBlock?()
          // 执行网络请求重试操作或其他逻辑
      }
}
