//
//  DetailViewController.swift
//  Demo
//
//  Created by kintan on 2018/4/15.
//  Copyright © 2018年 kintan. All rights reserved.
//

import CoreServices
import KSPlayer
import UIKit

protocol DetailProtocol: UIViewController {
    var resource: KSPlayerResource? { get set }
}

class DetailViewController: BaseViewController, DetailProtocol {
    #if os(iOS)
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override var prefersStatusBarHidden: Bool {
        !playerView.isMaskShow
    }

    private let playerView = IOSVideoPlayerView()
    #elseif os(tvOS)
    private let playerView = VideoPlayerView()
    #else
    private let playerView = CustomVideoPlayerView()
    #endif
    var resource: KSPlayerResource? {
        didSet {
            if let resource {
                playerView.set(resource: resource)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        view.addSubview(playerView)
        
        playerView.delegate = self
        playerView.translatesAutoresizingMaskIntoConstraints = false
        #if os(iOS)
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: view.readableContentGuide.topAnchor),
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        #else
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: view.topAnchor),
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        #endif
        view.layoutIfNeeded()
        playerView.backBlock = { [unowned self] in
            #if os(iOS)
            if UIApplication.shared.statusBarOrientation.isLandscape {
                view.backgroundColor = UIColor.black
                playerView.updateUI(isLandscape: false)
            } else {
                navigationController?.popViewController(animated: true)
                self.dismiss(animated: false)
            }
            #else
                navigationController?.popViewController(animated: true)
                self.dismiss(animated: false)
            #endif
        }
        playerView.becomeFirstResponder()
//        SwiftLoader.show(view: self.view , title: "正在缓冲...", animated: true)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIDevice.current.userInterfaceIdiom == .phone {
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension DetailViewController: PlayerControllerDelegate {
    func playerController(seek _: TimeInterval) {
        
    }

    func playerController(state states: KSPlayerState) {
        if states == .readyToPlay {
            
          //  SwiftLoader.hide()
            
            
        }else if states ==  .error {
            
          //  SwiftLoader.hide()
            self.showSearchErrorAlert(on: self, error: "请求视频出错，请重试", title: "提示")            
            
        }
        print(">>>>>>>>>>state: \(states.description)")
    }

    func playerController(currentTime _: TimeInterval, totalTime _: TimeInterval) {
        
    }

    func playerController(finish error: Error?) {
        print(">>>>>>>>>> finish \(String(describing: error?.localizedDescription))")
    }

    func playerController(maskShow _: Bool) {
        print(">>>>>>>>>>maskShow")
        #if os(iOS)
        setNeedsStatusBarAppearanceUpdate()
        #endif
    }

    func playerController(action _: PlayerButtonType) {
        print(">>>>>>>>>>action")
        
    }

    func playerController(bufferedCount _: Int, consumeTime _: TimeInterval) {
        print(">>>>>>>>>>bufferedCount")
    }
}
