//
// Created by Juliya Smith on 12/3/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class PillsViewFactory {

	private var insertButtonAction: () -> ()

	init(insertButtonAction: @escaping () -> ()) {
		self.insertButtonAction = insertButtonAction
	}

	func createInsertButton() -> UIBarButtonItem {
		let insertButton = UIBarButtonItem(
			barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(callInsertButtonAction)
		)
		insertButton.tintColor = PDColors[.NewItem]
		return insertButton
	}

	func createSiteCellDeleteSwipeAction(delete: @escaping () -> ()) -> UIContextualAction {
		let title = ActionStrings.Delete
		let delete = UIContextualAction(style: .normal, title: title) {
			_, _, _ in delete()
		}
		delete.backgroundColor = UIColor.red
		return delete
	}

	@objc private func callInsertButtonAction() {
		insertButtonAction()
	}
}
