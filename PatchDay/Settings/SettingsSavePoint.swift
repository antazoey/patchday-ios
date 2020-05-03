//
//  SettingsStateSaver.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/20/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class SettingsSavePoint: CodeBehindDependencies<SettingsSavePoint> {

	private let controls: SettingsControls

	init(controls: SettingsControls) {
		self.controls = controls
		super.init()
	}

	public func save(_ key: PDSetting, selectedRow: Index) {
		notifications?.cancelAllExpiredHormoneNotifications()
		switch key {
			case .DeliveryMethod: saveDeliveryMethodChange(selectedRow)
			case .Quantity: saveQuantity(selectedRow)
			case .ExpirationInterval: saveExpirationInterval(selectedRow)
		default: log.error("Error: No picker for key \(key)")
		}
		notifications?.requestAllExpiredHormoneNotifications()
	}

	private func saveDeliveryMethodChange(_ selectedRow: Index) {
		guard let sdk = sdk else { return }
		let newMethod = SettingsOptions.getDeliveryMethod(at: selectedRow)
		sdk.isFresh
			? sdk.settings.setDeliveryMethod(to: newMethod)
			: presentDeliveryMethodMutationAlert(choice: newMethod, controls: controls)
	}

	private func presentDeliveryMethodMutationAlert(choice: DeliveryMethod, controls: SettingsControls) {
		let decline = { (_ method: DeliveryMethod) -> Void in
			let methodTitle = SettingsOptions.getDeliveryMethodString(for: choice)
			switch choice {
				case .Patches:
					controls.deliveryMethodButton.setTitleForNormalAndDisabled(methodTitle)
					controls.quantityButton.isEnabled = true
					controls.quantityArrowButton.isEnabled = true
				case .Injections:
					controls.deliveryMethodButton.setTitleForNormalAndDisabled(methodTitle)
					controls.quantityButton.isEnabled = false
					controls.quantityArrowButton.isEnabled = false
			}
		}
		let handlers = DeliveryMethodMutationAlertActionHandler(decline: decline)
		alerts?.presentDeliveryMethodMutationAlert(newMethod: choice, handlers: handlers)
	}

	private func saveQuantity(_ selectedRow: Index) {
		let decline = createDeclineSaveQuantityButtonClosure()
		let newQuantity = SettingsOptions.getQuantity(at: selectedRow).rawValue
		QuantityMutator(
			sdk: sdk,
			alerts: alerts,
			tabs: tabs,
			notifications: notifications,
			decline: decline
		).setQuantity(to: newQuantity)
	}

	private func createDeclineSaveQuantityButtonClosure() -> (Int) -> Void { { oldQuantity in self.controls.quantityButton.setTitle("\(oldQuantity)") }
	}

	private func saveExpirationInterval(_ selectedRow: Index) {
		guard let newInterval = SettingsOptions.expirationIntervals.tryGet(at: selectedRow) else { return }
		sdk?.settings.setExpirationInterval(to: newInterval)
	}
}
