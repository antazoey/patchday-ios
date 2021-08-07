//
//  File.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 5/24/20.

import XCTest
import PDKit
import PDTest
import PatchData

@testable
import PatchDay

// swiftlint:disable function_body_length
class IntegrationTests: XCTestCase {

    let now = MockNow()
    private let dummyViewController = UIViewController()

#if targetEnvironment(simulator)

    private var sdk = PatchData()

    override func setUp() {
        sdk.resetAll()
    }

    func beforeEach() {
        sdk.resetAll()
    }

    // MARK: - ADD INTEGRATION TESTS HERE

    var tests: [() -> Void] {
        [
            whenTakingHormoneFromActionAlert_setsNotificationWithUpdatedDate,
            whenChangingHormoneBadge_updatesCorrectly,
            whenContinuingOnChangeDeliveryMethodAlert_addsOrRemoveHormonesToGetToDefaultQuantity,
            cyclesThroughPillExpirationIntervalXDaysOnXDaysOffCorrectly
        ]
    }

    // MARK: - Synchronous Test Runner

    func test_runAll() {
        for test in tests {
            beforeEach()
            test()
        }
    }

    // MARK: - Integration Test Implementations

    func whenChangingHormoneBadge_updatesCorrectly() {
        let badge = PDBadge(sdk: sdk)
        sdk.settings.setDeliveryMethod(to: .Patches)  // Should trigger reset to 3 patches
        let ids = self.sdk.hormones.all.map({ $0.id })
        if ids.count < 3 {
            XCTFail("Hormone count does not match delivery method")
            return
        }
        sdk.hormones.setDate(by: ids[0], with: DateFactory.createDate(daysFrom: -20)!)
        sdk.hormones.setDate(by: ids[1], with: DateFactory.createDate(daysFrom: -20)!)
        sdk.hormones.setDate(by: ids[2], with: DateFactory.createDate(daysFrom: -20)!)
        badge.reflect()

        XCTAssertEqual(3, sdk.hormones.totalExpired)
        XCTAssertEqual(3, badge.value)

        sdk.hormones.setDate(at: 0, with: Date())
        badge.reflect()

        XCTAssertEqual(2, sdk.hormones.totalExpired)
        XCTAssertEqual(2, badge.value)
    }

    func whenContinuingOnChangeDeliveryMethodAlert_addsOrRemoveHormonesToGetToDefaultQuantity() {
        let tabs = TabReflector(
            tabBarController: UITabBarController(),
            viewControllers: [UIViewController()],
            sdk: sdk
        )
        let handlers = DeliveryMethodMutationAlertActionHandler { (_, _) in () }
        let patchesToGelAlert = DeliveryMethodMutationAlert(
            sdk: sdk,
            tabs: tabs,
            originalDeliveryMethod: .Patches,
            originalQuantity: sdk.settings.quantity.rawValue,
            newDeliveryMethod: .Gel,
            handlers: handlers
        )
        patchesToGelAlert.continueHandler()
        XCTAssertEqual(1, sdk.hormones.count)
        XCTAssertEqual(1, sdk.settings.quantity.rawValue)

        let injectionsToPatchesAlert = DeliveryMethodMutationAlert(
            sdk: sdk,
            tabs: tabs,
            originalDeliveryMethod: .Injections,
            originalQuantity: 4,
            newDeliveryMethod: .Patches,
            handlers: handlers
        )
        injectionsToPatchesAlert.continueHandler()
        XCTAssertEqual(3, sdk.hormones.count)
        XCTAssertEqual(3, sdk.settings.quantity.rawValue)
    }

    /// PillExpiraionInterval XDaysOnXdaysOff test.
    /// This is a particularly complex schedule that warrants its own integration test.
    func cyclesThroughPillExpirationIntervalXDaysOnXDaysOffCorrectly() {
        let dependencies = MockDependencies()
        dependencies.sdk = sdk
        let now = MockNow()
        let tableView = UITableView()
        let alertFactory = AlertFactory(sdk: sdk, tabs: dependencies.tabs)
        let mockPillsTable = MockPillsTable()
        let listViewModel = PillsViewModel(
            pillsTableView: tableView,
            alertFactory: alertFactory,
            table: mockPillsTable,
            dependencies: dependencies
        )

        // Create new pill from the Pills View.
        listViewModel.goToNewPillDetails(pillsViewController: dummyViewController)
        let expectedCount = 3

        // Verify new pill was created - 2 defaults + 1 new one
        XCTAssertEqual(expectedCount, sdk.pills.count)

        // Initial details viewModel
        let newIndex = expectedCount - 1
        let detailsViewModel = PillDetailViewModel(
            newIndex, dependencies: dependencies, now: now
        )

        let pillSchedule = dependencies.sdk!.pills as! PillSchedule

        // Select expiration interval of .XDaysOnXDaysOff
        let intervalOptions = PillStrings.Intervals.all
        guard let indexToSelect = intervalOptions.firstIndex(
            where: { $0 == PillStrings.Intervals.XDaysOnXDaysOff }
        ) else {
            XCTFail("Unable to select .XDaysOnXDaysOff")
            return
        }
        detailsViewModel.selectExpirationInterval(indexToSelect)
        XCTAssertEqual(.XDaysOnXDaysOff, detailsViewModel.expirationInterval)
        XCTAssertEqual("Days on:", detailsViewModel.daysOneLabelText)
        XCTAssertEqual("Days off:", detailsViewModel.daysTwoLabelText)

        // Select 3 days on and 3 days off
        detailsViewModel.selectFromDaysPicker(2, daysNumber: 1)
        detailsViewModel.selectFromDaysPicker(2, daysNumber: 2)
        XCTAssertEqual("3", detailsViewModel.daysOn)
        XCTAssertEqual("3", detailsViewModel.daysOff)
        detailsViewModel.save()

        // MARK: - Day 1, On
        XCTAssertEqual("Current position: 1 of 3 (on)", detailsViewModel.daysPositionText)
        listViewModel.takePill(at: newIndex)
        XCTAssertEqual("Current position: 1 of 3 (on)", detailsViewModel.daysPositionText)
        XCTAssertEqual(1, detailsViewModel.pill!.timesTakenToday)

        guard var detailsViewModel = fastForwardDayForXDaysSchedule(
            day: 1, hour: 0, pillSchedule, dependencies, newIndex
        ) else {
            return
        }

        // MARK: - Day 2, On
        listViewModel.takePill(at: newIndex)
        detailsViewModel = PillDetailViewModel(newIndex, dependencies: dependencies, now: now)
        XCTAssertEqual("Current position: 3 of 3 (on)", detailsViewModel.daysPositionText)
        XCTAssertEqual(1, detailsViewModel.pill!.timesTakenToday)

        guard var detailsViewModel = fastForwardDayForXDaysSchedule(
            day: 2, hour: 0, pillSchedule, dependencies, newIndex
        ) else {
            return
        }

        // MARK: - Day 3, On
        listViewModel.takePill(at: newIndex)
        detailsViewModel = PillDetailViewModel(newIndex, dependencies: dependencies, now: now)
        XCTAssertEqual("Current position: 1 of 3 (off)", detailsViewModel.daysPositionText)
        XCTAssertEqual(1, detailsViewModel.pill!.timesTakenToday)

        guard var detailsViewModel = fastForwardDayForXDaysSchedule(
            day: 3, hour: 0, pillSchedule, dependencies, newIndex
        ) else {
            return
        }

        // MARK: - Day 4, Off
        detailsViewModel = PillDetailViewModel(newIndex, dependencies: dependencies, now: now)
        XCTAssertEqual("Current position: 1 of 3 (off)", detailsViewModel.daysPositionText)
        XCTAssertEqual(1, detailsViewModel.pill!.timesTakenToday)

        guard var detailsViewModel = fastForwardDayForXDaysSchedule(
            day: 4, hour: 0, pillSchedule, dependencies, newIndex
        ) else {
            return
        }

        // MARK: - Day 5, Off
        detailsViewModel = PillDetailViewModel(newIndex, dependencies: dependencies, now: now)
        XCTAssertEqual("Current position: 2 of 3 (off)", detailsViewModel.daysPositionText)
        XCTAssertEqual(1, detailsViewModel.pill!.timesTakenToday)

        guard var detailsViewModel = fastForwardDayForXDaysSchedule(
            day: 5, hour: 0, pillSchedule, dependencies, newIndex
        ) else {
            return
        }

        // MARK: - Day 6, Off
        detailsViewModel = PillDetailViewModel(newIndex, dependencies: dependencies, now: now)
        XCTAssertEqual("Current position: 3 of 3 (off)", detailsViewModel.daysPositionText)
        XCTAssertEqual(1, detailsViewModel.pill!.timesTakenToday)

        guard var detailsViewModel = fastForwardDayForXDaysSchedule(
            day: 6, hour: 0, pillSchedule, dependencies, newIndex
        ) else {
            return
        }

        // MARK: - Day 7, Off
        detailsViewModel = PillDetailViewModel(newIndex, dependencies: dependencies, now: now)
        XCTAssertEqual("Current position: 3 of 3 (off)", detailsViewModel.daysPositionText)
        XCTAssertEqual(1, detailsViewModel.pill!.timesTakenToday)

        guard fastForwardDayForXDaysSchedule(
            day: 7, hour: 0, pillSchedule, dependencies, newIndex
        ) != nil else {
            return
        }
    }

    func whenTakingHormoneFromActionAlert_setsNotificationWithUpdatedDate() {
        guard let hormone = sdk.hormones[0] else {
            XCTFail("This test required a hormone.")
            return
        }

        let notifications = MockNotifications()
        let alerts = MockAlertFactory()
        let testDate = DateFactory.createDate(byAddingHours: -2, to: Date())!
        let now = PDNow()
        let style = UIUserInterfaceStyle.dark
        let table = HormonesTable(UITableView(), sdk, style)
        let imageHistory = SiteImageHistory()
        let dependencies = MockDependencies()
        sdk.settings.setUseStaticExpirationTime(to: false)
        dependencies.sdk = sdk
        dependencies.notifications = notifications
        dependencies.alerts = alerts

        // Start off a hormone with a date.
        sdk.hormones.setDate(by: hormone.id, with: testDate)

        let hormonesViewModel = HormonesViewModel(
            siteImageHistory: imageHistory,
            style: style,
            table: table,
            dependencies: dependencies,
            now: now
        )

        hormonesViewModel.handleRowTapped(at: 0, dummyViewController) {}
        guard let hormoneAfterTest = sdk.hormones[hormone.id] else {
            XCTFail("Hormone somehow disappeared during test.")
            return
        }

        let changeAction = alerts.createHormoneActionsCallArgs[0].2
        changeAction()  // Simulates user selecting "Change" from the alert

        let actual = hormoneAfterTest.date
        PDAssertNotEquiv(testDate, actual)
    }

#endif

    private func fastForwardDayForXDaysSchedule(
        day: Int, hour: Int, _ pillSchedule: PillSchedule, _ dependencies: MockDependencies, _ newIndex: Index
    ) -> PillDetailViewModel? {
        now.now = TestDateFactory.createTestDate(daysFrom: day, hoursFrom: hour)
        pillSchedule._now = now
        for swallowable in pillSchedule.all {
            let pill = swallowable as! Pill
            pill._now = now
        }
        sdk.pills.awaken()
        let detailsViewModel = PillDetailViewModel(newIndex, dependencies: dependencies, now: now)

        // Verify the new day and the same position
        XCTAssertEqual(0, detailsViewModel.pill!.timesTakenToday)

        let isOn = [4, 5, 6].contains(day) ? "off" : "on"
        var day = day
        if day > 3 {
            day = (day + 1) % 3
        }

        let expected = "Current position: \(day) of 3 (\(isOn))"
        let actual = detailsViewModel.daysPositionText
        if expected != actual {
            XCTFail("\(expected) not equal to \(actual)")
            return nil
        }
        return detailsViewModel
    }
}
// swiftlint:enable function_body_length
