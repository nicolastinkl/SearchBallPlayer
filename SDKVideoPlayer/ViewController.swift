//
//  ViewController.swift
//  SDKVideoPlayer
//
//  Created by Zeus on 2024/7/9.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.style = .large
        activityIndicator.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          
            
            guard let vchome = UIStoryboard(name: "Home", bundle: Bundle.main).instantiateInitialViewController(),
                  self.isViewLoaded && self.view.window != nil else {
                 return
            }
            vchome.modalPresentationStyle = .fullScreen
            self.present(vchome, animated: false)
            
        }

    }


}

