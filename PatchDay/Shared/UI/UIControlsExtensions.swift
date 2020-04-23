//
//  UIControlsExtensions.swift
//  PatchDay
//
//  Created by Juliya Smith on 10/17/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


extension UIControl {

	func showAsEnabled() {
		isEnabled = true
		isHidden = false
	}

	func hideAsDisabled() {
		isEnabled = false
		isHidden = true
	}

	func replaceTarget(_ baseTarget: Any?, newAction: Selector, for event: UIControl.Event = .touchUpInside) {
		removeTarget(nil, action: nil, for: .allEvents)
		addTarget(baseTarget, action: newAction, for: event)
	}

	func removeTarget(_ source: Any, action: Selector) {
		removeTarget(source, action: action, for: .allEditingEvents)
	}

	func addTarget(_ source: Any, action: Selector) {
		addTarget(source, action: action, for: .touchUpInside)
	}
}

extension UIPickerView {

	func selectRow(_ row: Int) {
		selectRow(row, inComponent: 0, animated: false)
	}

	func getSelectedRow() -> Int {
		selectedRow(inComponent: 0)
	}
}

extension UISwitch {

	func setOn(_ on: Bool) {
		setOn(on, animated: false)
	}
}

extension UIButton {

	func setTitleForNormalAndDisabled(_ title: String) {
		setTitle(title, for: .normal)
		setTitle(title, for: .disabled)
	}

	func setTitle(_ title: String) {
		setTitle(title, for: .normal)
	}

	func setTitleColor(_ color: UIColor?) {
		setTitleColor(color, for: .normal)
	}

	func restoreSuffix() -> Int? {
		if let restoreId = restorationIdentifier {
			return Int("\(restoreId.suffix(1))")
		}
		return -1
	}

	/// Tries to convert the restoration ID to a PDSetting.
	/// It must end with either "Button" or "ArrowButton" and it must be a the name of a PDSetting.
	func tryGetSettingFromButtonMetadata() -> PDSetting? {
		guard let id = restorationIdentifier else { return nil }
		guard id.substring(from: id.count - 6) == "Button" else { return nil }
		var setting = id.substring(to: id.count - 6)
		if setting.substring(from: setting.count - 5) == "Arrow" {
			setting = setting.substring(to: setting.count - 5)
		}
		return NameToSettingMap[setting.lowercased()]
	}
}
