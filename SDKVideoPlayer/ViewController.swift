//
//  ViewController.swift
//  SDKVideoPlayer
//
//  Created by Zeus on 2024/7/9.
//

import UIKit
import SDWebImage




//@available(iOS 14.0, *)
extension ViewController: SwiftyOnboardDataSource {

        func swiftyOnboardNumberOfPages(_ swiftyOnboard: SwiftyOnboard) -> Int {
            return 3
        }

        func swiftyOnboardPageForIndex(_ swiftyOnboard: SwiftyOnboard, index: Int) -> SwiftyOnboardPage? {
            let page = SwiftyOnboardPage()
            if index == 0 {
                
                page.title.text = "Search as you like"
                page.title.textColor = UIColor.white
//                page.title.font =  UIFont.systemFont(ofSize: 20)
                page.subTitle.text = "Whether it's classic films or current hits, you can easily find them using our search feature."
                page.subTitle.textColor = UIColor.white
                page.imageView.image = UIImage(named: "worlwide")
            } else if index == 1 {
                
                page.title.text = "Efficient browsing"
                page.title.textColor = UIColor.white
                page.subTitle.text = "Our collection includes various popular and classic films, offering a simple and clear browsing experience."
                page.subTitle.textColor = UIColor.white
                page.imageView.image = UIImage(named: "entertainment")
            } else if index == 2 {
                
                page.title.text = "Wonderful movies"
                page.title.textColor = UIColor.white
                page.subTitle.text = "Includes all kinds of popular films, bringing you an unprecedented viewing experience."
                page.subTitle.textColor = UIColor.white
                page.imageView.image = UIImage(named: "wandoerfuyll")
            }
            
            return page
        }
}


class ViewController: BaseViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var swiftyOnboard:SwiftyOnboard?
    var onboardingView: UIView = {
        let views = UIView()
        views.translatesAutoresizingMaskIntoConstraints = false
        
        return views
        
    }()
    
    private let bgImageView:UIImageView = {
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//        imageView.layer.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "football_bg")
        return imageView
        
    }()
    
    private let imageView: SDAnimatedImageView = {
        let imageView = SDAnimatedImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        activityIndicator.style = .large
//        activityIndicator.startAnimating()
        activityIndicator.isHidden = true
        self.view.backgroundColor = UIColor.black
        
        SDKAdServices().requestTrackingAuthorization()
        
        
        if  ApplicationS.isFirstLaunch()   {
               // 显示一些欢迎信息或教程
               print("This is the first launch")
                self.ShowOnboardView()
           } else {
               // 正常启动
               print("Not the first launch")
               self.setupViews()
               DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                   self.gotoMainVC()
               }
           }

    }
    
    func gotoMainVC(){
        
        guard let vchome = UIStoryboard(name: "Home", bundle: Bundle.main).instantiateInitialViewController(),
              self.isViewLoaded && self.view.window != nil else {
             return
        }
        vchome.modalPresentationStyle = .fullScreen
        self.present(vchome, animated: false)
    }
    
    func ShowOnboardView(){
        
        // init onboardingView
        swiftyOnboard = SwiftyOnboard(frame: onboardingView.frame,style: SwiftyOnboardStyle.light)
        
        if let swiftyOnboard = swiftyOnboard{
            self.view.addSubview(onboardingView)
            
            
            self.onboardingView.addSubview(bgImageView)
            self.onboardingView.addSubview(swiftyOnboard)
            
            swiftyOnboard.translatesAutoresizingMaskIntoConstraints = false
            
            swiftyOnboard.dataSource = self
            
            
            
            NSLayoutConstraint.activate([
                
                
                // 子视图顶部与父视图顶部对齐
                onboardingView.topAnchor.constraint(equalTo: view.topAnchor),
                       // 子视图底部与父视图底部对齐
                onboardingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                       // 子视图左边与父视图左边对齐
                onboardingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                       // 子视图右边与父视图右边对齐
                onboardingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            
                // 子视图顶部与父视图顶部对齐
                swiftyOnboard.topAnchor.constraint(equalTo: onboardingView.topAnchor),
                       // 子视图底部与父视图底部对齐
                swiftyOnboard.bottomAnchor.constraint(equalTo: onboardingView.bottomAnchor),
                       // 子视图左边与父视图左边对齐
                swiftyOnboard.leadingAnchor.constraint(equalTo: onboardingView.leadingAnchor),
                       // 子视图右边与父视图右边对齐
                swiftyOnboard.trailingAnchor.constraint(equalTo: onboardingView.trailingAnchor),
                
                
                // 子视图顶部与父视图顶部对齐
                bgImageView.topAnchor.constraint(equalTo: onboardingView.topAnchor),
                       // 子视图底部与父视图底部对齐
                bgImageView.bottomAnchor.constraint(equalTo: onboardingView.bottomAnchor),
                       // 子视图左边与父视图左边对齐
                bgImageView.leadingAnchor.constraint(equalTo: onboardingView.leadingAnchor),
                       // 子视图右边与父视图右边对齐
                bgImageView.trailingAnchor.constraint(equalTo: onboardingView.trailingAnchor)
                
                    
              ])
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                swiftyOnboard.overlay?.skipButton.addTarget(self, action: #selector(self.btnClickskipButton(_:)), for: .touchUpInside)
                
                swiftyOnboard.overlay?.continueButton.addTarget(self, action: #selector(self.btnClickcontinueButton(_:)), for: .touchUpInside)
            }
        }
        
    }
    
    @objc func btnClickskipButton(_ sender:UIButton) {
        hideViewWithAnimation(myView: self.onboardingView)
        
    }
    
    func hideViewWithAnimation(myView: UIView) {
       // 淡出动画
       UIView.animate(withDuration: 0.5, animations: {
            myView.alpha = 0
           
           self.setupViews()
       }) { _ in
           // 动画完成后，可以在这里做一些清理工作
           // 例如，你可以在这里将视图从父视图中移除
            myView.removeFromSuperview()
           self.gotoMainVC()
       }
   }
    
    
    @objc func btnClickcontinueButton(_ sender:UIButton) {
        if let swiftyOnboard = swiftyOnboard{
            if swiftyOnboard.currentPage < (3-1) {
                swiftyOnboard.goToPage(index: swiftyOnboard.currentPage+1 , animated:true)
            }else{
                hideViewWithAnimation(myView: self.onboardingView)
            }
        }
    }
    
    private func setupViews() {
         
        imageView.translatesAutoresizingMaskIntoConstraints = false
     
        self.view.addSubview(imageView)
        imageView.image = UIImage(named: "AppIcon")
        NSLayoutConstraint.activate([
            
            
            imageView.centerXAnchor.constraint(equalTo:self.view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo:self.view.centerYAnchor),
            
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            
            
        ])
    }
    


}

