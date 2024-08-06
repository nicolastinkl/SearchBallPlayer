//
//  ErrorPlaceholderView.swift
//  UpcomingMovies
//
//  Created by Alonso on 11/7/18.
//  Copyright © 2018 Alonso. All rights reserved.
//

import UIKit

protocol ErrorPlaceholderViewDelegate: AnyObject {

    func errorPlaceholderView(_ errorPlaceholderView: ErrorPlaceholderView, didRetry sender: UIButton)

}

final class ErrorPlaceholderView: UIView, NibLoadable, RetryPlaceHolderable {

    @IBOutlet private weak var errorTitleLabel: UILabel!
    @IBOutlet private weak var errorDetailLabel: UILabel!
    @IBOutlet private weak var retryButton: ShrinkingButton!

    var isPresented: Bool = false
    var retry: (() -> Void)?

    weak var delegate: ErrorPlaceholderViewDelegate?

    var detailText: String? {
        didSet {
            guard let detailText = detailText else { return }
            errorDetailLabel.text = detailText
        }
    }

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }

    // MARK: - Private

    private func setupUI() {
        alpha = 0.0
        setupErrorTitleLabel()
        setupErrorDetailLabel()
        setupRetryButton()
    }

    private func setupErrorTitleLabel() {
        errorTitleLabel.text = Constants.errorTitle
        errorTitleLabel.textColor =  .systemRed //ThemeManager.shared.fontColor
        errorTitleLabel.font = FontHelper.regular(withSize: 24.0)
        errorTitleLabel.adjustsFontForContentSizeCategory = true
    }

    private func setupErrorDetailLabel() {
        errorDetailLabel.text = Constants.errorDetail
        errorDetailLabel.textColor = ThemeManager.shared.fontColor
        errorDetailLabel.font = FontHelper.subheadLight
        errorDetailLabel.adjustsFontForContentSizeCategory = true
    }

    private func setupRetryButton() {
        retryButton.setTitle(Constants.retryButtonTitle, for: .normal)
        retryButton.backgroundColor = ThemeManager.shared.viewBackgroundColor
        retryButton.setTitleColor(ThemeManager.shared.fontColor, for: .normal)
        retryButton.setTitleColor(ThemeManager.shared.fontColor.withAlphaComponent(0.5), for: .highlighted)
        
//        retryButton.layer.cornerRadius = 5
        retryButton.clipsToBounds = true
        retryButton.layer.cornerRadius = retryButton.frame.height/2
        retryButton.layer.borderColor = ThemeManager.shared.fontColor.cgColor
        retryButton.layer.borderWidth = 1
        retryButton.spinnerColor =  ThemeManager.shared.fontColor
        retryButton.addTarget(self, action: #selector(retryAction), for: .touchUpInside)
    }

    // MARK: - Selectors

    @objc private func retryAction() {
        retryButton.startAnimation()
        retry?()
    }

    // MARK: - RetryPlaceHolderable

    func resetState() {
        retryButton.stopAnimation()
    }

}

// MARK: - Constants

extension ErrorPlaceholderView {

    struct Constants {
        static let errorTitle = "Error"
        static let errorDetail = "Error Content"
        static let retryButtonTitle = "Retry"
    }

}
