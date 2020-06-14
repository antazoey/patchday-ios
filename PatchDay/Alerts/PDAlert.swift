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

	let alert: UIAlertController
	let parent: UIViewController

	init(parent: UIViewController, title: String, message: String, style: UIAlertController.Style) {
		let _style = AppDelegate.isPad ? .alert : style
		self.alert = UIAlertController(title: title, message: message, preferredStyle: _style)
		self.parent = parent
	}

	public func present(actions: [UIAlertAction]) {
		if alert.actions.count == 0 {
			for a in actions {
				if !alert.actions.contains(a) {
					alert.addAction(a)
				}
			}
		}
		// bug in swift preventing calling self.present()
		_ = parent.present(alert, animated: true, completion: nil)
	}

	public func present() {
		self.parent.present(self.alert, animated: true)
	}
}
