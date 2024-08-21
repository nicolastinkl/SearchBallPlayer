//
//  UpcomingMovieExpandedCollectionViewCell.swift
//  SDKVideoPlayer
//
//  Created by Zeus on 2024/8/5.
//

import Foundation

import UIKit

import SafariServices
import Alamofire
import SDWebImage


final class SearchBallExpandedCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var backdropImageView: SDAnimatedImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var releaseDateLabel: UILabel!
    @IBOutlet private(set) weak var posterImageView: SDAnimatedImageView!

     

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse() 
        backdropImageView.image = nil
        posterImageView.image = nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    // MARK: - Private

    private func setupUI() {
        isAccessibilityElement = true
        titleLabel.font = FontHelper.headlineBold
        titleLabel.adjustsFontForContentSizeCategory = true
        releaseDateLabel.font = FontHelper.body
        releaseDateLabel.adjustsFontForContentSizeCategory = true
        posterImageView.layer.cornerRadius = 6
        posterImageView.clipsToBounds = true
    }

    // MARK: - Reactive Behavior

    public func setupBindables(viewModel: PopularMovie?) {
        guard let viewModel = viewModel else { return }

        titleLabel.text = viewModel.title
        accessibilityLabel = viewModel.title

        releaseDateLabel.text = viewModel.releaseDate

        backdropImageView.sd_setImage(with:  URL(string: ApplicationS.defaultBackdropImageBaseURLString.appending(viewModel.backdropPath) ), placeholderImage: UIImage(named: "placeholder-image"), context: [:])
        
        
        posterImageView.sd_setImage(with:  URL(string:  ApplicationS.defaultRegularImageBaseURLString.appending(viewModel.posterPath)), placeholderImage: UIImage(named: "placeholder-image"), context: [:])
         
    }

}
