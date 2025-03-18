//
//  IntegrationTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 5/24/20.

import XCTest
import PDKit
import PDTest
import PatchData

@testable
import PatchDay

// swiftlint:disable type_name
class WhenChangingHormoneBadge_UpdatesCorrectly: PDIntegrationTestCase {
    func test() async {
        sdk.settings.setDeliveryMethod(to: .Patches)
        let badge = PDBadge(sdk: sdk)
        let ids = getIDs()
        setDate(idIndex: 0, ids: ids)
        setDate(idIndex: 1, ids: ids)
        setDate(idIndex: 2, ids: ids)
        badge.reflect()

        // Waiting because it seems to take some time to relfect in the badge.
        do {
            try await Task.sleep(nanoseconds: 2_000_000_000)
        } catch {
            XCTFail("Sleep failed with error: \(error)")
        }
        self.assertBadgeValue(expected: 3, badge: badge)

        sdk.hormones.setDate(at: 0, with: Date())
        badge.reflect()

        // Waiting because it seems to take some time to relfect in the badge.
        do {
            try await Task.sleep(nanoseconds: 2_000_000_000)
        } catch {
            XCTFail("Sleep failed with error: \(error)")
        }
        self.assertBadgeValue(expected: 2, badge: badge)
    }

    private func getIDs() -> [UUID] {
        let ids = sdk.hormones.all.map({ $0.id })
        if ids.count < 3 {
            XCTFail("Hormone count does not match delivery method")
            return []
        }
        return ids
    }

    private func setDate(idIndex: Index, ids: [UUID]) {
        let testDate = TestDateFactory.createTestDate(daysFrom: -20)
        guard let pillId = ids.tryGet(at: idIndex) else {
            XCTFail("No hormone ID at index \(idIndex)")
            return
        }
        sdk.hormones.setDate(by: pillId, with: testDate)
    }

    private func assertBadgeValue(expected: Int, badge: PDBadge) {
        XCTAssertEqual(expected, sdk.hormones.totalExpired)
        XCTAssertEqual(expected, badge.value)
    }
}

class WhenContinuingOnChangeDeliveryMethodAlert_addsOrRemoveHormonesToGetToDefaultQuantity: PDIntegrationTestCase {
    func test() {
        let tabs = createTabs()
        let handlers = createHandlers()
        let patchesToGelAlert = createAlert(
            tabs: tabs,
            startDeliveryMethod: .Patches,
            newDeliveryMethod: .Gel,
            originalQuantity: sdk.settings.quantity.rawValue,
            handlers: handlers
        )
        patchesToGelAlert.continueHandler()
        assertQuantity(1)
        let injectionsToPatchesAlert = createAlert(
            tabs: tabs,
            startDeliveryMethod: .Injections,
            newDeliveryMethod: .Patches,
            originalQuantity: 4,
            handlers: handlers
        )
        injectionsToPatchesAlert.continueHandler()
        assertQuantity(3)
    }

    func createTabs() -> TabReflector {
        TabReflector(
            tabBarController: UITabBarController(),
            viewControllers: [UIViewController()],
            sdk: sdk
        )
    }

    func createHandlers() -> DeliveryMethodMutationAlertActionHandler {
        DeliveryMethodMutationAlertActionHandler { (_, _) in () }
    }

    func createAlert(
        tabs: TabReflector,
        startDeliveryMethod: DeliveryMethod,
        newDeliveryMethod: DeliveryMethod,
        originalQuantity: Int,
        handlers: DeliveryMethodMutationAlertActionHandler
    ) -> DeliveryMethodMutationAlert {
        DeliveryMethodMutationAlert(
            sdk: sdk,
            tabs: tabs,
            originalDeliveryMethod: startDeliveryMethod,
            originalQuantity: originalQuantity,
            newDeliveryMethod: newDeliveryMethod,
            handlers: handlers
        )
    }

    func assertQuantity(_ expected: Int) {
        XCTAssertEqual(expected, sdk.hormones.count)
        XCTAssertEqual(expected, sdk.settings.quantity.rawValue)
    }
}

class WhenTakingHormoneFromActionAlert_setsNotificationWithUpdatedDate: PDIntegrationTestCase {

    let style = UIUserInterfaceStyle.dark
    let notifications = MockNotifications()
    let alerts = MockAlertFactory()
    let testDate = DateFactory.createDate(byAddingHours: -2, to: Date())!

    func test() {
        guard let hormone = sdk.hormones[0] else {
            XCTFail("This test required a hormone.")
            return
        }
        setUpTest(hormone: hormone)
        let viewModel = createViewModel()
        let hormoneAfterTest = tapRowAndGetHormone(viewModel: viewModel, hormone: hormone)
        userSelectChangeAction()
        let actual = hormoneAfterTest.date
        PDAssertNotEquiv(testDate, actual)
    }

    private func setUpTest(hormone: Hormonal) {
        sdk.settings.setUseStaticExpirationTime(to: false)
        dependencies.sdk = sdk
        dependencies.notifications = notifications
        dependencies.alerts = alerts

        // Start a hormone with a date
        sdk.hormones.setDate(by: hormone.id, with: testDate)
    }

    private func createViewModel() -> HormonesViewModel {
        HormonesViewModel(
            siteImageHistory: SiteImageHistory(),
            style: style,
            table: createTable(),
            dependencies: dependencies,
            now: now
        )
    }

    func createTable() -> HormonesTable {
        HormonesTable(UITableView(), sdk, style)
    }

    private func tapRowAndGetHormone(viewModel: HormonesViewModel, hormone: Hormonal) -> Hormonal {
        viewModel.handleRowTapped(at: 0, UIViewController()) {}
        guard let hormoneAfterTest = sdk.hormones[hormone.id] else {
            XCTFail("Hormone somehow disappeared during test.")
            return MockHormone()
        }
        return hormoneAfterTest
    }

    private func userSelectChangeAction() {
        let changeAction = alerts.createHormoneActionsCallArgs[0].2
        changeAction()
    }
}
// swiftlint:enable type_name
