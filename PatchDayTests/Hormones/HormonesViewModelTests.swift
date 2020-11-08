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

    private let table = UITableView()
    private let style = UIUserInterfaceStyle.dark
    private let alertFactory = MockAlertFactory()
    private let mockHistory = MockSiteImageHistory()
    private let mockTable = MockHormonesTable()

    func testInit_callsReloadContext() {
        let deps = MockDependencies()
        let hormones = deps.sdk!.hormones as! MockHormoneSchedule
        _ = HormonesViewModel(
            siteImageHistory: mockHistory,
            style: style,
            alertFactory: alertFactory,
            table: mockTable,
            dependencies: deps
        )
        let actual = hormones.reloadContextCallCount
        XCTAssertEqual(1, actual)
    }

    func testTitle_whenNilSdk_returnsHormonesTitle() {
        let deps = MockDependencies()
        deps.sdk = nil
        let viewModel = HormonesViewModel(
            siteImageHistory: mockHistory,
            style: style,
            alertFactory: alertFactory,
            table: mockTable,
            dependencies: deps
        )
        let expected = PDTitleStrings.HormonesTitle
        let actual = viewModel.title
        XCTAssertEqual(expected, actual)
    }

    func testTitle_whenPatches_returnsPatchesTitle() {
        let deps = MockDependencies()
        let sdk = MockSDK()
        (sdk.settings as! MockSettings).deliveryMethod = DeliveryMethodUD(.Patches)
        deps.sdk = sdk
        let viewModel = HormonesViewModel(
            siteImageHistory: mockHistory,
            style: style,
            alertFactory: alertFactory,
            table: mockTable,
            dependencies: deps
        )
        let expected = PDTitleStrings.PatchesTitle
        let actual = viewModel.title
        XCTAssertEqual(expected, actual)
    }

    func testTitle_whenInjections_returnsInjectionsTitle() {
        let deps = MockDependencies()
        let sdk = MockSDK()
        (sdk.settings as! MockSettings).deliveryMethod = DeliveryMethodUD(.Injections)
        deps.sdk = sdk
        let viewModel = HormonesViewModel(
            siteImageHistory: mockHistory,
            style: style,
            alertFactory: alertFactory,
            table: mockTable,
            dependencies: deps
        )
        let expected = PDTitleStrings.InjectionsTitle
        let actual = viewModel.title
        XCTAssertEqual(expected, actual)
    }

    func testTitle_whenGel_returnsGelTitle() {
        let deps = MockDependencies()
        let sdk = MockSDK()
        (sdk.settings as! MockSettings).deliveryMethod = DeliveryMethodUD(.Gel)
        deps.sdk = sdk
        let viewModel = HormonesViewModel(
            siteImageHistory: mockHistory,
            style: style,
            alertFactory: alertFactory,
            table: mockTable,
            dependencies: deps
        )
        let expected = PDTitleStrings.GelTitle
        let actual = viewModel.title
        XCTAssertEqual(expected, actual)
    }

    func testUpdateSiteImages() {
        let deps = MockDependencies()
        let sdk = MockSDK()
        (sdk.settings as! MockSettings).deliveryMethod = DeliveryMethodUD(.Gel)
        deps.sdk = sdk
        let viewModel = HormonesViewModel(
            siteImageHistory: mockHistory,
            style: style,
            alertFactory: alertFactory,
            table: mockTable,
            dependencies: deps
        )
        viewModel.updateSiteImages()
    }

    func testExpiredHormoneBadgeValue_whenNilHormones_returnsNil() {
        let deps = MockDependencies()
        deps.sdk = nil
        let viewModel = HormonesViewModel(
            siteImageHistory: mockHistory,
            style: style,
            alertFactory: alertFactory,
            table: mockTable,
            dependencies: deps
        )
        XCTAssertNil(viewModel.expiredHormoneBadgeValue)
    }

    func testExpiredHormoneBadgeValue_whenNoExpiredHormones_returnsNil() {
        let deps = MockDependencies()
        let sdk = MockSDK()
        (sdk.hormones as! MockHormoneSchedule).totalExpired = 0
        deps.sdk = sdk
        let viewModel = HormonesViewModel(
            siteImageHistory: mockHistory,
            style: style,
            alertFactory: alertFactory,
            table: mockTable,
            dependencies: deps
        )
        XCTAssertNil(viewModel.expiredHormoneBadgeValue)
    }

    func testExpiredHormoneBadgeValue_returnsStringifiedExpiredCount() {
        let deps = MockDependencies()
        let sdk = MockSDK()
        let expiredCount = 4
        (sdk.hormones as! MockHormoneSchedule).totalExpired = expiredCount
        deps.sdk = sdk
        let viewModel = HormonesViewModel(
            siteImageHistory: mockHistory,
            style: style,
            alertFactory: alertFactory,
            table: mockTable,
            dependencies: deps
        )
        let expected = "\(expiredCount)"
        let actual = viewModel.expiredHormoneBadgeValue
        XCTAssertEqual(expected, actual)
    }

    func testHandleRowTapped_whenChoosesChangeAction_callsAlertsPresentHormoneActionsWithExpectedIndex() {
        let deps = MockDependencies()
        let expectedSite = MockSite()
        let expectedHormone = MockHormone()
        expectedHormone.siteName = "Current site"
        expectedSite.name = "Expected site"
        (deps.sdk?.hormones as! MockHormoneSchedule).all = [expectedHormone]
        (deps.sdk?.sites as! MockSiteSchedule).suggested = expectedSite
        let viewModel = HormonesViewModel(
            siteImageHistory: mockHistory,
            style: style,
            alertFactory: alertFactory,
            table: mockTable,
            dependencies: deps
        )
        viewModel.handleRowTapped(at: 0, UIViewController(), reload: {})
        let callArgs = alertFactory.createHormoneActionsCallArgs[0]
        XCTAssertEqual(callArgs.0, expectedHormone.siteName)
        XCTAssertEqual(callArgs.1, expectedSite.name)
    }
}
