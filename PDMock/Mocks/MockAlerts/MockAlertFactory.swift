//
//  MockAlertFactory.swift
//  PDMock
//
//  Created by Juliya Smith on 6/14/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockAlertFactory: AlertProducing {

	public init() {}

	public var tabs: TabReflective?

	public var createDeliveryMethodMutationAlertCallArgs: [(DeliveryMethod, DeliveryMethodMutationAlertActionHandling)] = []
	public var createDeliveryMethodMutationAlertReturnValue = MockAlert()
	public func createDeliveryMethodMutationAlert(newDeliveryMethod: DeliveryMethod, handlers: DeliveryMethodMutationAlertActionHandling) -> PDAlerting {
		createDeliveryMethodMutationAlertCallArgs.append((newDeliveryMethod, handlers))
		return createDeliveryMethodMutationAlertReturnValue
	}

	public var createQuantityMutationAlertCallArgs: [(QuantityMutationAlertActionHandling, Int, Int)] = []
	public var createQuantityMutationAlertReturnValue = MockAlert()
	public func createQuantityMutationAlert(
		handlers: QuantityMutationAlertActionHandling, oldQuantity: Int, newQuantity: Int
	) -> PDAlerting {
		createQuantityMutationAlertCallArgs.append((handlers, oldQuantity, newQuantity))
		return createQuantityMutationAlertReturnValue
	}

	public var createHormoneActionsCallArgs: [(SiteName, SiteName?, () -> Void, () -> Void)] = []
	public var createHormoneActionsReturnValue = MockAlert()
	public func createHormoneActions(
		_ currentSite: SiteName,
		_ suggestSiteName: SiteName?,
		_ change: @escaping () -> Void,
		_ nav: @escaping () -> Void
	) -> PDAlerting {
		createHormoneActionsCallArgs.append((currentSite, suggestSiteName, change, nav))
		return createHormoneActionsReturnValue
	}

	public var createPillActionsCallArgs: [(Swallowable, PillCellActionHandling)] = []
	public var createPillActionsReturnValue = MockAlert()
	public func createPillActions(_ pill: Swallowable, _ handlers: PillCellActionHandling) -> PDAlerting {
		createPillActionsCallArgs.append((pill, handlers))
		return createPillActionsReturnValue
	}

	public var createNewSiteAlertCallArgs: [NewSiteAlertActionHandling] = []
	public var createNewSiteAlertReturnValue = MockAlert()
	public func createNewSiteAlert(_ handlers: NewSiteAlertActionHandling) -> PDAlerting {
		createNewSiteAlertCallArgs.append(handlers)
		return createNewSiteAlertReturnValue
	}

	public var createUnsavedAlertCallArgs: [(UIViewController, () -> Void, () -> Void)] = []
	public var createUnsavedAlertReturnValue = MockAlert()
	public func createUnsavedAlert(_ parent: UIViewController, saveAndContinueHandler: @escaping () -> Void, discardHandler: @escaping () -> Void) -> PDAlerting {
		createUnsavedAlertCallArgs.append((parent, saveAndContinueHandler, discardHandler))
		return createUnsavedAlertReturnValue
	}

	public var createDisclaimerAlertCallCount = 0
	public var createDisclaimerAlertReturnValue = MockAlert()
	public func createDisclaimerAlert() -> PDAlerting {
		createDisclaimerAlertCallCount += 1
		return createDisclaimerAlertReturnValue
	}

	public var createGenericAlertCallCount = 0
	public var createGenericAlertReturnValue = MockAlert()
	public func createGenericAlert() -> PDAlerting {
		createGenericAlertCallCount += 1
		return createGenericAlertReturnValue
	}
}
