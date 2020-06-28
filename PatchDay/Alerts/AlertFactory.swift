//
//  AlertFactory.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/14/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class AlertFactory: AlertProducing {

	var sdk: PatchDataSDK
	var tabs: TabReflective?

	init(sdk: PatchDataSDK, tabs: TabReflective?) {
		self.sdk = sdk
		self.tabs = tabs
	}

	func createDeliveryMethodMutationAlert(
		newDeliveryMethod: DeliveryMethod,
		handlers: DeliveryMethodMutationAlertActionHandling
	) -> PDAlerting {
		let originalMethod = sdk.settings.deliveryMethod.value
		let originalQuantity = sdk.settings.quantity.rawValue
		return DeliveryMethodMutationAlert(
			sdk: self.sdk,
			tabs: self.tabs,
			originalDeliveryMethod: originalMethod,
			originalQuantity: originalQuantity,
			newDeliveryMethod: newDeliveryMethod,
			handlers: handlers
		)
	}

	func createHormoneActions(
		_ currentSite: SiteName,
		_ suggestSiteName: SiteName?,
		_ change: @escaping () -> Void,
		_ nav: @escaping () -> Void
	) -> PDAlerting {
		HormoneCellActionAlert(
			currentSite: currentSite, nextSite: suggestSiteName, changeHormone: change, nav: nav
		)
	}
}
