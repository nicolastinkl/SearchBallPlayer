//
//  UICollectionView+Extensions.swift
//  UpcomingMovies
//
//  Created by Alonso on 2/5/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

import UIKit

extension UICollectionView {

    // MARK: - Cell Register

    func register<T: UICollectionViewCell>(cellType: T.Type, bundle: Bundle? = nil) {
//        let identifier = cellType.dequeueIdentifier
        let identifier = String(describing: cellType)
        register(cellType, forCellWithReuseIdentifier: identifier)
    }

    // MARK: - Nib Register

    func registerNib<T: UICollectionViewCell>(cellType: T.Type, bundle: Bundle? = nil) {
//        let identifier = cellType.dequeueIdentifier
        let identifier = String(describing: cellType)
        let nib = UINib(nibName: identifier, bundle: bundle)
        register(nib, forCellWithReuseIdentifier: identifier)
    }

    // MARK: - Dequeuing

    func dequeueReusableCell<T: UICollectionViewCell>(with type: T.Type, for indexPath: IndexPath) -> T? {
        let identifier = String(describing: type)
        return self.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? T
    }

}
