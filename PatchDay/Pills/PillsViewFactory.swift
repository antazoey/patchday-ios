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
    
    static func createSiteCellDeleteSwipeAction(delete: @escaping () -> ()) -> UIContextualAction {
        let title = ActionStrings.delete
        let delete = UIContextualAction(style: .normal, title: title) {
             _, _, _ in delete()
        }
        delete.backgroundColor = UIColor.red
        return delete
    }
}
