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

	public var factory: AlertProducing = MockAlertFactory()

	public init() {}
	
	public var presentDisclaimerAlertCallCount = 0
	public func presentDisclaimerAlert() {
		presentDisclaimerAlertCallCount += 1
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
