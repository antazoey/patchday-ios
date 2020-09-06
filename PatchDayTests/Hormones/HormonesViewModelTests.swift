//
//  HormonesViewModelTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 6/13/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDMock

@testable
import PatchDay

class HormonesViewModelTests: XCTestCase {
    func testInit_callsReloadContext() {
        let table = UITableView()
        let style = UIUserInterfaceStyle.dark
        let deps = MockDependencies()
        let hormones = deps.sdk!.hormones as! MockHormoneSchedule
        let alertFactory = MockAlertFactory()
        _ = HormonesViewModel(
            hormonesTableView: table,
            style: style,
            alertFactory: alertFactory, dependencies: deps
        )
        let actual = hormones.reloadContextCallCount
        XCTAssertEqual(1, actual)
    }

    func testHandleRowTapped_whenChoosesChangeAction_callsAlertsPresentHormoneActionsWithExpectedIndex() {
        let table = UITableView()
        let style = UIUserInterfaceStyle.dark
        let deps = MockDependencies()
        let expectedSite = MockSite()
        let expectedHormone = MockHormone()
        expectedHormone.siteName = "Current site"
        expectedSite.name = "Expected site"
        (deps.sdk?.hormones as! MockHormoneSchedule).all = [expectedHormone]
        (deps.sdk?.sites as! MockSiteSchedule).suggested = expectedSite
        let alertFactory = MockAlertFactory()
        let viewModel = HormonesViewModel(
            hormonesTableView: table,
            style: style,
            alertFactory: alertFactory,
            dependencies: deps
        )
        viewModel.handleRowTapped(at: 0, UIViewController(), reload: {})
        let callArgs = alertFactory.createHormoneActionsCallArgs[0]
        XCTAssertEqual(callArgs.0, expectedHormone.siteName)
        XCTAssertEqual(callArgs.1, expectedSite.name)
    }
}
