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

    static func createItemFromActionState(_ props: BarItemInitializationProperties) -> UIBarButtonItem {
        switch props.tableActionState {
        case .Editing: return SiteViewFactory.createResetItem(reset: props.reset)
        case .Reading: return SiteViewFactory.createInsertItem(insert: props.insert, sitesViewController: props.sitesViewController)
        case .Unknown: return UIBarButtonItem()
        }
    }

    static func createInsertItem(insert: Selector, sitesViewController: UIViewController) -> UIBarButtonItem {
        let insertItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonItem.SystemItem.add,
            target: sitesViewController,
            action: insert
        )
        insertItem.tintColor = PDColors.get(.Green)
        return insertItem
    }

    static func createEditItem(edit: Selector, sitesViewController: UIViewController) -> UIBarButtonItem {
        UIBarButtonItem(
            title: ActionStrings.edit,
            style: .plain,
            target: sitesViewController,
            action: edit
        )
    }

    static func createResetItem(reset: Selector) -> UIBarButtonItem {
        let item = UIBarButtonItem(
            title: ActionStrings.reset,
            style: .plain,
            target: self,
            action: reset
        )
        item.tintColor = UIColor.red
        return item
    }

    /// Create a delete row action. Row actions are the buttons that appear in TableViews when you swipe them.
    static func createDeleteRowTableAction(indexPath: IndexPath, delete: @escaping (IndexPath) -> ()) -> UITableViewRowAction {
        let title = ActionStrings.delete
        let deleteRowAction = UITableViewRowAction(style: .normal, title: title) { _, _ in delete(indexPath)}
        deleteRowAction.backgroundColor = UIColor.red
        return deleteRowAction
    }
}