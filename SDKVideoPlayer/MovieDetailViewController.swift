//
//  VideoDetailViewController.swift
//  SDKVideoPlayer
//
//  Created by Zeus on 2024/7/11.
//

import Foundation
import UIKit
import Alamofire
import SDWebImage
import SwiftIcons
import SwiftfulLoadingIndicators
//import SwiftLoader
import KSPlayer

class MovieDetailViewController: UIViewController {
    
    var movieDetail: Video?
    
    private let posterImageView: SDAnimatedImageView = {
        let imageView = SDAnimatedImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
           
           // 创建渐变层
           let gradientLayer = CAGradientLayer()
           gradientLayer.colors = [
               UIColor.clear.cgColor, // 顶部透明
//               UIColor(fromHex: "#9244a5").cgColor
               UIColor.black.withAlphaComponent(0.5).cgColor  // 底部黑色
           ]
           gradientLayer.locations = [0.0, 0.95] // 渐变在图片高度的一半开始
           gradientLayer.frame = imageView.bounds
           
           // 将渐变层添加到图片视图
           imageView.layer.insertSublayer(gradientLayer, at: 0)
           
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let remarksLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let playButton:UIButton = {
        
        let playButton = UIButton(type: .custom)
        
        playButton.tintColor = UIColor.white
        playButton.setImage(UIImage(named: "Play"), for: UIControl.State.normal)
//          playButton.layer.cornerRadius = 25
          playButton.translatesAutoresizingMaskIntoConstraints = false
          return playButton
    }()
    let scrollView = UIScrollView()
    let contentView = UIView()
    var hdplayurl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        
        setupScrollView()
        setupPosterImageView()
        setupNameLabel()
        setupSummaryLabel()
        setupRemarksLabel()
        setupPlayButton()
        
        // 使用提供的JSON数据填充界面
        guard let movieDetail = movieDetail else { return }
        loadMovieDetail(movieDetail)
        
        
        //generation back button
        setupNavigationBar()
          
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    private func setupNavigationBar() {
        // 创建一个UIButton作为返回按钮
        let backButton = ShadowButton(type: .custom)
        
        // 设置按钮的图片（假设你有一个名为"back_arrow"的图片）
        backButton.setImage(UIImage(named: "back"), for: .normal)
        
        // 设置按钮的颜色
//        backButton.tintColor = UIColor.white
        
        // 添加点击事件
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit

        // 设置按钮的尺寸
//        backButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        // 禁用自动约束
        backButton.translatesAutoresizingMaskIntoConstraints = false
         
        // 添加按钮到主视图
        scrollView.addSubview(backButton)

        // 设置按钮的约束
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: -10),
            backButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44) // 根据图片实际比例调整
        ])
        
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIView())
        
//        self.navigationController?.navigationItem.setLeftBarButton(UIBarButtonItem(customView: backButton), animated: true)
    }
    
    @objc private func backButtonTapped() {
        // 执行返回操作
        
        navigationController?.popViewController(animated: true)
    }
    
    
    
    private func setupScrollView() {
          scrollView.translatesAutoresizingMaskIntoConstraints = false
          contentView.translatesAutoresizingMaskIntoConstraints = false
          view.addSubview(scrollView)
          scrollView.addSubview(contentView)
          
          NSLayoutConstraint.activate([
              scrollView.topAnchor.constraint(equalTo: view.topAnchor),
              scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
              scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
              scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
              
              contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
              contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
              contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
              contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
              contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
              
              // 关键部分：设置contentView的高度，使其大于scrollView的高度，以实现滚动
              //contentView.heightAnchor.constraint(equalToConstant: 1200)
          ])
      }
    
    
      
    
    private func setupPosterImageView() {
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(posterImageView)
        
        // 约束：顶部对齐刘海屏，宽度占满屏幕，高度根据图片比例设置
          NSLayoutConstraint.activate([
              posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor,constant: -100),
              posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
              posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//              posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: 16/9) // 根据图片实际比例调整
            posterImageView.heightAnchor.constraint(equalToConstant: 400)
          ])
          
          // 更新渐变层的位置，确保它适应刘海屏
          posterImageView.layoutIfNeeded()
          let gradientLayer = posterImageView.layer.sublayers?.first as? CAGradientLayer
          gradientLayer?.frame = CGRect(x: 0, y: 0, width: posterImageView.bounds.width, height: posterImageView.bounds.height)

    
    }
    
    private func setupPlayButton(){
//        contentView.addSubview(playButton)
//        
//        NSLayoutConstraint.activate([
//            playButton.centerXAnchor.constraint(equalTo: posterImageView.centerXAnchor),
//            playButton.centerYAnchor.constraint(equalTo: posterImageView.centerYAnchor,constant: 10),
//            playButton.widthAnchor.constraint(equalToConstant: 100),
//            playButton.heightAnchor.constraint(equalToConstant: 100)
//        ])
        
        
    }
    
    private func setupNameLabel() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupSummaryLabel() {
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(summaryLabel)
        
        NSLayoutConstraint.activate([
            summaryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            summaryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            summaryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupRemarksLabel() {
        remarksLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(remarksLabel)
        
        NSLayoutConstraint.activate([
            remarksLabel.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 20),
            remarksLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            remarksLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    var jishuArray :[String] = [String]()
    var jishuURLArray :[String] = [String]()
    private func loadMovieDetail(_ movie: Video) {
        // 从URL加载图片
        if let imageUrl = URL(string: movie.vodPic) {
            self.posterImageView.sd_setImage(with: imageUrl, placeholderImage:  UIImage(named: "placeholder-image"), context: nil)
        }
        nameLabel.text = movie.vodName
        summaryLabel.text = movie.vodBlurb + movie.vodContent
        remarksLabel.text = movie.vodRemarks + " " + movie.vodLang  + " " + movie.vodYear
        let movies = movie.vodPlayURL as NSString
        var newMovices = movies.replacingOccurrences(of: ".m3u8#", with: ".m3u8\n")
        newMovices = newMovices.replacingOccurrences(of: "$https", with: "\nhttps")
      
        var index = 1
        newMovices.components(separatedBy: "\n").forEach { str in
            //print("\n" + str)
            
            if(str.count > 10){
                let newStr =  str as NSString
                if  newStr.contains(".m3u8"){
                    
                    jishuURLArray.append(newStr as String)
                    jishuArray.append("\(index)")
                    index  = index + 1
                }
                
            }

            
        }
        print("总条数：\(jishuURLArray.count)" )
         
        if jishuURLArray.count > 1 {
            setupButtons()
        }else{
            //只有一个播放列表时
            if let playlistOne  = jishuURLArray.first as? NSString {
                
                if let url = playlistOne.components(separatedBy: ".m3u8").first {
                    
                    
                    let button = UIButton(type: .custom)
                    button.setTitle("\(movie.vodRemarks)", for: .normal)
                    button.setTitleColor(UIColor.black, for: UIControl.State.normal)
                    button.setTitleColor(UIColor.orange, for: UIControl.State.selected)
                    button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                    
                    button.backgroundColor = UIColor(fromHex: "#eeeef0")
                    button.layer.cornerRadius = 5
                    button.clipsToBounds = true

                    button.tag = index
                    button.addTarget(self, action: #selector(ButtonhdplayurlTapped(_:)), for: .touchUpInside)
                    
                    
                    contentView.addSubview(button)
                    button.translatesAutoresizingMaskIntoConstraints = false
                      
                    let buttonSize: CGFloat = 44
                      NSLayoutConstraint.activate([
                          button.heightAnchor.constraint(equalToConstant: buttonSize),
                          button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant:  50),
                          button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant:  -50),
                          button.topAnchor.constraint(equalTo: remarksLabel.topAnchor, constant: 35 )
                      ])
                    
                    
                    jishuURLArray.removeAll()
                    jishuURLArray.append(url+".m3u8")
                    hdplayurl = url+".m3u8"
                    NSLayoutConstraint.activate([
                    
                          contentView.heightAnchor.constraint(equalToConstant:1200)
                      
                    ])
                }
            }
        }
//        print(movie)
//        print(jishuURLArray)
        
    }
    
 
    func setupButtons() {
        
//        let buttonSize: CGFloat = 40.0
        let numberOfColumns: Int = 6
        
        let numberOfRows =   jishuArray.count/numberOfColumns+1
        let spacing: CGFloat = 10
        let buttonSize: CGFloat = (self.view.frame.width - spacing*7) / 6
        for row in 0..<numberOfRows { //  6 rows of buttons, adjust as needed

            for col in 0..<numberOfColumns {
                   let index = row * numberOfColumns + col
                   if index < jishuArray.count {
                       let button = UIButton(type: .custom)
                       button.setTitle(jishuArray[index], for: .normal)
                       button.setTitleColor(UIColor.black, for: UIControl.State.normal)
                       button.setTitleColor(UIColor.orange, for: UIControl.State.selected)
                       button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
                       
                       button.backgroundColor = UIColor(fromHex: "#eeeef0")
                       button.layer.cornerRadius = 5
                       button.clipsToBounds = true

                       button.tag = index
                       button.addTarget(self, action: #selector(ButtonTapped(_:)), for: .touchUpInside)
                       
                       
                       contentView.addSubview(button)
                       button.translatesAutoresizingMaskIntoConstraints = false
                         
                     
                         NSLayoutConstraint.activate([
                             button.widthAnchor.constraint(equalToConstant: buttonSize),
                             button.heightAnchor.constraint(equalToConstant: buttonSize),
                             button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CGFloat(col) * (buttonSize + spacing) + spacing),
                             button.topAnchor.constraint(equalTo: remarksLabel.topAnchor, constant: 35 + CGFloat(row) * (buttonSize + spacing) + spacing)
                         ])
                   }
                  
               }
           }
        
              // 约束内容视图的高度，使其包含所有按钮
              var heightSummary:CGFloat = CGFloat(summaryLabel.text?.count ?? 0) * 1.2
              print(heightSummary)
                if ( heightSummary <= 0.0) {
                    heightSummary = 200.0
                }
              NSLayoutConstraint.activate([
              
                    contentView.heightAnchor.constraint(equalToConstant:self.view.frame.height*0.6 + heightSummary   +  CGFloat(numberOfRows) * (buttonSize + spacing) + spacing)
                
              ])
       }
    
    @objc private func ButtonhdplayurlTapped(_ button:UIButton){
        if hdplayurl.count > 5 ,let u = URL(string: hdplayurl) {
            
            let resource = KSPlayerResource(url: u)
            let controller = DetailViewController()
            controller.resource = resource
//            self.show(controller, sender: self)
            if let s = self.movieDetail {
                LocalStore.saveToUserDefaults(RecentlyWatchVideo: s)
                //通知刷新列表
                
                // 发送通知
                NotificationCenter.default.post(name: .historyItemsUpdated, object: nil)
                
            }
            
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated:false)
        }
        
    }
    
    @objc private func ButtonTapped(_ button:UIButton){
               
        if let u = URL(string: jishuURLArray[button.tag]) {
            
           let resource = KSPlayerResource(url: u)
           let controller = DetailViewController()
           controller.resource = resource
            
            if let s = self.movieDetail {
                LocalStore.saveToUserDefaults(RecentlyWatchVideo: s)
                //通知刷新列表
                
                // 发送通知
                NotificationCenter.default.post(name: .historyItemsUpdated, object: nil)
                
            }
            
//            self.show(controller, sender: self)
           controller.modalPresentationStyle = .fullScreen
           self.present(controller, animated:false)
       }
    }
}
