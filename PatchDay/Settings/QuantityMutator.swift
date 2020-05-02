//
//  PatchDataHelper.swift
//  PatchDay
//
//  Created by Juliya Smith on 10/20/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class QuantityMutator: QuantityMutating {

	var sdk: PatchDataSDK?
	let alerts: AlertDispatching?
	let tabs: TabReflective?
	let notifications: NotificationScheduling?
	let decline: (_ originalQuantity: Int) -> Void

	init(sdk: PatchDataSDK?,
		alerts: AlertDispatching?,
		tabs: TabReflective?,
		notifications: NotificationScheduling?,
		decline: @escaping (_ originalQunatity: Int) -> Void) {
		self.sdk = sdk
		self.alerts = alerts
		self.tabs = tabs
		self.notifications = notifications
		self.decline = decline
	}

	func setQuantity(to newQuantity: Int) {
		guard let sdk = sdk else { return }
		let oldQuantity = sdk.settings.quantity.rawValue
		if newQuantity >= oldQuantity {
			sdk.settings.setQuantity(to: newQuantity)
			return
		}
		let continueAction: (_ newQuantity: Int) -> Void = {
			(newQuantity) in
			sdk.hormones.delete(after: newQuantity)
			sdk.settings.setQuantity(to: newQuantity)
			self.makeResetClosure(oldQuantity: oldQuantity)(oldQuantity)
		}
		let handler = QuantityMutationAlertActionHandler(
			cont: continueAction,
			decline: self.decline,
			setQuantity: sdk.settings.setQuantity
		)
		alerts?.presentQuantityMutationAlert(
			oldQuantity: oldQuantity,
			newQuantity: newQuantity,
			handlers: handler
		)
	}

	private func makeResetClosure(oldQuantity: Int) -> ((Int) -> Void) {
		let reset: (Int) -> Void = {
			newQuantity in
			self.tabs?.reflectHormoneCharacteristics()
			self.notifications?.cancelRangeOfExpiredHormoneNotifications(
				from: newQuantity, to: oldQuantity
			)
		}
		return reset
	}
}
