//
//  PlaceholderDisplayable.swift
//  UpcomingMovies
//
//  Created by Alonso on 4/7/19.
//  Copyright © 2019 Alonso. All rights reserved.
//

import UIKit

typealias PlaceholderableTyealias = Displayable & Detailable
typealias RetryPlaceHolderable = Displayable & Detailable & RetryActionable

protocol PlaceholderDisplayable: Retryable, Emptiable {}

extension PlaceholderDisplayable where Self: UIViewController {

    func hideDisplayedPlaceholderView() {
        hideEmptyView()
        hideRetryView()
    }

}
