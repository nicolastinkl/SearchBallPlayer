//
//  MovieDetailViewController.swift
//  SDKVideoPlayer
//
//  Created by Zeus on 2024/8/5.
//

import Foundation

import UIKit

final class MovieDetailViewController: UIViewController, Storyboarded, Transitionable {
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var posterContainerView: UIView!

    @IBOutlet private weak var titleContainerView: UIView!
    @IBOutlet private weak var titleContainerViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet private weak var optionsContainerView: UIView!

    @IBOutlet private weak var genreLabel: UILabel!
    @IBOutlet private weak var releaseDateLabel: UILabel!
    @IBOutlet private weak var overviewLabel: UILabel!

    static var storyboardName: String = "Home"
    

    private lazy var moreBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "Ellipsis"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(moreBarButtonAction(_:)))
        return barButtonItem
    }()

//    private lazy var favoriteBarButtonItem: FavoriteToggleBarButtonItem = {
//        let barButtonItem = FavoriteToggleBarButtonItem()
//        barButtonItem.target = self
//        barButtonItem.action = #selector(favoriteButtonAction(_:))
//
//        return barButtonItem
//    }()

    // MARK: - Dependencies
    var viewModel: PopularMovie?
    private(set) var transitionContainerView: UIView?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindables()

        configureUI()
        //viewModel?.getMovieDetail(showLoader: true)
    }
    
    @objc func moreBarButtonAction (_ sender: UIButton) {
        
    }
 

    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
//        if let viewController = container as? MovieDetailTitleViewController {
//            titleContainerViewHeightConstraint?.constant = viewController.preferredContentSize.height
//        }
    }

    // MARK: - Private

    private func setupUI() {
        
        title = viewModel?.originalTitle

//        coordinator?.embedMovieDetailPoster(on: self, in: posterContainerView)
//        coordinator?.embedMovieDetailTitle(on: self, in: titleContainerView)
//        coordinator?.embedMovieDetailOptions(on: self, in: optionsContainerView)

        setupNavigationBar()
        setupLabels()
    }

    private func setupNavigationBar() {
        let backItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        navigationItem.backBarButtonItem = backItem
        navigationItem.rightBarButtonItems = [moreBarButtonItem]
    }

    private func setupLabels() {
        genreLabel.font = FontHelper.body
        genreLabel.adjustsFontForContentSizeCategory = true

        releaseDateLabel.font = FontHelper.body
        releaseDateLabel.adjustsFontForContentSizeCategory = true

        overviewLabel.font = FontHelper.body
        overviewLabel.adjustsFontForContentSizeCategory = true
    }

    private func configureUI() {
        guard let viewModel = viewModel else { return }
        releaseDateLabel.text = viewModel.releaseDate
        overviewLabel.text = viewModel.overview
    }

    // MARK: - Reactive Behavior

    private func setupBindables() {
//        setupViewBindables()
//        setupLoaderBindable()
//        setupErrorBindables()
//        setupAlertBindables()
    }

}


