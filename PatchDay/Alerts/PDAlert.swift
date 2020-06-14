//
//  PDAlert.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/16/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

public class PDAlert: PDAlerting {

	let controller: UIAlertController
	let parent: UIViewController
	let style: UIAlertController.Style

	init(parent: UIViewController, title: String, message: String, style: UIAlertController.Style) {
		self.controller = UIAlertController(title: title, message: message, preferredStyle: style)
		self.parent = parent
		self.style = style
	}

	public func present(actions: [UIAlertAction]) {
		for a in actions {
			controller.addAction(a)
		}
		parent.present(controller, animated: true, completion: nil)
	}

	public func present() {
		if AppDelegate.isPad {
			controller.popoverPresentationController?.sourceView = parent.view
		}
		parent.present(controller, animated: true, completion: nil)
	}
}
