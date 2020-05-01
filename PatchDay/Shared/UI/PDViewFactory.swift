//
// Created by Juliya Smith on 11/29/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class PDViewFactory {

	static func createDoneButton(doneAction: Selector, mainView: UIView, targetViewController: UIViewController) -> UIButton {
		let donePoint = CGPoint(x: configureDoneButtonStartX(mainView: mainView), y: 0)
		let doneSize = CGSize(width: 100, height: 50)
		let doneRect = CGRect(origin: donePoint, size: doneSize)
		let doneButton = UIButton(frame: doneRect)
		doneButton.setTitle(ActionStrings.Done, for: UIControl.State.normal)
		doneButton.setTitle(ActionStrings.Done, for: UIControl.State.highlighted)
        doneButton.setTitleColor(PDColors[.Button], for: UIControl.State.normal)
        doneButton.setTitleColor(PDColors[.Text], for: UIControl.State.highlighted)
		doneButton.replaceTarget(targetViewController, newAction: doneAction)
		return doneButton
	}

	private static func configureDoneButtonStartX(mainView: UIView) -> CGFloat {
		AppDelegate.isPad ? 0 : (mainView.frame.size.width / 2) - 50
	}

	static func createTextBarButtonItem(_ text: String, color: UIColor = PDColors[.Button]) -> UIBarButtonItem {
		let item = createBarButtonItem(color)
		item.title = text
		return item
	}

	static func createIconBarButtonItem(_ icon: UIIcon, color: UIColor = PDColors[.Button]) -> UIBarButtonItem {
		let item = createBarButtonItem(color)
		item.image = icon
		return item
	}

	private static func createBarButtonItem(_ color: UIColor) -> UIBarButtonItem {
		let item = UIBarButtonItem()
		item.tintColor = color
		return item
	}
}
