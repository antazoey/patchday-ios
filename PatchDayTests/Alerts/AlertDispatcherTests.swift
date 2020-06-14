//
//  TestAlertDispatcher.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 6/14/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDMock

@testable
import PatchDay

class AlertDispatcherTests: XCTestCase {
	func testPresentHormoneActions_whenChoosingChange_changes() {
		let sdk = MockSDK()
		let hormones = sdk.hormones as! MockHormoneSchedule
		let sites = sdk.sites as! MockSiteSchedule
		let suggestedSite = MockSite()
		suggestedSite.name = "SUGGESTED"
		sites.suggested = suggestedSite
		let factory = MockAlertFactory()
		let tabs = MockTabs()
		let dispatcher = AlertDispatcher(sdk: sdk, factory: factory, tabs: tabs)
		dispatcher.presentHormoneActions(at: 0, reload: {}, nav: {})
		let changeAction = factory.createHormoneActionsCallArgs[0].2
		changeAction()
		let dateArgs = hormones.setDateByIndexCallArgs[0]
		XCTAssertEqual(0, dateArgs.0)
		XCTAssert(PDTest.equiv(Date(), dateArgs.1))
		let siteArgs = hormones.setSiteByIndexCallArgs[0]
		XCTAssertEqual(0, siteArgs.0)
		XCTAssertEqual(suggestedSite.id, siteArgs.1.id)
	}
}
