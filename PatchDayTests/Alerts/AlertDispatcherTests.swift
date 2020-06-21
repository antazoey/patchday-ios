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
		let hormone = MockHormone()
		hormones.all = [hormone]
		let sites = sdk.sites as! MockSiteSchedule
		let suggestedSite = MockSite()
		suggestedSite.name = "SUGGESTED"
		sites.suggested = suggestedSite
		let factory = MockAlertFactory()
		let tabs = MockTabs()
		let dispatcher = AlertDispatcher(sdk: sdk, factory: factory, tabs: tabs)

		// Test call
		dispatcher.presentHormoneActions(at: 0, reload: {}, nav: {})

		let changeAction = factory.createHormoneActionsCallArgs[0].2
		changeAction()
		let dateArgs = hormones.setDateByIdCallArgs[0]
		XCTAssertEqual(hormone.id, dateArgs.0)
		XCTAssert(PDTest.equiv(Date(), dateArgs.1))
		let siteArgs = hormones.setSiteByIdCallArgs[0]
		XCTAssertEqual(hormone.id, siteArgs.0)
		XCTAssertEqual(suggestedSite.id, siteArgs.1.id)
	}

	func testPresentHormoneActions_whenChoosingChangeWithoutSuggestedSite_stillCallsReload() {
		let sdk = MockSDK()
		let hormones = sdk.hormones as! MockHormoneSchedule
		let hormone = MockHormone()
		hormones.all = [hormone]
		let sites = sdk.sites as! MockSiteSchedule
		sites.suggested = nil
		let factory = MockAlertFactory()
		let tabs = MockTabs()
		let dispatcher = AlertDispatcher(sdk: sdk, factory: factory, tabs: tabs)
		var reloadCalled = false
		let dumbReload = { reloadCalled = true }
		dispatcher.presentHormoneActions(at: 0, reload: dumbReload, nav: {})
		let changeAction = factory.createHormoneActionsCallArgs[0].2
		changeAction()
		XCTAssert(reloadCalled)
	}
}
