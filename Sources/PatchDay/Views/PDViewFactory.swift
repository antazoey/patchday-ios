//
// Created by Juliya Smith on 11/29/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class PDViewFactory {

    private static func configureDoneButtonStartX(mainView: UIView) -> CGFloat {
        AppDelegate.isPad ? 0 : (mainView.frame.size.width / 2) - 50
    }

    static func createTextBarButtonItem(_ text: String, color: UIColor = PDColors[.Button]) -> UIBarButtonItem {
        let item = createBarButtonItem(color)
        item.title = text
        return item
    }

    static func createIconBarButtonItem(_ icon: UIIcon, color: UIColor = PDColors[.Button]) -> UIBarButtonItem {
        let item = createBarButtonItem(color)
        item.image = icon
        return item
    }

    private static func createBarButtonItem(_ color: UIColor) -> UIBarButtonItem {
        let item = UIBarButtonItem()
        item.tintColor = color
        return item
    }
}
