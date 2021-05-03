//
//  SettingsReflectorTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 5/10/20.

import XCTest
import PDKit
import PDTest

@testable
import PatchDay

class SettingsReflectorTests: XCTestCase {

    private let dependencies = MockDependencies()
    private let helper = SettingsTestHelper()
    private var controls: SettingsControls! = nil
    private var reflector: SettingsReflector! = nil

    func testReflect_reflectsDeliveryMethodAndIntervalAndQuantityAndNotifications() {
        let sdk = dependencies.sdk as! MockSDK
        let settings = sdk.settings as! MockSettings
        settings.deliveryMethod = DeliveryMethodUD(.Patches)
        settings.expirationInterval = ExpirationIntervalUD(.OnceWeekly)
        settings.quantity = QuantityUD(3)
        settings.notifications = NotificationsUD(true)
        settings.notificationsMinutesBefore = NotificationsMinutesBeforeUD(23)

        controls = helper.createControls()
        SettingsReflector(controls, dependencies).reflect()

        XCTAssertEqual(controls.deliveryMethodButton.titleLabel?.text, "Patches")
        XCTAssertEqual(controls.expirationIntervalButton.titleLabel?.text, "Once Weekly")
        XCTAssertEqual(controls.quantityButton.titleLabel?.text, "3")
        XCTAssertTrue(controls.notificationsSwitch.isOn)
    }

    func testReflect_whenNotificationsIsOff_doesNotLoadMinutesBefore() {
        let sdk = dependencies.sdk as! MockSDK
        let settings = sdk.settings as! MockSettings
        settings.notifications = NotificationsUD(false)
        settings.notificationsMinutesBefore = NotificationsMinutesBeforeUD(32)
        controls = helper.createControls()
        SettingsReflector(controls, dependencies).reflect()

        XCTAssertEqual(0, controls.notificationsMinutesBeforeSlider.value)
    }

    func testReflect_whenNotificationsIsOn_loadMinutesBefore() {
        let sdk = dependencies.sdk as! MockSDK
        let settings = sdk.settings as! MockSettings
        settings.notifications = NotificationsUD(true)
        settings.notificationsMinutesBefore = NotificationsMinutesBeforeUD(32)
        controls = helper.createControls()
        SettingsReflector(controls, dependencies).reflect()

        XCTAssertEqual("32", controls.notificationsMinutesBeforeValueLabel.text)
        XCTAssertEqual(Float(32), controls.notificationsMinutesBeforeSlider.value)
    }

    func testReflect_whenDeliveryMethodIsInjections_reflectsQuantityOfOne() {
        let sdk = dependencies.sdk as! MockSDK
        let settings = sdk.settings as! MockSettings
        settings.quantity = QuantityUD(3)
        settings.deliveryMethod = DeliveryMethodUD(.Injections)
        controls = helper.createControls()
        controls.quantityButton.setTitle("Not 1")
        SettingsReflector(controls, dependencies).reflect()

        XCTAssertEqual("1", controls.quantityButton.titleLabel?.text)
    }

    func testReflect_whenDeliveryMethodIsInjections_setsQuantityToOne() {
        let sdk = dependencies.sdk as! MockSDK
        let settings = sdk.settings as! MockSettings
        settings.quantity = QuantityUD(3)
        settings.deliveryMethod = DeliveryMethodUD(.Injections)
        controls = helper.createControls()
        controls.quantityButton.setTitle("Not 1")
        SettingsReflector(controls, dependencies).reflect()

        XCTAssertEqual(1, settings.setQuantityCallArgs[0])
    }

    func testReflect_whenDeliveryMethodIsInjections_disablesQuantityButtons() {
        let sdk = dependencies.sdk as! MockSDK
        let settings = sdk.settings as! MockSettings
        settings.quantity = QuantityUD(3)
        settings.deliveryMethod = DeliveryMethodUD(.Injections)
        controls = helper.createControls()
        controls.quantityButton.setTitle("Not 1")
        SettingsReflector(controls, dependencies).reflect()

        XCTAssertFalse(controls.quantityButton.isEnabled)
        XCTAssertFalse(controls.quantityArrowButton.isEnabled)
    }

    func testReflect_whenDeliveryMethodIsGel_reflectsQuantityOfOne() {
        let sdk = dependencies.sdk as! MockSDK
        let settings = sdk.settings as! MockSettings
        settings.quantity = QuantityUD(3)
        settings.deliveryMethod = DeliveryMethodUD(.Gel)
        controls = helper.createControls()
        controls.quantityButton.setTitle("Not 1")
        SettingsReflector(controls, dependencies).reflect()

        XCTAssertEqual("1", controls.quantityButton.titleLabel?.text)
    }

    func testReflect_whenDeliveryMethodIsGel_setsQuantityToOne() {
        let sdk = dependencies.sdk as! MockSDK
        let settings = sdk.settings as! MockSettings
        settings.quantity = QuantityUD(3)
        settings.deliveryMethod = DeliveryMethodUD(.Gel)
        controls = helper.createControls()
        controls.quantityButton.setTitle("Not 1")
        SettingsReflector(controls, dependencies).reflect()

        XCTAssertEqual(1, settings.setQuantityCallArgs[0])
    }

    func testReflect_whenDeliveryMethodIsGel_disablesQuantityButtons() {
        let sdk = dependencies.sdk as! MockSDK
        let settings = sdk.settings as! MockSettings
        settings.quantity = QuantityUD(3)
        settings.deliveryMethod = DeliveryMethodUD(.Gel)
        controls = helper.createControls()
        controls.quantityButton.setTitle("Not 1")
        SettingsReflector(controls, dependencies).reflect()

        XCTAssertFalse(controls.quantityButton.isEnabled)
        XCTAssertFalse(controls.quantityArrowButton.isEnabled)
    }
}
