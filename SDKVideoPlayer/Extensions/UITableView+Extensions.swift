//
//  UITableView+Extensions.swift
//  UpcomingMovies
//
//  Created by Alonso on 2/5/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

import UIKit

extension UITableView {

    // MARK: - Cell Register

    func register<T: UITableViewCell>(cellType: T.Type, bundle: Bundle? = nil) {
        let identifier = String(describing: cellType)

//        let identifier = cellType.dequeueIdentifier
        register(cellType, forCellReuseIdentifier: identifier)
    }

    // MARK: - Nib Register

    func registerNib<T: UITableViewCell>(cellType: T.Type, bundle: Bundle? = nil) {
//        let identifier = cellType.dequeueIdentifier
        let identifier = String(describing: cellType)

        let nib = UINib(nibName: identifier, bundle: bundle)
        register(nib, forCellReuseIdentifier: identifier)
    }

    // MARK: - Dequeuing

    func dequeueReusableCell<T: UITableViewCell>(with type: T.Type, for indexPath: IndexPath) -> T? {
        let identifier = String(describing: type)

        return  self.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T
    }

    // MARK: - Header

    func configureDynamicHeaderViewHeight() {
        guard let headerView = tableHeaderView else { return }
        let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var headerFrame = headerView.frame

        // Comparison needed to avoid an infinite loop
        if height != headerFrame.size.height {
            headerFrame.size.height = height
            headerView.frame = headerFrame
            tableHeaderView = headerView
        }
    }

}
