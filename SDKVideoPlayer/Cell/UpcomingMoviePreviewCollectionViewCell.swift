//
//  UpcomingMoviePreviewCollectionViewCell.swift
//  UpcomingMovies
//
//  Created by Alonso on 1/24/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

import UIKit

import SDWebImage

final class UpcomingMoviePreviewCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private(set) weak var posterImageView: SDAnimatedImageView!

 

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
//        posterImageView.cancelImageDownload()
        posterImageView.image = nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    // MARK: - Private

    private func setupUI() {
        isAccessibilityElement = true

        titleLabel.textColor = ThemeManager.shared.fontColor
        titleLabel.numberOfLines = 0
        titleLabel.font = FontHelper.bodySemiBold
        titleLabel.adjustsFontForContentSizeCategory = true
    }

    // MARK: - Reactive Behavior

    public func setupBindables(viewModel:  PopularMovie?) {
        guard let viewModel = viewModel else { return }
        accessibilityLabel = viewModel.title
        if  viewModel.posterPath.count > 1 {
//            posterImageView.setImage(with: posterURL)
            
            posterImageView.sd_setImage(with:  URL(string: ApplicationS.defaultRegularImageBaseURLString.appending(viewModel.posterPath) ), placeholderImage: UIImage(named: "placeholder-image"), context: [:])
            
            titleLabel.text = nil
        } else {
            posterImageView.backgroundColor = .darkGray
            titleLabel.text = viewModel.title
        }
    }

}
