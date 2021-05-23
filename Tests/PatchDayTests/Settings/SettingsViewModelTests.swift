//
//  SettingsViewModelTests.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 5/10/20.

import XCTest
import PDKit
import PDTest

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

    private var settings: MockSettings {
        dependencies.sdk?.settings as! MockSettings
    }

    func testDeliveryMethodStartIndex_returnsIndexOfSetMethod() {
        settings.deliveryMethod = DeliveryMethodUD(.Gel)
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, dependencies)
        let actual = viewModel.deliveryMethodStartIndex
        let expected = 2
        XCTAssertEqual(expected, actual)
    }

    func testDeliveryMethodStartIndex_whenSdkIsNil_returnsZero() {
        let deps = MockDependencies()
        deps.sdk = nil
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, deps)
        XCTAssertEqual(0, viewModel.deliveryMethodStartIndex)
    }

    func testQuantityStartIndex_returnsIndexOfSetQuantity() {
        settings.quantity = QuantityUD(2)
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, dependencies)
        let actual = viewModel.quantityStartIndex
        let expected = 1
        XCTAssertEqual(expected, actual)
    }

    func testQuantityStartIndex_whenSdkIsNil_returnsZero() {
        let deps = MockDependencies()
        deps.sdk = nil
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, deps)
        XCTAssertEqual(0, viewModel.quantityStartIndex)
    }

    func testExpirationIntervalStartIndex_returnsIndexOfSetInterval() {
        settings.expirationInterval = ExpirationIntervalUD(.EveryTwoWeeks)
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, dependencies)
        let actual = viewModel.expirationIntervalStartIndex
        let expectedOption = SettingsOptions.OnceEveryTwoWeeks
        let expected = SettingsOptions.expirationIntervals.firstIndex(of: expectedOption)
        XCTAssertEqual(expected, actual)
    }

    func testExpirationIntervalStartIndex_whenIsCustomInterval_returnsIndexOfSetInterval() {
        settings.expirationInterval = ExpirationIntervalUD(.EveryXDays)
        settings.expirationInterval.xDays.rawValue = "6.5"
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, dependencies)
        let actual = viewModel.expirationIntervalStartIndex
        let expectedOption = "Every 6½ Days"
        let expected = SettingsOptions.expirationIntervals.firstIndex(of: expectedOption)
        XCTAssertEqual(expected, actual)
    }

    func testExpirationIntervalStartIndex_whenSdkIsNil_returnsZero() {
        let deps = MockDependencies()
        deps.sdk = nil
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, deps)
        XCTAssertEqual(0, viewModel.expirationIntervalStartIndex)
    }

    func testActivatePicker_whenPickerIsHidden_selectsActivator() {
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, dependencies)
        let picker = SettingsPicker()
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

        let picker = SettingsPicker()
        picker.setting = .ExpirationInterval
        picker.isHidden = false
        viewModel.activatePicker(picker)

        let expected = SettingsOptions.expirationIntervals[0]
        let actual = settings.setExpirationIntervalCallArgs[0]
        XCTAssertEqual(expected, actual)
    }

    func testHandleNewNotificationsMinutesValue_whenNotificationsIsOff_doesNotMutate() {
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, dependencies)
        settings.notifications = NotificationsUD(false)
        viewModel.handleNewNotificationsMinutesValue(23.0)
        PDAssertEmpty(settings.setNotificationsMinutesBeforeCallArgs)
    }

    func testHandleNewNotificationsMinutesValue_whenNewValueLessThanZero_doesNotMutate() {
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, dependencies)
        viewModel.handleNewNotificationsMinutesValue(-23.0)
        PDAssertEmpty(settings.setNotificationsMinutesBeforeCallArgs)
    }

    func testHandleNewNotificationsMinutesValue_cancelsAndResendsAllNotifications() {
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, dependencies)
        settings.notifications = NotificationsUD(true)
        viewModel.handleNewNotificationsMinutesValue(23.0)
        let nots = dependencies.notifications as! MockNotifications
        XCTAssertEqual(1, nots.cancelAllExpiredHormoneNotificationsCallCount)
        XCTAssertEqual(1, nots.requestAllExpiredHormoneNotificationCallCount)
    }

    func testHandleNewNotificationsMinutesBeforeValue_whenNilSdk_doesNotCancelOrRequestNotifications() {
        let deps = MockDependencies()
        deps.sdk = nil
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, deps)
        viewModel.handleNewNotificationsMinutesValue(23.0)
        let nots = deps.notifications as! MockNotifications
        XCTAssertEqual(0, nots.cancelAllExpiredHormoneNotificationsCallCount)
        XCTAssertEqual(0, nots.requestAllExpiredHormoneNotificationCallCount)
    }

    func testHandleNewNotificationsMinutesValue_sets() {
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, dependencies)
        viewModel.handleNewNotificationsMinutesValue(23.0)
        PDAssertSingle(23, settings.setNotificationsMinutesBeforeCallArgs)
    }

    func testHandleNewNotificationsMinutesValue_returnsExpectedTitleString() {
        let reflector = SettingsReflector(controls, dependencies)
        let saver = SettingsSaver(controls, dependencies)
        let alertFactory = MockAlertFactory()
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, dependencies)
        let actual = viewModel.handleNewNotificationsMinutesValue(23.0)
        let expected = "23.0"
        XCTAssertEqual(expected, actual)
    }

    func testHandleNewNotificationsMinutesValue_rounds() {
        let reflector = SettingsReflector(controls, dependencies)
        let saver = SettingsSaver(controls, dependencies)
        let alertFactory = MockAlertFactory()
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, dependencies)
        let actual = viewModel.handleNewNotificationsMinutesValue(23.232352552)
        let expected = "23.0"
        XCTAssertEqual(expected, actual)
    }

    func testReflect_callsReflectorReflect() {
        let mockReflector = MockSettingsReflector()
        let viewModel = SettingsViewModel(mockReflector, saver, alertFactory, dependencies)
        viewModel.reflect()
        XCTAssertEqual(1, mockReflector.reflectCallCount)
    }

    func testSetNotifications_sets() {
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, dependencies)
        viewModel.setNotifications(true)
        viewModel.setNotifications(false)
        let callArgs = settings.setNotificationsCallArgs
        XCTAssertEqual(2, callArgs.count)
        XCTAssertTrue(callArgs[0])
        XCTAssertFalse(callArgs[1])
    }

    func testSetNotifications_whenSettingToTrue_requestsAllNotifications() {
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, dependencies)
        viewModel.setNotifications(true)
        let notifications = dependencies.notifications as! MockNotifications
        let requestCallCount = notifications.requestAllExpiredHormoneNotificationCallCount
        let cancelCallCount = notifications.cancelAllExpiredHormoneNotificationsCallCount
        XCTAssertEqual(1, requestCallCount)
        XCTAssertEqual(0, cancelCallCount)
    }

    func testSetNotifications_whenSettingsToFalse_cancelsAllNotifications() {
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, dependencies)
        viewModel.setNotifications(false)
        let notifications = dependencies.notifications as! MockNotifications
        let requestCallCount = notifications.requestAllExpiredHormoneNotificationCallCount
        let cancelCallCount = notifications.cancelAllExpiredHormoneNotificationsCallCount
        XCTAssertEqual(0, requestCallCount)
        XCTAssertEqual(1, cancelCallCount)
    }

    func testSetNotifications_whenNotifcationsIsNil_doesNothingWithNotifications() {
        let deps = MockDependencies()
        deps.notifications = nil
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, deps)
        viewModel.setNotifications(false)
        let notifications = dependencies.notifications as! MockNotifications
        let requestCallCount = notifications.requestAllExpiredHormoneNotificationCallCount
        let cancelCallCount = notifications.cancelAllExpiredHormoneNotificationsCallCount
        XCTAssertEqual(0, requestCallCount)
        XCTAssertEqual(0, cancelCallCount)
    }

    func testSetNotifications_whenSettingsToFalse_clearsNotificationsMinutesBefore() {
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, dependencies)
        viewModel.setNotifications(false)
        let callArgs = settings.setNotificationsMinutesBeforeCallArgs
        XCTAssertEqual([0], callArgs)
    }
}
