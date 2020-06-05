//
//  UnsavedChangesAlert.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/4/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class UnsavedChangesAlert: PDAlert {

	let title = NSLocalizedString("Unsaved Changes", comment: "Title of alert")
	let saveAndContinueTitle = NSLocalizedString("Save and continue", comment: "Alert action")
	let discardAndContinue = NSLocalizedString("Continue without saving", comment: "Alert action")


	let saveAndContinueHandler: () -> Void
	let discardChangesHandler: () -> Void

	var saveAndContinueAction: UIAlertAction {
		let handler: ((UIAlertAction) -> Void) = { _ in self.saveAndContinueHandler() }
		return UIAlertAction(title: saveAndContinueTitle, style: .default, handler: handler)
	}

	var discardAndContinueAction: UIAlertAction {
		let handler: ((UIAlertAction) -> Void) = { _ in self.discardChangesHandler() }
		return UIAlertAction(title: discardAndContinue, style: .destructive, handler: handler)
	}

	var declineAction: UIAlertAction {
		let title = ActionStrings.Decline
		return UIAlertAction(title: title, style: .cancel)
	}

	init(
		parent: UIViewController,
		saveAndContinueHandler: @escaping () -> Void,
		discardHandler: @escaping () -> Void
	) {
		self.saveAndContinueHandler = saveAndContinueHandler
		self.discardChangesHandler = discardHandler
		super.init(parent: parent, title: self.title, message: "", style: .actionSheet)
	}

	override func present() {
		let actions = [saveAndContinueAction, discardAndContinueAction, declineAction]
		super.present(actions: actions)
	}
}
