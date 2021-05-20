//
//  HormonesViewModelTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 6/13/20.

import XCTest
import PDKit
import PDTest

@testable
import PatchDay

class HormonesViewModelTests: XCTestCase {

    private let table = UITableView()
    private let style = UIUserInterfaceStyle.dark
    private let mockNow: NowProtocol = MockNow()
    private let mockHistory = MockSiteImageHistory()
    private let mockTable = MockHormonesTable()
    private let mockDeps = MockDependencies()
    private let deliveryMethodToSiteNames: [DeliveryMethod: [String]] = [
        .Patches: [
            SiteStrings.LeftAbdomen,
            SiteStrings.RightAbdomen,
            SiteStrings.LeftGlute
        ],
        .Injections: [SiteStrings.LeftDelt],
        .Gel: [SiteStrings.Arms]
    ]
    private let mockHormones: [MockHormone] = [
        MockHormone(),
        MockHormone(),
        MockHormone()
    ]
    private let mockCells = [
        MockHormoneCell(),
        MockHormoneCell(),
        MockHormoneCell()
    ]
    private let mockRecorders = [
        MockSiteImageRecorder(),
        MockSiteImageRecorder(),
        MockSiteImageRecorder()
    ]

    private func setUpRealisticSchedule(
        resetMocksAfterInit: Bool=true, deliveryMethod: DeliveryMethod = .Patches
    ) -> HormonesViewModel {
        let siteNames = deliveryMethodToSiteNames[deliveryMethod]!
        for i in 0..<siteNames.count {
            let hormone = mockHormones[i]
            let siteName = siteNames[i]
            hormone.siteName = siteName
            hormone.siteImageId = siteName
            hormone.siteId = UUID()
            hormone.hasSite = true
            hormone.deliveryMethod = deliveryMethod
        }
        let sdk = mockDeps.sdk!
        let q = deliveryMethod == .Patches ? 3 : 1
        (sdk.settings as! MockSettings).quantity = QuantityUD(q)
        (sdk.hormones as! MockHormoneSchedule).all = Array(mockHormones[0..<siteNames.count])
        (sdk.settings as! MockSettings).deliveryMethod = DeliveryMethodUD(deliveryMethod)
        mockTable.cells = Array(mockCells[0..<siteNames.count])
        mockHistory.subscriptMockImplementation = { self.mockRecorders[$0] }

        let viewModel = HormonesViewModel(
            siteImageHistory: mockHistory,
            style: style,
            table: mockTable,
            dependencies: mockDeps,
            now: mockNow
        )

        if resetMocksAfterInit {
            // Reset mocks from init
            mockHistory.subscriptCallArgs = []
            for recorder in mockRecorders {
                recorder.pushCallArgs = []
            }
            for cell in mockCells {
                cell.reflectSiteImageCallArgs = []
            }
        }
        return viewModel
    }

    func testInit_callsReloadContext() {
        let deps = MockDependencies()
        let hormones = deps.sdk!.hormones as! MockHormoneSchedule
        _ = HormonesViewModel(
            siteImageHistory: mockHistory,
            style: style,
            table: mockTable,
            dependencies: deps,
            now: mockNow
        )
        let actual = hormones.reloadContextCallCount
        XCTAssertEqual(1, actual)
    }

    func testInit_reflectsCellsInTable() {
        let deps = MockDependencies()
        _ = HormonesViewModel(
            siteImageHistory: mockHistory,
            style: style,
            table: mockTable,
            dependencies: deps,
            now: mockNow
        )
        XCTAssertEqual(1, mockTable.reflectModelCallCount)
    }

    func testTitle_whenNilSdk_returnsHormonesTitle() {
        let deps = MockDependencies()
        deps.sdk = nil
        let viewModel = HormonesViewModel(
            siteImageHistory: mockHistory,
            style: style,
            table: mockTable,
            dependencies: deps,
            now: mockNow
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
            table: mockTable,
            dependencies: deps,
            now: mockNow
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
            table: mockTable,
            dependencies: deps,
            now: mockNow
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
            table: mockTable,
            dependencies: deps,
            now: mockNow
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
            table: mockTable,
            dependencies: deps,
            now: mockNow
        )
        mockTable.reflectModelCallCount = 0  // Reset from init
        viewModel.updateSiteImages()
        XCTAssertEqual(1, mockTable.reflectModelCallCount)
    }

    func testUpdateSiteImages_whenPatches_updatesSiteImages() {
        let viewModel = setUpRealisticSchedule(resetMocksAfterInit: true, deliveryMethod: .Patches)
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

    func testUpdateSiteImages_whenInjections_updatesSiteImage() {
        let viewModel = setUpRealisticSchedule(
            resetMocksAfterInit: true, deliveryMethod: .Injections
        )
        // Make call
        viewModel.updateSiteImages()

        // Assertions
        XCTAssertEqual([0], mockHistory.subscriptCallArgs, "Iteration assertion")
        let expectedImages = [
            SiteImages.injectionLeftDelt
        ]
        let actualImages = [mockRecorders[0].pushCallArgs[0]]
        XCTAssertEqual(expectedImages, actualImages, "Check that image was recorded")
        let actualRecorders = [mockCells[0].reflectSiteImageCallArgs[0] as! MockSiteImageRecorder]
        XCTAssertEqual([mockRecorders[0]], actualRecorders, "Check that recorders were applied to cell")
    }

    func testUpdateSiteImages_whenGel_updatesSiteImage() {
        let viewModel = setUpRealisticSchedule(
            resetMocksAfterInit: true, deliveryMethod: .Gel
        )
        // Make call
        viewModel.updateSiteImages()

        // Assertions
        XCTAssertEqual([0], mockHistory.subscriptCallArgs, "Iteration assertion")
        let expectedImages = [
            SiteImages.arms
        ]
        let actualImages = [mockRecorders[0].pushCallArgs[0]]
        XCTAssertEqual(expectedImages, actualImages, "Check that image was recorded")
        let actualRecorders = [mockCells[0].reflectSiteImageCallArgs[0] as! MockSiteImageRecorder]
        XCTAssertEqual([mockRecorders[0]], actualRecorders, "Check that recorders were applied to cell")
    }

    func testExpiredHormoneBadgeValue_whenNilHormones_returnsNil() {
        let deps = MockDependencies()
        deps.sdk = nil
        let viewModel = HormonesViewModel(
            siteImageHistory: mockHistory,
            style: style,
            table: mockTable,
            dependencies: deps,
            now: mockNow
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
            table: mockTable,
            dependencies: deps,
            now: mockNow
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
            table: mockTable,
            dependencies: deps,
            now: mockNow
        )
        let expected = "\(expiredCount)"
        let actual = viewModel.expiredHormoneBadgeValue
        XCTAssertEqual(expected, actual)
    }

    func testHandleRowTapped_reloadsSiteData() {
        let viewModel = setUpRealisticSchedule()
        viewModel.handleRowTapped(at: 0, UIViewController(), reload: {})
        let actual = (mockDeps.sdk!.sites as! MockSiteSchedule).reloadContextCallCount
        XCTAssertEqual(1, actual)
    }

    func testHandleRowTapped_whenChangeActionChosen_doesExpectedActions() {
        let expectedSite = MockSite()
        let expectedHormone = MockHormone()
        (mockDeps.sdk?.hormones as! MockHormoneSchedule).all = [expectedHormone]
        (mockDeps.sdk?.sites as! MockSiteSchedule).suggested = expectedSite
        let viewModel = HormonesViewModel(
            siteImageHistory: mockHistory,
            style: style,
            table: mockTable,
            dependencies: mockDeps,
            now: mockNow
        )
        var handleCalled = false
        viewModel.handleRowTapped(at: 0, UIViewController()) {
            handleCalled = true
        }
        let changeAction = (mockDeps.alerts as! MockAlertFactory).createHormoneActionsCallArgs[0].2
        changeAction()  // Simulates user selecting "Change" from the alert
        let mockHormones = mockDeps.sdk!.hormones as! MockHormoneSchedule
        let tabsReloaded = (mockDeps.tabs as! MockTabs).reflectHormonesCallCount == 1
        let badgeReflected = (mockDeps.badge as! MockBadge).reflectCallCount == 1
        let notificationCallArgs = (mockDeps.notifications as! MockNotifications)
            .requestExpiredHormoneNotificationCallArgs
        let setDateCallArgs = mockHormones.setDateByIdCallArgs
        let setSiteCallArgs = mockHormones.setSiteByIdCallArgs
        XCTAssertTrue(tabsReloaded)
        XCTAssertTrue(handleCalled)
        XCTAssertTrue(badgeReflected)
        XCTAssertEqual(1, notificationCallArgs.count)
        XCTAssertEqual(notificationCallArgs[0].id, expectedHormone.id)
        XCTAssertEqual(1, setDateCallArgs.count)
        XCTAssertEqual(1, setSiteCallArgs.count)
    }

    func testHandleRowTapped_whenEditActionChosen_doesExpectedActions() {
        let expectedHormone = MockHormone()
        (mockDeps.sdk!.hormones as! MockHormoneSchedule).all = [expectedHormone]
        let viewModel = HormonesViewModel(
            siteImageHistory: mockHistory,
            style: style,
            table: mockTable,
            dependencies: mockDeps,
            now: mockNow
        )
        let viewController = UIViewController()
        viewModel.handleRowTapped(at: 0, viewController, reload: {})
        let editAction = (mockDeps.alerts as! MockAlertFactory).createHormoneActionsCallArgs[0].3
        editAction()  // Simulates user selecting "Edit" from the alert
        let callArgs = (mockDeps.nav as! MockNav).goToHormoneDetailsCallArgs
        XCTAssertEqual(1, callArgs.count)
        XCTAssertEqual(0, callArgs[0].0)
        XCTAssertEqual(viewController, callArgs[0].1)
    }

    func testHandleRowTapped_whenNilSdk_doesNotCallReloadOrCreateAlert() {
        let deps = MockDependencies()
        deps.sdk = nil
        let viewModel = HormonesViewModel(
            siteImageHistory: mockHistory,
            style: style,
            table: mockTable,
            dependencies: deps,
            now: mockNow
        )
        var reloadCalled = false
        viewModel.handleRowTapped(at: 0, UIViewController()) {
            reloadCalled = true
        }
        let callArgs = (mockDeps.alerts as! MockAlertFactory).createHormoneActionsCallArgs
        XCTAssertFalse(reloadCalled)
        XCTAssertEqual(0, callArgs.count)
    }

    func testPresentDisclaimerIfFirstLaunch_ifNilSdk_doesNothing() {
        mockDeps.sdk = nil
        let viewModel = HormonesViewModel(
            siteImageHistory: mockHistory,
            style: style,
            table: mockTable,
            dependencies: mockDeps,
            now: mockNow
        )
        viewModel.presentDisclaimerAlertIfFirstLaunch()
        let actual = (mockDeps.alerts as! MockAlertFactory).createDisclaimerAlertCallCount
        XCTAssertEqual(0, actual)
    }

    func testPresentDisclaimerIfFirstLaunch_whenAlreadyMentioned_doesNothing() {
        (mockDeps.sdk?.settings as! MockSettings).mentionedDisclaimer = MentionedDisclaimerUD(true)
        let viewModel = HormonesViewModel(
            siteImageHistory: mockHistory,
            style: style,
            table: mockTable,
            dependencies: mockDeps,
            now: mockNow
        )
        viewModel.presentDisclaimerAlertIfFirstLaunch()
        let actual = (mockDeps.alerts as! MockAlertFactory).createDisclaimerAlertCallCount
        XCTAssertEqual(0, actual)
    }

    func testPresentDisclaimerIfFirstLaunch_whenNotYetMentioned_presentsDisclaimer() {
        (mockDeps.sdk?.settings as! MockSettings).mentionedDisclaimer = MentionedDisclaimerUD(false)
        let viewModel = HormonesViewModel(
            siteImageHistory: mockHistory,
            style: style,
            table: mockTable,
            dependencies: mockDeps,
            now: mockNow
        )
        viewModel.presentDisclaimerAlertIfFirstLaunch()
        let mockAlerts = mockDeps.alerts as! MockAlertFactory
        let actual = mockAlerts.createDisclaimerAlertCallCount
        XCTAssertEqual(1, actual)
        XCTAssertEqual(1, mockAlerts.createDisclaimerAlertReturnValue.presentCallCount)
    }

    func testPresentDisclaimerIfFirstLaunch_whenNotYetMentioned_setsMentionedToTrue() {
        let mockSettings = mockDeps.sdk?.settings as! MockSettings
        mockSettings.mentionedDisclaimer = MentionedDisclaimerUD(false)
        let viewModel = HormonesViewModel(
            siteImageHistory: mockHistory,
            style: style,
            table: mockTable,
            dependencies: mockDeps,
            now: mockNow
        )
        viewModel.presentDisclaimerAlertIfFirstLaunch()
        XCTAssertEqual(1, mockSettings.setMentionedDisclaimerCallArgs.count)
        XCTAssertTrue(mockSettings.setMentionedDisclaimerCallArgs[0])
    }

    func testSubscript_whenCellExists_returnsCell() {
        let viewModel = setUpRealisticSchedule()  // Has 3 cells
        let actual = viewModel[2] as! MockHormoneCell
        let expected = mockCells[2]
        XCTAssertEqual(expected, actual)
    }

    func testSubscript_whenOutsideIndexRange_returnsBlankCell() {
        let viewModel = setUpRealisticSchedule()  // Has 3 cells
        // Returns blank HormoneCell type if out of range
        let actual = viewModel[5] as? HormoneCell
        XCTAssertNotNil(actual)
    }

    func testGoToHormoneDetails_navigates() {
        let viewModel = setUpRealisticSchedule()
        let testIndex = 2
        let viewController = UIViewController()
        viewModel.goToHormoneDetails(hormoneIndex: testIndex, viewController)
        let callArgs = (mockDeps.nav as! MockNav).goToHormoneDetailsCallArgs
        XCTAssertEqual(testIndex, callArgs[0].0)
        XCTAssertEqual(viewController, callArgs[0].1)
    }
}
