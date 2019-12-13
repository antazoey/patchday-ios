//
// Created by Juliya Smith on 12/3/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class PillsViewFactory {

    static func createInsertButton(action: Selector) -> UIBarButtonItem {
        let insertButton = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: action
        )
        insertButton.tintColor = PDColors.get(.Green)
        return insertButton
    }
}
