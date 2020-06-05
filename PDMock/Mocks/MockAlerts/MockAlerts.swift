//
//  MockAlerts.swift
//  PDMock
//
//  Created by Juliya Smith on 5/10/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockAlerts: AlertDispatching {
	
	public init() {}
	
	public var presentPillActionsCallArgs: [(Swallowable, PillCellActionHandling)] = []
	public func presentPillActions(for pill: Swallowable, handlers: PillCellActionHandling) {
		presentPillActionsCallArgs.append((pill, handlers))
	}
	
	public var presentDeliveryMethodMutationAlertCallArgs: [(DeliveryMethod, DeliveryMethodMutationAlertActionHandling)] = []
	public func presentDeliveryMethodMutationAlert(newMethod: DeliveryMethod, handlers: DeliveryMethodMutationAlertActionHandling) {
		presentDeliveryMethodMutationAlertCallArgs.append((newMethod, handlers))
	}
	
	public var presentQuantityMutationAlertCallArgs: [(Int, Int, QuantityMutationAlertActionHandling)] = []
	public func presentQuantityMutationAlert(oldQuantity: Int, newQuantity: Int, handlers: QuantityMutationAlertActionHandling) {
		presentQuantityMutationAlertCallArgs.append((oldQuantity, newQuantity, handlers))
	}
	
	public var presentDisclaimerAlertCallCount = 0
	public func presentDisclaimerAlert() {
		presentDisclaimerAlertCallCount += 1
	}
	
	public var presentNewSiteAlertCallArgs: [NewSiteAlertActionHandling] = []
	public func presentNewSiteAlert(handlers: NewSiteAlertActionHandling) {
		presentNewSiteAlertCallArgs.append(handlers)
	}
	
	public var presentGenericAlertCallCount = 0
	public func presentGenericAlert() {
		presentGenericAlertCallCount += 1
	}

	public var presentUnsavedAlertCallArgs: [(UIViewController, () -> Void, () -> Void)] = []
	public func presentUnsavedAlert(
		_ parent: UIViewController,
		saveAndContinueHandler: @escaping () -> Void,
		discardHandler: @escaping () -> Void
	) {
		presentUnsavedAlertCallArgs.append((parent, saveAndContinueHandler, discardHandler))
	}
}
