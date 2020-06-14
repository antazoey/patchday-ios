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

	public var createHormoneActionsCallArgs: [(UIViewController, SiteName?, () -> Void, () -> Void)] = []
	public var createHormoneActionsReturnValue = MockAlert()
	public func createHormoneActions(
		_ root: UIViewController,
		_ siteName: SiteName?,
		_ change: @escaping () -> Void,
		_ nav: @escaping () -> Void
	) -> PDAlerting {
		createHormoneActionsCallArgs.append((root, siteName, change, nav))
		return createHormoneActionsReturnValue
	}
}
