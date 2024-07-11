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
import SwiftLoader
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
               UIColor.black.cgColor  // 底部黑色
           ]
           gradientLayer.locations = [0.0, 0.9] // 渐变在图片高度的一半开始
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
    
    
    private let ScrollView: UIScrollView = {
        let label = UIScrollView()
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
         
        setupScrollView()
        setupPosterImageView()
        setupNameLabel()
        setupSummaryLabel()
        setupRemarksLabel()
        
        // 使用提供的JSON数据填充界面
        guard let movieDetail = movieDetail else { return }
        loadMovieDetail(movieDetail)
        
        //generation back button
        
        // list
        
        // Scrollview
        
    }
    
    private func setupScrollView(){
        
        view.addSubview(ScrollView)
        // 约束：顶部对齐刘海屏，宽度占满屏幕，高度根据图片比例设置
          NSLayoutConstraint.activate([
            ScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            ScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
          ])
        
    }
    
    private func setupPosterImageView() {
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        ScrollView.addSubview(posterImageView)
        
        // 约束：顶部对齐刘海屏，宽度占满屏幕，高度根据图片比例设置
          NSLayoutConstraint.activate([
              posterImageView.topAnchor.constraint(equalTo: ScrollView.topAnchor),
              posterImageView.leadingAnchor.constraint(equalTo: ScrollView.leadingAnchor),
              posterImageView.trailingAnchor.constraint(equalTo: ScrollView.trailingAnchor),
              posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: 16/9) // 根据图片实际比例调整
          ])
          
          // 更新渐变层的位置，确保它适应刘海屏
          posterImageView.layoutIfNeeded()
          let gradientLayer = posterImageView.layer.sublayers?.first as? CAGradientLayer
          gradientLayer?.frame = CGRect(x: 0, y: 0, width: posterImageView.bounds.width, height: posterImageView.bounds.height)
    
    }
    
    private func setupNameLabel() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        ScrollView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: ScrollView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: ScrollView.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupSummaryLabel() {
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        ScrollView.addSubview(summaryLabel)
        
        NSLayoutConstraint.activate([
            summaryLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            summaryLabel.leadingAnchor.constraint(equalTo: ScrollView.leadingAnchor, constant: 20),
            summaryLabel.trailingAnchor.constraint(equalTo: ScrollView.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupRemarksLabel() {
        remarksLabel.translatesAutoresizingMaskIntoConstraints = false
        ScrollView.addSubview(remarksLabel)
        
        NSLayoutConstraint.activate([
            remarksLabel.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 20),
            remarksLabel.leadingAnchor.constraint(equalTo: ScrollView.leadingAnchor, constant: 20),
            remarksLabel.trailingAnchor.constraint(equalTo: ScrollView.trailingAnchor, constant: -20)
        ])
    }
    
    private func loadMovieDetail(_ movie: Video) {
        // 从URL加载图片
        if let imageUrl = URL(string: movie.vodPic) {
            self.posterImageView.sd_setImage(with: imageUrl, placeholderImage:  UIImage(named: "placeholder-image"), context: nil)
        }
        nameLabel.text = movie.vodName
        summaryLabel.text = movie.vodBlurb + movie.vodContent
        remarksLabel.text = movie.vodRemarks
    }
    
    
}
