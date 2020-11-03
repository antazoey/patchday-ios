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

    func testTitle_whenNilSdk_returnsHormonesTitle() {
        let table = UITableView()
        let deps = MockDependencies()
        let style = UIUserInterfaceStyle.dark
        deps.sdk = nil
        let alertFactory = MockAlertFactory()
        let viewModel = HormonesViewModel(
            hormonesTableView: table,
            style: style,
            alertFactory: alertFactory,
            dependencies: deps
        )
        let expected = PDTitleStrings.HormonesTitle
        let actual = viewModel.title
        XCTAssertEqual(expected, actual)
    }

    func testTitle_whenPatches_returnsPatchesTitle() {
        let table = UITableView()
        let deps = MockDependencies()
        let style = UIUserInterfaceStyle.dark
        let sdk = MockSDK()
        (sdk.settings as! MockSettings).deliveryMethod = DeliveryMethodUD(.Patches)
        deps.sdk = sdk
        let alertFactory = MockAlertFactory()
        let viewModel = HormonesViewModel(
            hormonesTableView: table,
            style: style,
            alertFactory: alertFactory,
            dependencies: deps
        )
        let expected = PDTitleStrings.PatchesTitle
        let actual = viewModel.title
        XCTAssertEqual(expected, actual)
    }

    func testTitle_whenInjections_returnsInjectionsTitle() {
        let table = UITableView()
        let deps = MockDependencies()
        let style = UIUserInterfaceStyle.dark
        let sdk = MockSDK()
        (sdk.settings as! MockSettings).deliveryMethod = DeliveryMethodUD(.Injections)
        deps.sdk = sdk
        let alertFactory = MockAlertFactory()
        let viewModel = HormonesViewModel(
            hormonesTableView: table,
            style: style,
            alertFactory: alertFactory,
            dependencies: deps
        )
        let expected = PDTitleStrings.InjectionsTitle
        let actual = viewModel.title
        XCTAssertEqual(expected, actual)
    }

    func testTitle_whenGel_returnsGelTitle() {
        let table = UITableView()
        let deps = MockDependencies()
        let style = UIUserInterfaceStyle.dark
        let sdk = MockSDK()
        (sdk.settings as! MockSettings).deliveryMethod = DeliveryMethodUD(.Gel)
        deps.sdk = sdk
        let alertFactory = MockAlertFactory()
        let viewModel = HormonesViewModel(
            hormonesTableView: table,
            style: style,
            alertFactory: alertFactory,
            dependencies: deps
        )
        let expected = PDTitleStrings.GelTitle
        let actual = viewModel.title
        XCTAssertEqual(expected, actual)
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
