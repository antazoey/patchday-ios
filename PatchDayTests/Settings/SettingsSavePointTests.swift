//
//  SettingsSavePointTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 5/10/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import XCTest
import PDKit
import PDMock

@testable
import PatchDay

class SettingsSavePointTests: XCTestCase {

	private let dependencies = MockDependencies()
	private let helper = SettingsTestHelper()
	private var controls: SettingsControls! = nil
	private var saver: SettingsSavePoint! = nil

	override func setUp() {
		controls = helper.createControls()
		controls.deliveryMethodButton.setTitle("TEST")
		controls.quantityButton.setTitle("TEST")
		saver = SettingsSavePoint(controls, dependencies)
	}

	func testSave_whenDeliveryMethodAndFreshSdk_sets() {
		let sdk = dependencies.sdk! as! MockSDK
		let testIndex = 1
		sdk.isFresh = true
		saver.save(.DeliveryMethod, selectedRow: testIndex)

		let expected = SettingsOptions.getDeliveryMethod(at: testIndex)
		let actual = (sdk.settings as! MockSettings).setDeliveryMethodCallArgs[0]
		XCTAssertEqual(expected, actual)
	}

	func testSave_whenDeliveryMethodAndNotFreshSdk_presentsAlertWithExpectedMethod() {
		let sdk = dependencies.sdk! as! MockSDK
		let testIndex = 2
		sdk.isFresh = false
		saver.save(.DeliveryMethod, selectedRow: testIndex)

		let alerts = dependencies.alerts as! MockAlerts
		let expected = SettingsOptions.getDeliveryMethod(at: testIndex)
		let actual = alerts.presentDeliveryMethodMutationAlertCallArgs[0].0
		XCTAssertEqual(expected, actual)
	}

	func testSave_whenDeliveryMethodAndNotFreshSdk_presentsAlertWithDeclineActionThatResetsButton() {
		let sdk = dependencies.sdk! as! MockSDK
		let testIndex = 2
		sdk.isFresh = false
		saver.save(.DeliveryMethod, selectedRow: testIndex)

		let alerts = dependencies.alerts as! MockAlerts
		let handlers = alerts.presentDeliveryMethodMutationAlertCallArgs[0].1

		handlers.handleDecline(originalMethod: .Patches, originalQuantity: 3)
		let expected = SettingsOptions.getDeliveryMethodString(for: .Patches)
		let actual = controls.deliveryMethodButton.titleLabel?.text
		XCTAssertEqual(expected, actual)
	}

	func testSave_whenDeliveryMethodAndNotFreshSdkAndToldDecline_doesNotSet() {
		let sdk = dependencies.sdk! as! MockSDK
		let testIndex = 2
		sdk.isFresh = false
		saver.save(.DeliveryMethod, selectedRow: testIndex)

		let alerts = dependencies.alerts as! MockAlerts
		let handlers = alerts.presentDeliveryMethodMutationAlertCallArgs[0].1
		handlers.handleDecline(originalMethod: .Patches, originalQuantity: 3)

		let actual = (sdk.settings as! MockSettings).setDeliveryMethodCallArgs.count
		XCTAssertEqual(0, actual)
	}

	func testSave_whenDeliveryMethodAndNotFreshSdkAndToldDeclineWithPatches_enablesQuantityButton() {
		let sdk = dependencies.sdk! as! MockSDK
		let testIndex = 2
		sdk.isFresh = false
		saver.save(.DeliveryMethod, selectedRow: testIndex)
		controls.quantityButton.isEnabled = false
		controls.quantityArrowButton.isEnabled = false

		let alerts = dependencies.alerts as! MockAlerts
		let handlers = alerts.presentDeliveryMethodMutationAlertCallArgs[0].1
		handlers.handleDecline(originalMethod: .Patches, originalQuantity: 3)

		XCTAssertTrue(controls.quantityButton.isEnabled)
		XCTAssertTrue(controls.quantityArrowButton.isEnabled)
	}

	func testSave_whenDeliveryMethodAndNotFreshSdkAndToldDeclineWithInjections_disablesQuantityButton() {
		let sdk = dependencies.sdk! as! MockSDK
		let testIndex = 2
		sdk.isFresh = false
		saver.save(.DeliveryMethod, selectedRow: testIndex)
		controls.quantityButton.isEnabled = true
		controls.quantityArrowButton.isEnabled = true

		let alerts = dependencies.alerts as! MockAlerts
		let handlers = alerts.presentDeliveryMethodMutationAlertCallArgs[0].1
		handlers.handleDecline(originalMethod: .Injections, originalQuantity: 3)

		XCTAssertFalse(controls.quantityButton.isEnabled)
		XCTAssertFalse(controls.quantityArrowButton.isEnabled)
	}

	func testSave_whenDeliveryMethodAndNotFreshSdkAndToldDeclineWithGel_disablesQuantityButton() {
		let sdk = dependencies.sdk! as! MockSDK
		let testIndex = 2
		sdk.isFresh = false
		saver.save(.DeliveryMethod, selectedRow: testIndex)
		controls.quantityButton.isEnabled = true
		controls.quantityArrowButton.isEnabled = true

		let alerts = dependencies.alerts as! MockAlerts
		let handlers = alerts.presentDeliveryMethodMutationAlertCallArgs[0].1
		handlers.handleDecline(originalMethod: .Gel, originalQuantity: 3)

		XCTAssertFalse(controls.quantityButton.isEnabled)
		XCTAssertFalse(controls.quantityArrowButton.isEnabled)
	}

	func testSave_whenQuantity_presentsAlertUsingExpectedQuantities() {
		let sdk = dependencies.sdk! as! MockSDK
		let oldQ = 3
		let newQ = 2
		(sdk.settings as! MockSettings).quantity = QuantityUD(oldQ)
		saver.save(.Quantity, selectedRow: newQ - 1) // Use index
		let alerts = dependencies.alerts as! MockAlerts

		XCTAssertEqual(oldQ, alerts.presentQuantityMutationAlertCallArgs[0].0)
		XCTAssertEqual(newQ, alerts.presentQuantityMutationAlertCallArgs[0].1)
	}

	func testSave_whenQuantity_presentsAlertWithDeclineActionThatResetsButtonTitle() {
		let sdk = dependencies.sdk! as! MockSDK
		let oldQ = 3
		let newQ = 2
		(sdk.settings as! MockSettings).quantity = QuantityUD(oldQ)
		saver.save(.Quantity, selectedRow: newQ - 1) // Use index
		let alerts = dependencies.alerts as! MockAlerts

		let handlers = alerts.presentQuantityMutationAlertCallArgs[0].2
		handlers.handleDecline(oldQuantity: oldQ)
		XCTAssertEqual("3", controls.quantityButton.titleLabel?.text)
	}

	func testSave_whenQuantity_presentsAlertWithContinueActionThatDeletesAfterNewQuantity() {
		let sdk = dependencies.sdk! as! MockSDK
		let oldQ = 3
		let newQ = 2
		let settings = sdk.settings as! MockSettings
		settings.quantity = QuantityUD(oldQ)
		saver.save(.Quantity, selectedRow: newQ - 1) // Use index
		let alerts = dependencies.alerts as! MockAlerts

		let handlers = alerts.presentQuantityMutationAlertCallArgs[0].2
		handlers.handleContinue(newQuantity: newQ)
		XCTAssertEqual(newQ, settings.setQuantityCallArgs[0])
	}

	func testSave_whenQuantity_presentsAlertWithContinueActionThatReflectsTabs() {
		let sdk = dependencies.sdk! as! MockSDK
		let oldQ = 3
		let newQ = 2
		let settings = sdk.settings as! MockSettings
		settings.quantity = QuantityUD(oldQ)
		saver.save(.Quantity, selectedRow: newQ - 1) // Use index
		let alerts = dependencies.alerts as! MockAlerts

		let handlers = alerts.presentQuantityMutationAlertCallArgs[0].2
		handlers.handleContinue(newQuantity: newQ)
		let tabs = saver.tabs as! MockTabs
		XCTAssertEqual(1, tabs.reflectHormonesCallCount)
	}

	func testSave_whenQuantity_presentsAlertWithContinueActionThatRemovesUnneededNotifications() {
		let sdk = dependencies.sdk! as! MockSDK
		let oldQ = 3
		let newQ = 2
		let settings = sdk.settings as! MockSettings
		settings.quantity = QuantityUD(oldQ)
		saver.save(.Quantity, selectedRow: newQ - 1) // Use index
		let alerts = dependencies.alerts as! MockAlerts

		let handlers = alerts.presentQuantityMutationAlertCallArgs[0].2
		handlers.handleContinue(newQuantity: newQ)
		let nots = saver.notifications as! MockNotifications

		// Indices
		XCTAssertEqual(newQ - 1, nots.cancelRangeOfExpiredHormoneNotificationsCallArgs[0].0)
		XCTAssertEqual(oldQ - 1, nots.cancelRangeOfExpiredHormoneNotificationsCallArgs[0].1)
	}
}
