//
//  File.swift
//  SDKVideoPlayer
//
//  Created by Zeus on 2024/7/19.
//

import Foundation
import UIKit

class VideoPopupView: UIView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = ThemeManager.shared.fontColor
        label.textAlignment = .center
        return label
    }()
    
    let durationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = ThemeManager.shared.fontColor2
        label.textAlignment = .center
        return label
    }()
    
    let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("立即播放", for: .normal)
        button.setTitleColor(ThemeManager.shared.fontColor, for: UIControl.State.normal)
        button.layer.cornerRadius = 8
        button.backgroundColor = UIColor.MainColor()
        button.clipsToBounds = true
        
        return button
    }()
    
    var playAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: -2)
        
        addSubview(titleLabel)
        addSubview(durationLabel)
        addSubview(playButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            titleLabel.heightAnchor.constraint(equalToConstant: 44),
            
            durationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            durationLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            durationLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
//            durationLabel.heightAnchor.constraint(equalToConstant: 44),
            
            
            playButton.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 16),
            playButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            playButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            playButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func playButtonTapped() {
        playAction?()
    }
    
    public func configData(title: String ,durationLabel :String){
        self.titleLabel.text = title
    }
}
