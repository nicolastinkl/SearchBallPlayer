//
//  Utitils.swift
//  SDKVideoPlayer
//
//  Created by abc123456 on 2024/7/10.
//

import Foundation
import UIKit
extension UIColor {
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
    
     
    func showNetworkErrorView( errormsg: String,clickBlock: @escaping () -> Void) {
        self.privateClickBlock = clickBlock
          // 创建背景视图
        
        // 创建背景视图
       let errorView = UIView()
       errorView.backgroundColor = UIColor.black
       errorView.translatesAutoresizingMaskIntoConstraints = false
       view.addSubview(errorView)
       self.errorView = errorView
 
            errorView.backgroundColor = UIColor.black
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
            titleLabel.textColor = .white
            titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            errorView.addSubview(titleLabel)
            
            // 创建并添加描述标签
            let descriptionLabel = UILabel()
            descriptionLabel.text = errormsg
            descriptionLabel.textColor = .lightGray
            descriptionLabel.font = UIFont.systemFont(ofSize: 15)
            descriptionLabel.numberOfLines = 0
            descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            errorView.addSubview(descriptionLabel)
            
            // 创建并添加重试按钮
            let retryButton = UIButton(type: .system)
            retryButton.setTitle("重试", for: .normal)
            retryButton.setTitleColor(.red, for: .normal)
            retryButton.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
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
          privateClickBlock?()
          // 执行网络请求重试操作或其他逻辑
      }
}
