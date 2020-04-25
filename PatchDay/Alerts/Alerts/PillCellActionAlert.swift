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
    
    private var cancelAction: UIAlertAction {
        UIAlertAction(title: ActionStrings.Cancel, style: .default)
    }

	private var pillDetailsAction: UIAlertAction {
        UIAlertAction(title: ActionStrings.Edit, style: .default) {
			void in self.handlers.goToDetails()
		}
	}

	private var takeAction: UIAlertAction {
        UIAlertAction(title: ActionStrings.Take, style: .default) {
			void in self.handlers.takePill()
		}
	}

	override func present() {
		self.present(actions: [pillDetailsAction, takeAction, cancelAction])
	}
}
