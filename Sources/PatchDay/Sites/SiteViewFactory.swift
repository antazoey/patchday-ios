//
// Created by Juliya Smith on 12/4/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class SiteViewFactory {

    static func createBackItem() -> UIBarButtonItem {
        PDViewFactory.createTextBarButtonItem(PDTitleStrings.SitesTitle)
    }

    static func createItemFromActionState(_ props: BarItemInitializationProperties) -> UIBarButtonItem {
        let viewController = props.sitesViewController
        if props.isEditing {
            return SiteViewFactory.createResetItem(
                reset: props.reset, sitesViewController: viewController
            )
        }
        return SiteViewFactory.createInsertItem(
            insert: props.insert, sitesViewController: viewController
        )
    }

    static func createInsertItem(insert: Selector, sitesViewController: UIViewController) -> UIBarButtonItem {
        let item = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonItem.SystemItem.add,
            target: sitesViewController,
            action: insert
        )
        item.tintColor = PDColors[.NewItem]
        item.title = nil
        item.accessibilityIdentifier = "insertNewSiteButton"
        return item
    }

    static func createEditItem(edit: Selector, sitesViewController: UIViewController) -> UIBarButtonItem {
        let item = PDViewFactory.createTextBarButtonItem(ActionStrings.Edit)
        item.target = sitesViewController
        item.action = edit
        item.accessibilityIdentifier = "editSitesButton"
        return item
    }

    static func createResetItem(reset: Selector, sitesViewController: UIViewController) -> UIBarButtonItem {
        let item = PDViewFactory.createTextBarButtonItem(ActionStrings.Reset, color: UIColor.red)
        item.style = .plain
        item.target = sitesViewController
        item.action = reset
        item.image = nil
        item.accessibilityIdentifier = "resetSitesButton"
        return item
    }

    /// Create a delete row action. Row actions are the buttons that appear in TableViews when you swipe them.
    static func createDeleteRowTableAction(
        indexPath: IndexPath, delete: @escaping (IndexPath) -> Void
    ) -> UIContextualAction {
        let title = ActionStrings.Delete
        let deleteRowAction = UIContextualAction(style: .normal, title: title) {
            _, _, _ in delete(indexPath)
        }
        deleteRowAction.backgroundColor = UIColor.red
        return deleteRowAction
    }
}
