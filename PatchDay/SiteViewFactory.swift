//
// Created by Juliya Smith on 12/4/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class SiteViewFactory {

    static func createBackItem() -> UIBarButtonItem {
        let backItem = UIBarButtonItem()
        backItem.title = VCTitleStrings.sitesTitle
        return backItem
    }

    static func createInsertItem(insertAction: Selector, sitesViewController: UIViewController) -> UIBarButtonItem {
        let insertItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonItem.SystemItem.add,
            target: sitesViewController,
            action: insertAction
        )
        insertItem.tintColor = PDColors.get(.Green)
        return insertItem
    }

    static func createEditItem(editAction: Selector, sitesViewController: UIViewController) -> UIBarButtonItem {
        let editButton = UIBarButtonItem(
            title: ActionStrings.edit,
            style: .plain,
            target: sitesViewController,
            action: editAction
        )
        return editButton
    }

    static func createDeleteRowTableAction(indexPath: IndexPath) -> UITableViewRowAction {
        let title = ActionStrings.delete
        let delete = UITableViewRowAction(style: .normal, title: title) {
            _, _ in self.deleteCell(indexPath: indexPath)
        }
        delete.backgroundColor = UIColor.red
        return [delete]
    }
}
