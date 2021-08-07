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

// swiftlint:disable function_body_length
class WhenChangingHormoneBadge_UpdatesCorrectly: PDIntegrationTestCase {
    func test() {
        let badge = PDBadge(sdk: sdk)
        sdk.settings.setDeliveryMethod(to: .Patches)  // Should trigger reset to 3 patches
        let ids = self.sdk.hormones.all.map({ $0.id })
        if ids.count < 3 {
            XCTFail("Hormone count does not match delivery method")
            return
        }
        sdk.hormones.setDate(by: ids[0], with: TestDateFactory.createTestDate(daysFrom: -20))
        sdk.hormones.setDate(by: ids[1], with: TestDateFactory.createTestDate(daysFrom: -20))
        sdk.hormones.setDate(by: ids[2], with: TestDateFactory.createTestDate(daysFrom: -20))
        badge.reflect()

        XCTAssertEqual(3, sdk.hormones.totalExpired)
        XCTAssertEqual(3, badge.value)

        sdk.hormones.setDate(at: 0, with: Date())
        badge.reflect()

        XCTAssertEqual(2, sdk.hormones.totalExpired)
        XCTAssertEqual(2, badge.value)
    }
}

class WhenContinuingOnChangeDeliveryMethodAlert_addsOrRemoveHormonesToGetToDefaultQuantity: PDIntegrationTestCase {
    func test() {
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
}

class WhenTakingHormoneFromActionAlert_setsNotificationWithUpdatedDate: PDIntegrationTestCase {
    func test() {
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

        hormonesViewModel.handleRowTapped(at: 0, UIViewController()) {}
        guard let hormoneAfterTest = sdk.hormones[hormone.id] else {
            XCTFail("Hormone somehow disappeared during test.")
            return
        }

        let changeAction = alerts.createHormoneActionsCallArgs[0].2
        changeAction()  // Simulates user selecting "Change" from the alert

        let actual = hormoneAfterTest.date
        PDAssertNotEquiv(testDate, actual)
    }
}
// swiftlint:enable function_body_length
