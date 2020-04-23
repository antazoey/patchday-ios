//
// Created by Juliya Smith on 2/16/20.
// Copyright (c) 2020 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class PillCellActionAlert: PDAlert {

	private let handlers: PillCellActionHandling

	init(parent: UIViewController, pillName: String, handlers: PillCellActionHandling) {
		self.handlers = handlers
		super.init(parent: parent, title: pillName, message: "", style: .actionSheet)
	}

	private var pillDetailsAction: UIAlertAction {
		UIAlertAction(title: "Edit Details", style: .default) {
			void in self.handlers.goToDetails()
		}
	}

	private var takeAction: UIAlertAction {
		UIAlertAction(title: "Take Pill", style: .default) {
			void in self.handlers.takePill()
		}
	}

	override func present() {
		self.present(actions: [pillDetailsAction, takeAction])
	}
}
