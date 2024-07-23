//
//  File.swift
//  SDKVideoPlayer
//
//  Created by Zeus on 2024/7/19.
//

import Foundation
import UIKit

class VideoPopupView: UIView {
    
    let titleLabelName: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textColor = ThemeManager.shared.fontColor2
        label.textAlignment = .center
        label.numberOfLines = 1
//        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = ThemeManager.shared.fontColor
        label.textAlignment = .center
        label.numberOfLines = 1
//        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    let durationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = ThemeManager.shared.fontColor2
        label.textAlignment = .center
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "Play")
//        imageView.clipsToBounds = true
//        imageView.layer.cornerRadius = 10
//        imageView.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let playButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitle( NSLocalizedString("ClickPlay", comment: ""), for: .normal)
        button.setTitleColor(.white, for: UIControl.State.normal)
        button.layer.cornerRadius = 8
        button.backgroundColor = UIColor.MainColor()
        button.clipsToBounds = true
        
        return button
    }()
    
    var cornerRadius: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    
    var playAction: (() -> Void)?
    
    
    let gradientView = GradientView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        gradientView.startColor = UIColor.MainColor() // Light blue
        gradientView.endColor = ThemeManager.shared.viewBackgroundColor
        //  UIColor(fromHex: "#eeeff1") //UIColor(red: 0.12, green: 0.56, blue: 1.0, alpha: 1.0)   // Blue
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(gradientView)
        //insertSubview(gradientView, at: 0)
        
        
        // 设置 Auto Layout 约束
        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: self.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            gradientView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        gradientView.frame = self.frame

        //backgroundColor = ThemeManager.shared.viewBackgroundColor
//        layer.cornerRadius = 12
        self.cornerRadius = 12
        
        layer.shadowColor = ThemeManager.shared.fontColor.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: -2)
        
        titleLabelName.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabelName)
        addSubview(titleLabel)
        addSubview(durationLabel)
        addSubview(imageView)
        addSubview(playButton)
        
        NSLayoutConstraint.activate([            
            
            titleLabelName.topAnchor.constraint(equalTo: topAnchor, constant: 2),
            titleLabelName.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabelName.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabelName.heightAnchor.constraint(equalToConstant: 20),
                
            titleLabel.topAnchor.constraint(equalTo: titleLabelName.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.heightAnchor.constraint(equalToConstant: 104),
            
            durationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            durationLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            durationLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            durationLabel.heightAnchor.constraint(equalToConstant: 10),
            
//            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0),
            imageView.heightAnchor.constraint(equalToConstant: 50),
            imageView.widthAnchor.constraint(equalToConstant: 50),
            
            
            //playButton.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 16),
            playButton.heightAnchor.constraint(equalToConstant: 50),
            playButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 80),
            playButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -80),
            playButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    private func setupView() {
            layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        applyCornerRadius()
    }
    
    private func applyCornerRadius() {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: [UIRectCorner.topLeft, UIRectCorner.topRight],
                                cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }

    
    @objc private func playButtonTapped() {
        playAction?()
    }
    
    public func configData(title: String ,durationLabel :String){
        self.titleLabel.text = title
        self.titleLabelName.text = NSLocalizedString("Get_successful_online_video", comment: "") 
    }
}
