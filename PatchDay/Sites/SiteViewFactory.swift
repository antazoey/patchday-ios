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
		let vc = props.sitesViewController
		switch props.tableActionState {
			case .Editing: return SiteViewFactory.createResetItem(reset: props.reset, sitesViewController: vc)
			case .Reading: return SiteViewFactory.createInsertItem(insert: props.insert, sitesViewController: vc)
			case .Unknown: return UIBarButtonItem()
		}
	}

	static func createInsertItem(insert: Selector, sitesViewController: UIViewController) -> UIBarButtonItem {
		let insertItem = UIBarButtonItem(
			barButtonSystemItem: UIBarButtonItem.SystemItem.add,
			target: sitesViewController,
			action: insert
		)
		insertItem.tintColor = PDColors[.NewItem]
		insertItem.title = nil
		return insertItem
	}

	static func createEditItem(edit: Selector, sitesViewController: UIViewController) -> UIBarButtonItem {
		let item = PDViewFactory.createTextBarButtonItem(ActionStrings.Edit)
		item.target = sitesViewController
		item.action = edit
		return item
	}

	static func createResetItem(reset: Selector, sitesViewController: UIViewController) -> UIBarButtonItem {
		let item = PDViewFactory.createTextBarButtonItem(ActionStrings.Reset, color: UIColor.red)
		item.style = .plain
		item.target = sitesViewController
		item.action = reset
		item.image = nil
		return item
	}

	/// Create a delete row action. Row actions are the buttons that appear in TableViews when you swipe them.
	static func createDeleteRowTableAction(indexPath: IndexPath, delete: @escaping (IndexPath) -> Void) -> UIContextualAction {
		let title = ActionStrings.Delete
		let deleteRowAction = UIContextualAction(style: .normal, title: title) {
			_, _, _ in delete(indexPath)
		}
		deleteRowAction.backgroundColor = UIColor.red
		return deleteRowAction
	}
}
