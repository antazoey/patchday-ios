//
//  PDAlertPresenting.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol AlertDispatching {
	func presentHormoneActions(
		at row: Index,
		reload: @escaping () -> Void,
		nav: @escaping () -> Void
	)
	func presentPillActions(for pill: Swallowable, handlers: PillCellActionHandling)
	func presentDeliveryMethodMutationAlert(
		newMethod: DeliveryMethod, handlers: DeliveryMethodMutationAlertActionHandling
	)
	func presentQuantityMutationAlert(
		oldQuantity: Int, newQuantity: Int, handlers: QuantityMutationAlertActionHandling
	)
	func presentDisclaimerAlert()
	func presentNewSiteAlert(handlers: NewSiteAlertActionHandling)
	func presentGenericAlert()
	func presentUnsavedAlert(
		_ parent: UIViewController,
		saveAndContinueHandler: @escaping () -> Void,
		discardHandler: @escaping () -> Void
	)
}
