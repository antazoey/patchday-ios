//
//  File.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 5/24/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDMock
import PatchData

@testable
import PatchDay

class IntegrationTests: XCTestCase {
#if targetEnvironment(simulator)

	func testWhenChangingHormoneBadgeUpdatesCorrectly() {
		let sdk = PatchData()
		let badge = PDBadge(sdk: sdk)
		sdk.hormones.setDate(at: 0, with: DateFactory.createDate(daysFromNow: -20)!)
		sdk.hormones.setDate(at: 1, with: DateFactory.createDate(daysFromNow: -20)!)
		sdk.hormones.setDate(at: 2, with: DateFactory.createDate(daysFromNow: -20)!)
		badge.reflect()

		XCTAssertEqual(3, sdk.hormones.totalExpired)
		XCTAssertEqual(3, badge.value)

		sdk.hormones.setDate(at: 0, with: Date())
		badge.reflect()

		XCTAssertEqual(2, sdk.hormones.totalExpired)
		XCTAssertEqual(2, badge.value)
	}
#endif
}
