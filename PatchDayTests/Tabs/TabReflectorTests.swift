//
//  TabReflectorTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 5/30/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDMock

@testable
import PatchDay

class TabReflectorTests: XCTestCase {

    private let sdk = MockSDK()
    private let hormonesViewController = UIViewController()
    private let pillsViewController = UIViewController()

    func createTabs() -> TabReflector {
        let controller = UITabBarController()
        let viewControllers = [hormonesViewController, pillsViewController, UIViewController()]
        return TabReflector(
            tabBarController: controller, viewControllers: viewControllers, sdk: sdk
        )
    }

    func testReflectHormones_reflectsDeliveryMethodAccurately() {
        let settings = sdk.settings as! MockSettings
        settings.deliveryMethod = DeliveryMethodUD(.Injections)
        let tabs = createTabs()
        tabs.reflectHormones()
        let expected = PDIcons[.Injections]
        let actual = hormonesViewController.tabBarItem.image
        XCTAssertEqual(expected, actual)
    }

    func testReflectHormones_reflectsBadgeValue() {
        let hormones = sdk.hormones as! MockHormoneSchedule
        hormones.totalExpired = 2
        let tabs = createTabs()
        tabs.reflectHormones()
        XCTAssertEqual("2", hormonesViewController.tabBarItem.badgeValue)
    }

    func testReflectHormones_whenZeroTotalDue_doesNotReflectBadgeValue() {
        let hormones = sdk.hormones as! MockHormoneSchedule
        hormones.totalExpired = 0
        let tabs = createTabs()
        tabs.reflectHormones()
        XCTAssertNil(hormonesViewController.tabBarItem.badgeValue)
    }

    func testReflectPills_whenZeroTotalDue_doesNotReflectBadgeValue() {
        let pills = sdk.pills as! MockPillSchedule
        pills.totalDue = 0
        let tabs = createTabs()
        tabs.reflectPills()
        XCTAssertNil(pillsViewController.tabBarItem.badgeValue)
    }

    func testReflectPills_reflectsBadgeValue() {
        let pills = sdk.pills as! MockPillSchedule
        pills.totalDue = 1
        let tabs = createTabs()
        tabs.reflectPills()
        XCTAssertEqual("1", pillsViewController.tabBarItem.badgeValue)
    }
}
