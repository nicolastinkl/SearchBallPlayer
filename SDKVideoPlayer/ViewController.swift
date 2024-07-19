//
//  ViewController.swift
//  SDKVideoPlayer
//
//  Created by Zeus on 2024/7/9.
//

import UIKit
import SDWebImage

class ViewController: BaseViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
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
        
        setupViews();
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
          
            
            guard let vchome = UIStoryboard(name: "Home", bundle: Bundle.main).instantiateInitialViewController(),
                  self.isViewLoaded && self.view.window != nil else {
                 return
            }
            vchome.modalPresentationStyle = .fullScreen
            self.present(vchome, animated: false)
            
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

