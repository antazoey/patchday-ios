//
//  SettingsSaverTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 5/10/20.

import XCTest
import PDKit
import PDTest

@testable
import PatchDay

class SettingsSaverTests: XCTestCase {

    private let dependencies = MockDependencies()
    private let helper = SettingsTestHelper()
    private var controls: SettingsControls! = nil
    private var saver: SettingsSaver! = nil

    override func setUp() {
        controls = helper.createControls()
        controls.deliveryMethodButton.setTitle("TEST")
        controls.quantityButton.setTitle("TEST")
        saver = SettingsSaver(controls, dependencies)
    }

    private var sdk: MockSDK {
        dependencies.sdk as! MockSDK
    }

    private var alerts: MockAlertFactory {
        dependencies.alerts as! MockAlertFactory
    }

    func testSave_whenDeliveryMethodAndFreshSdk_sets() {
        let testIndex = 1
        sdk.isFresh = true
        saver.save(.DeliveryMethod, selectedRow: testIndex)

        let expected = SettingsOptions.getDeliveryMethod(at: testIndex)
        let actual = (sdk.settings as! MockSettings).setDeliveryMethodCallArgs[0]
        XCTAssertEqual(expected, actual)
    }

    func testSave_whenDeliveryMethodAndNotFreshSdk_presentsAlertWithExpectedMethod() {
        let testIndex = 2
        sdk.isFresh = false
        saver.save(.DeliveryMethod, selectedRow: testIndex)
        let expected = SettingsOptions.getDeliveryMethod(at: testIndex)
        let actual = alerts.createDeliveryMethodMutationAlertCallArgs[0].0
        XCTAssertEqual(expected, actual)
        XCTAssertEqual(
            1, alerts.createDeliveryMethodMutationAlertReturnValue.presentCallCount
        )
    }

    func testSave_whenDeliveryMethodAndNotFreshSdk_presentsAlertWithDeclineActionThatResetsButton() {
        let testIndex = 2
        sdk.isFresh = false
        saver.save(.DeliveryMethod, selectedRow: testIndex)
        let handlers = alerts.createDeliveryMethodMutationAlertCallArgs[0].1
        handlers.handleDecline(originalMethod: .Patches, originalQuantity: 3)
        let expected = SettingsOptions.getDeliveryMethodString(for: .Patches)
        let actual = controls.deliveryMethodButton.titleLabel?.text
        XCTAssertEqual(expected, actual)
        XCTAssertEqual(
            1, alerts.createDeliveryMethodMutationAlertReturnValue.presentCallCount
        )
    }

    func testSave_whenDeliveryMethodAndNotFreshSdkAndToldDecline_doesNotSet() {
        let testIndex = 2
        sdk.isFresh = false
        saver.save(.DeliveryMethod, selectedRow: testIndex)
        let handlers = alerts.createDeliveryMethodMutationAlertCallArgs[0].1
        handlers.handleDecline(originalMethod: .Patches, originalQuantity: 3)
        let actual = (sdk.settings as! MockSettings).setDeliveryMethodCallArgs.count
        XCTAssertEqual(0, actual)
        XCTAssertEqual(
            1, alerts.createDeliveryMethodMutationAlertReturnValue.presentCallCount
        )
    }

    func testSave_whenDeliveryMethodAndNotFreshSdkAndToldDeclineWithPatches_enablesQuantityButton() {
        let testIndex = 2
        sdk.isFresh = false
        saver.save(.DeliveryMethod, selectedRow: testIndex)
        controls.quantityButton.isEnabled = false
        controls.quantityArrowButton.isEnabled = false
        let handlers = alerts.createDeliveryMethodMutationAlertCallArgs[0].1
        handlers.handleDecline(originalMethod: .Patches, originalQuantity: 3)
        XCTAssertTrue(controls.quantityButton.isEnabled)
        XCTAssertTrue(controls.quantityArrowButton.isEnabled)
        XCTAssertEqual(
            1, alerts.createDeliveryMethodMutationAlertReturnValue.presentCallCount
        )
    }

    func testSave_whenDeliveryMethodAndNotFreshSdkAndToldDeclineWithInjections_disablesQuantityButton() {
        let testIndex = 2
        sdk.isFresh = false
        saver.save(.DeliveryMethod, selectedRow: testIndex)
        controls.quantityButton.isEnabled = true
        controls.quantityArrowButton.isEnabled = true
        let handlers = alerts.createDeliveryMethodMutationAlertCallArgs[0].1
        handlers.handleDecline(originalMethod: .Injections, originalQuantity: 3)
        XCTAssertFalse(controls.quantityButton.isEnabled)
        XCTAssertFalse(controls.quantityArrowButton.isEnabled)
        XCTAssertEqual(
            1, alerts.createDeliveryMethodMutationAlertReturnValue.presentCallCount
        )
    }

    func testSave_whenDeliveryMethodAndNotFreshSdkAndToldDeclineWithGel_disablesQuantityButton() {
        let testIndex = 2
        sdk.isFresh = false
        saver.save(.DeliveryMethod, selectedRow: testIndex)
        controls.quantityButton.isEnabled = true
        controls.quantityArrowButton.isEnabled = true
        let handlers = alerts.createDeliveryMethodMutationAlertCallArgs[0].1
        handlers.handleDecline(originalMethod: .Gel, originalQuantity: 3)

        XCTAssertFalse(controls.quantityButton.isEnabled)
        XCTAssertFalse(controls.quantityArrowButton.isEnabled)
        XCTAssertEqual(
            1, alerts.createDeliveryMethodMutationAlertReturnValue.presentCallCount
        )
    }

    func testSave_whenQuantity_presentsAlertUsingExpectedQuantities() {
        let oldQ = 3
        let newQ = 2
        (sdk.settings as! MockSettings).quantity = QuantityUD(oldQ)
        saver.save(.Quantity, selectedRow: newQ - 1) // Use index
        let callArgs = alerts.createQuantityMutationAlertCallArgs[0]
        XCTAssertEqual(oldQ, callArgs.1)
        XCTAssertEqual(newQ, callArgs.2)
        XCTAssertEqual(1, alerts.createQuantityMutationAlertReturnValue.presentCallCount)
    }

    func testSave_whenQuantity_presentsAlertWithDeclineActionThatResetsButtonTitle() {
        let oldQ = 3
        let newQ = 2
        (sdk.settings as! MockSettings).quantity = QuantityUD(oldQ)
        saver.save(.Quantity, selectedRow: newQ - 1) // Use index
        let callArgs = alerts.createQuantityMutationAlertCallArgs[0]
        let handlers = callArgs.0
        handlers.handleDecline(oldQuantity: oldQ)
        XCTAssertEqual("3", controls.quantityButton.titleLabel?.text)
        XCTAssertEqual(1, alerts.createQuantityMutationAlertReturnValue.presentCallCount)
    }

    func testSave_whenQuantity_presentsAlertWithContinueActionThatDeletesAfterNewQuantity() {
        let oldQ = 3
        let newQ = 2
        let settings = sdk.settings as! MockSettings
        settings.quantity = QuantityUD(oldQ)
        saver.save(.Quantity, selectedRow: newQ - 1) // Use index
        let callArgs = alerts.createQuantityMutationAlertCallArgs[0]
        let handlers = callArgs.0
        handlers.handleContinue(newQuantity: newQ)
        XCTAssertEqual(newQ, settings.setQuantityCallArgs[0])
        XCTAssertEqual(1, alerts.createQuantityMutationAlertReturnValue.presentCallCount)
    }

    func testSave_whenQuantity_presentsAlertWithContinueActionThatReflectsTabs() {
        let oldQ = 3
        let newQ = 2
        let settings = sdk.settings as! MockSettings
        settings.quantity = QuantityUD(oldQ)
        saver.save(.Quantity, selectedRow: newQ - 1) // Use index
        let callArgs = alerts.createQuantityMutationAlertCallArgs[0]
        let handlers = callArgs.0
        handlers.handleContinue(newQuantity: newQ)
        let tabs = saver.tabs as! MockTabs
        XCTAssertEqual(1, tabs.reflectHormonesCallCount)
        XCTAssertEqual(1, alerts.createQuantityMutationAlertReturnValue.presentCallCount)
    }

    func testSave_whenQuantity_presentsAlertWithContinueActionThatRemovesUnneededNotifications() {
        let oldQ = 3
        let newQ = 2
        let settings = sdk.settings as! MockSettings
        settings.quantity = QuantityUD(oldQ)
        saver.save(.Quantity, selectedRow: newQ - 1) // Use index
        let callArgs = alerts.createQuantityMutationAlertCallArgs[0]
        let handlers = callArgs.0
        handlers.handleContinue(newQuantity: newQ)
        let nots = saver.notifications as! MockNotifications

        // Indices
        XCTAssertEqual(newQ - 1, nots.cancelRangeOfExpiredHormoneNotificationsCallArgs[0].0)
        XCTAssertEqual(oldQ - 1, nots.cancelRangeOfExpiredHormoneNotificationsCallArgs[0].1)
        XCTAssertEqual(1, alerts.createQuantityMutationAlertReturnValue.presentCallCount)
    }

    func testSave_whenExpirationIntervalIsOne_savesExpectedInterval() {
        saver.save(.ExpirationInterval, selectedRow: 0)  // Once a day is the first option
        let settings = sdk.settings as! MockSettings
        let callArgs = settings.setExpirationIntervalCallArgs
        XCTAssertEqual(1, callArgs.count)
        XCTAssertEqual(SettingsOptions.OnceDaily, callArgs[0])
    }

    func testSave_whenExpirationIntervalIsOnePointFive_savesExpectedInterval() {
        saver.save(.ExpirationInterval, selectedRow: 1)  // Every 1.5 Days
        let settings = sdk.settings as! MockSettings
        let callArgs = settings.setExpirationIntervalCallArgs
        XCTAssertEqual(1, callArgs.count)
        XCTAssertEqual("Every 1½ Days", callArgs[0])
    }

    func testSave_whenExpirationIntervalIsThreePointFive_savesExpectedInterval() {
        saver.save(.ExpirationInterval, selectedRow: 5)
        let settings = sdk.settings as! MockSettings
        let callArgs = settings.setExpirationIntervalCallArgs
        XCTAssertEqual(1, callArgs.count)
        XCTAssertEqual(SettingsOptions.TwiceWeekly, callArgs[0])
    }
}
