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
    private var controls: SettingsControls! = nil

    func testActivatePicker_whenPickerIsHidden_selectsActivator() {
        let controls = helper.createControls()
        let reflector = SettingsReflector(controls, dependencies)
        let saver = SettingsSavePoint(controls, dependencies)
        let alertFactory = MockAlertFactory()
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
        let controls = helper.createControls()
        let reflector = SettingsReflector(controls, dependencies)
        let saver = SettingsSavePoint(controls, dependencies)
        let alertFactory = MockAlertFactory()
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, dependencies)

        let picker = SettingsPickerView()
        picker.setting = .ExpirationInterval
        picker.isHidden = false
        viewModel.activatePicker(picker)
        let sdk = dependencies.sdk as! MockSDK
        let settings = sdk.settings as! MockSettings
        XCTAssertEqual(SettingsOptions.expirationIntervals[0], settings.setExpirationIntervalCallArgs[0])
    }

    func testHandleNewNotificationsValue_whenNotificationsIsOff_doesNotMutate() {
        let controls = helper.createControls()
        let reflector = SettingsReflector(controls, dependencies)
        let saver = SettingsSavePoint(controls, dependencies)
        let alertFactory = MockAlertFactory()
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, dependencies)
        let settings = dependencies.sdk?.settings as! MockSettings
        settings.notifications = NotificationsUD(false)

        viewModel.handleNewNotificationsValue(23)

        XCTAssertEqual(0, settings.setNotificationsMinutesBeforeCallArgs.count)
    }

    func testHandleNewNotificationsValue_whenNewValueLessThanZero_doesNotMutate() {
        let controls = helper.createControls()
        let reflector = SettingsReflector(controls, dependencies)
        let saver = SettingsSavePoint(controls, dependencies)
        let alertFactory = MockAlertFactory()
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, dependencies)

        viewModel.handleNewNotificationsValue(-23)

        let settings = dependencies.sdk?.settings as! MockSettings
        XCTAssertEqual(0, settings.setNotificationsMinutesBeforeCallArgs.count)
    }

    func testHandleNewNotificationsValue_cancelsAdnResendsAllNotifications() {
        let controls = helper.createControls()
        let reflector = SettingsReflector(controls, dependencies)
        let saver = SettingsSavePoint(controls, dependencies)
        let alertFactory = MockAlertFactory()
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, dependencies)
        let settings = dependencies.sdk?.settings as! MockSettings
        settings.notifications = NotificationsUD(true)

        viewModel.handleNewNotificationsValue(23)

        let nots = dependencies.notifications as! MockNotifications
        XCTAssertEqual(1, nots.cancelAllExpiredHormoneNotificationsCallCount)
        XCTAssertEqual(1, nots.requestAllExpiredHormoneNotificationCallCount)
    }

    func testHandleNewNotificationsValue_sets() {
        let controls = helper.createControls()
        let reflector = SettingsReflector(controls, dependencies)
        let saver = SettingsSavePoint(controls, dependencies)
        let alertFactory = MockAlertFactory()
        let viewModel = SettingsViewModel(reflector, saver, alertFactory, dependencies)

        viewModel.handleNewNotificationsValue(23)

        let settings = dependencies.sdk?.settings as! MockSettings
        XCTAssertEqual(1, settings.setNotificationsMinutesBeforeCallArgs.count)
    }
}
