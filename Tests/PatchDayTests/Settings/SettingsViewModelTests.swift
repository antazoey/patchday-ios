//
//  SettingsViewModelTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 5/10/20.

import XCTest
import PDKit
import PDMock

@testable
import PatchDay

class SettingsViewModelTests: XCTestCase {

    private let dependencies = MockDependencies()
    private let helper = SettingsTestHelper()
    private let alertFactory = MockAlertFactory()

    private var controls: SettingsControls {
        helper.createControls()
    }

    private var reflector: SettingsReflector {
        SettingsReflector(controls, dependencies)
    }

    private var saver: SettingsSaver {
        SettingsSaver(controls, dependencies)
    }

    func testDeliveryMethodStartIndex_returnsIndexOfSetMethod() {
        let settings = dependencies.sdk?.settings as! MockSettings
        settings.deliveryMethod = DeliveryMethodUD(.Gel)
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, dependencies)
        let actual = viewModel.deliveryMethodStartIndex
        let expected = 2
        XCTAssertEqual(expected, actual)
    }

    func testQuantityStartIndex_returnsIndexOfSetQuantity() {
        let settings = dependencies.sdk?.settings as! MockSettings
        settings.quantity = QuantityUD(2)
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, dependencies)
        let actual = viewModel.quantityStartIndex
        let expected = 1
        XCTAssertEqual(expected, actual)
    }

    func testExpirationIntervalStartIndex_returnsIndexOfSetInterval() {
        let settings = dependencies.sdk?.settings as! MockSettings
        settings.expirationInterval = ExpirationIntervalUD(.EveryTwoWeeks)
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, dependencies)
        let actual = viewModel.expirationIntervalStartIndex
        let expected = 3
        XCTAssertEqual(expected, actual)
    }

    func testActivatePicker_whenPickerIsHidden_selectsActivator() {
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, dependencies)
        let picker = SettingsPickerView()
        picker.isHidden = true
        let activator = UIButton()
        activator.isSelected = false
        picker.activator = activator
        viewModel.activatePicker(picker)
        XCTAssertTrue(picker.activator.isSelected)
    }

    func testActivatePicker_whenPickerIsVisible_saves() {
        let reflector = SettingsReflector(controls, dependencies)
        let saver = SettingsSaver(controls, dependencies)
        let alertFactory = MockAlertFactory()
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, dependencies)

        let picker = SettingsPickerView()
        picker.setting = .ExpirationInterval
        picker.isHidden = false
        viewModel.activatePicker(picker)
        let sdk = dependencies.sdk as! MockSDK
        let settings = sdk.settings as! MockSettings
        let expected = SettingsOptions.expirationIntervals[0]
        let actual = settings.setExpirationIntervalCallArgs[0]
        XCTAssertEqual(expected, actual)
    }

    func testHandleNewNotificationsMinutesValue_whenNotificationsIsOff_doesNotMutate() {
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, dependencies)
        let settings = dependencies.sdk?.settings as! MockSettings
        settings.notifications = NotificationsUD(false)
        viewModel.handleNewNotificationsMinutesValue(23)
        XCTAssertEqual(0, settings.setNotificationsMinutesBeforeCallArgs.count)
    }

    func testHandleNewNotificationsMinutesValue_whenNewValueLessThanZero_doesNotMutate() {
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, dependencies)
        viewModel.handleNewNotificationsMinutesValue(-23)
        let settings = dependencies.sdk?.settings as! MockSettings
        XCTAssertEqual(0, settings.setNotificationsMinutesBeforeCallArgs.count)
    }

    func testHandleNewNotificationsMinutesValue_cancelsAdnResendsAllNotifications() {
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, dependencies)
        let settings = dependencies.sdk?.settings as! MockSettings
        settings.notifications = NotificationsUD(true)
        viewModel.handleNewNotificationsMinutesValue(23)
        let nots = dependencies.notifications as! MockNotifications
        XCTAssertEqual(1, nots.cancelAllExpiredHormoneNotificationsCallCount)
        XCTAssertEqual(1, nots.requestAllExpiredHormoneNotificationCallCount)
    }

    func testHandleNewNotificationsMinutesValue_sets() {
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, dependencies)
        viewModel.handleNewNotificationsMinutesValue(23)
        let settings = dependencies.sdk?.settings as! MockSettings
        XCTAssertEqual(1, settings.setNotificationsMinutesBeforeCallArgs.count)
    }

    func testHandleNewNotificationsMinutesValue_returnsExpectedTitleString() {
        let reflector = SettingsReflector(controls, dependencies)
        let saver = SettingsSaver(controls, dependencies)
        let alertFactory = MockAlertFactory()
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, dependencies)
        let actual = viewModel.handleNewNotificationsMinutesValue(23)
        let expected = "23.0"
        XCTAssertEqual(expected, actual)
    }
}
