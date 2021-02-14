//
//  File.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 5/24/20.

import XCTest
import PDKit
import PDMock
import PatchData

@testable
import PatchDay

class IntegrationTests: XCTestCase {
#if targetEnvironment(simulator)

    private let sdk = PatchData()
    private let dummyViewController = UIViewController()

    override func setUp() {
        sdk.resetAll()
    }

    // Force synchronous execution
    func test() {
        runTestWhenChangingHormoneBadgeUpdatesCorrectly()
        runTestWhenContinuingOnChangeDeliveryMethodAlertAddsOrRemoveHormonesToGetToDefaultQuantity()
    }

    func runTestWhenChangingHormoneBadgeUpdatesCorrectly() {
        let badge = PDBadge(sdk: sdk)
        sdk.settings.setDeliveryMethod(to: .Patches)  // Should trigger reset to 3 patches
        let ids = self.sdk.hormones.all.map({ $0.id })
        sdk.hormones.setDate(by: ids[0], with: DateFactory.createDate(daysFromNow: -20)!)
        sdk.hormones.setDate(by: ids[1], with: DateFactory.createDate(daysFromNow: -20)!)
        sdk.hormones.setDate(by: ids[2], with: DateFactory.createDate(daysFromNow: -20)!)
        badge.reflect()

        XCTAssertEqual(3, sdk.hormones.totalExpired)
        XCTAssertEqual(3, badge.value)

        sdk.hormones.setDate(at: 0, with: Date())
        badge.reflect()

        XCTAssertEqual(2, sdk.hormones.totalExpired)
        XCTAssertEqual(2, badge.value)
    }

    func runTestWhenContinuingOnChangeDeliveryMethodAlertAddsOrRemoveHormonesToGetToDefaultQuantity() {
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

#endif
}
