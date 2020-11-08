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

    func testInit_reflectsCellsInTable() {
        let deps = MockDependencies()
        _ = HormonesViewModel(
            siteImageHistory: mockHistory,
            style: style,
            alertFactory: alertFactory,
            table: mockTable,
            dependencies: deps
        )
        XCTAssertEqual(1, mockTable.reflectModelCallCount)
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

    func testUpdateSiteImages_callsTableReflectModel() {
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
        mockTable.reflectModelCallCount = 0  // Reset from init
        viewModel.updateSiteImages()
        XCTAssertEqual(1, mockTable.reflectModelCallCount)
    }

    func testUpdateSiteImages_updatesSiteImages() {
        let deps = MockDependencies()
        let sdk = MockSDK()
        (sdk.settings as! MockSettings).quantity = QuantityUD(3)
        let hormones = [MockHormone(), MockHormone(), MockHormone()]
        hormones[0].siteName = SiteStrings.LeftAbdomen
        hormones[0].deliveryMethod = .Patches
        hormones[0].siteId = UUID()
        hormones[0].siteImageId = SiteStrings.LeftAbdomen
        hormones[0].hasSite = true
        hormones[1].siteName = SiteStrings.RightAbdomen
        hormones[1].deliveryMethod = .Patches
        hormones[1].siteId = UUID()
        hormones[1].siteImageId = SiteStrings.RightAbdomen
        hormones[1].hasSite = true
        hormones[2].siteName = SiteStrings.LeftGlute
        hormones[2].deliveryMethod = .Patches
        hormones[2].siteId = UUID()
        hormones[2].siteImageId = SiteStrings.LeftGlute
        hormones[2].hasSite = true
        (sdk.hormones as! MockHormoneSchedule).all = hormones
        (sdk.settings as! MockSettings).deliveryMethod = DeliveryMethodUD(.Gel)
        deps.sdk = sdk
        let mockCells = [MockHormoneCell(), MockHormoneCell(), MockHormoneCell()]
        mockTable.cells = mockCells
        let mockRecorders = [MockSiteImageRecorder(), MockSiteImageRecorder(), MockSiteImageRecorder()]
        mockHistory.subscriptMockImplementation = { mockRecorders[$0] }

        let viewModel = HormonesViewModel(
            siteImageHistory: mockHistory,
            style: style,
            alertFactory: alertFactory,
            table: mockTable,
            dependencies: deps
        )

        // Reset mocks from init
        mockHistory.subscriptCallArgs = []
        for recorder in mockRecorders {
            recorder.pushCallArgs = []
        }
        for cell in mockCells {
            cell.reflectSiteImageCallArgs = []
        }

        // Make call
        viewModel.updateSiteImages()

        // Assertions
        XCTAssertEqual([0, 1, 2], mockHistory.subscriptCallArgs, "Iteration assertion")
        let expectedImages = [
            SiteImages.patchLeftAbdomen,
            SiteImages.patchRightAbdomen,
            SiteImages.patchLeftGlute
        ]
        let actualImages = mockRecorders.map { $0.pushCallArgs[0] }
        XCTAssertEqual(expectedImages, actualImages, "Check that image was recorded")
        let actualRecorders = mockCells.map {
            $0.reflectSiteImageCallArgs[0]
        } as! [MockSiteImageRecorder]
        XCTAssertEqual(mockRecorders, actualRecorders, "Check that recorders were applied to cell")
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
