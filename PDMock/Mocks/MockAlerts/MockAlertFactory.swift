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
	public func createHormoneActions(
		_ currentSite: SiteName,
		_ suggestSiteName: SiteName?,
		_ change: @escaping () -> Void,
		_ nav: @escaping () -> Void
	) -> PDAlerting {
		createHormoneActionsCallArgs.append((currentSite, suggestSiteName, change, nav))
		return createHormoneActionsReturnValue
	}


	public init() {}

	public var createHormoneActionsCallArgs: [(SiteName, SiteName?, () -> Void, () -> Void)] = []
	public var createHormoneActionsReturnValue = MockAlert()
}
