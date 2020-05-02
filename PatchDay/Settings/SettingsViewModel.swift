//
//  SettingsViewModel.swift
//  PatchDay
//
//  Created by Juliya Smith on 10/29/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class SettingsViewModel: CodeBehindDependencies<SettingsViewModel> {

	var reflector: SettingsReflector
	var saver: SettingsSavePoint

	init(reflector: SettingsReflector, saver: SettingsSavePoint) {
		self.reflector = reflector
		self.saver = saver
		super.init()
	}

	var deliveryMethodStartIndex: Index {
		sdk?.settings.deliveryMethod.currentIndex ?? 0
	}

	var quantityStartIndex: Index {
		sdk?.settings.quantity.currentIndex ?? 0
	}

	var expirationIntervalStartIndex: Index {
		sdk?.settings.expirationInterval.currentIndex ?? 0
	}

	func activatePicker(_ picker: SettingsPickerView) {
		picker.isHidden ? picker.open() : close(picker)
	}

	func handleNewNotificationsValue(_ newValue: Float) {
		notifications?.cancelAllExpiredHormoneNotifications()
		let newMinutesBeforeValue = Int(newValue)
		sdk?.settings.setNotificationsMinutesBefore(to: newMinutesBeforeValue)
		notifications?.requestAllExpiredHormoneNotifications()
	}

	private func close(_ picker: SettingsPickerView) {
		picker.close()
		saver.save(picker.setting, selectedRow: picker.selectedRow(inComponent: 0))
	}
}
