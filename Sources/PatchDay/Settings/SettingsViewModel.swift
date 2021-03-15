//
//  SettingsViewModel.swift
//  PatchDay
//
//  Created by Juliya Smith on 10/29/19.

import Foundation
import PDKit

class SettingsViewModel: CodeBehindDependencies<SettingsViewModel> {

    var reflector: SettingsReflector
    var saver: SettingsSaver
    var alertFactory: AlertProducing?

    convenience init(controls: SettingsControls) {
        let reflector = SettingsReflector(controls)
        let saver = SettingsSaver(controls)
        self.init(reflector, saver, nil)
    }

    init(
        _ reflector: SettingsReflector,
        _ saver: SettingsSaver,
        _ alertFactory: AlertProducing? = nil
    ) {
        self.reflector = reflector
        self.saver = saver
        self.alertFactory = alertFactory
        super.init()
        if self.alertFactory == nil, let sdk = sdk {
            self.alertFactory = AlertFactory(sdk: sdk, tabs: self.tabs)
        }
    }

    init(
        _ reflector: SettingsReflector,
        _ saver: SettingsSaver,
        _ alertFactory: AlertProducing,
        _ dependencies: DependenciesProtocol
    ) {
        self.reflector = reflector
        self.saver = saver
        self.alertFactory = alertFactory
        super.init(
            sdk: dependencies.sdk,
            tabs: dependencies.tabs,
            notifications: dependencies.notifications,
            alerts: dependencies.alerts,
            nav: dependencies.nav,
            badge: dependencies.badge,
            widget: dependencies.widget
        )
    }

    var deliveryMethodStartIndex: Index {
        sdk?.settings.deliveryMethod.currentIndex ?? 0
    }

    var quantityStartIndex: Index {
        sdk?.settings.quantity.currentIndex ?? 0
    }

    var expirationIntervalStartIndex: Index {
        sdk?.settings.expirationInterval.currentIndex ?? 0
    }

    func activatePicker(_ picker: SettingsPickerView) {
        picker.isHidden ? picker.open() : close(picker)
    }

    func handleNewNotificationsValue(_ newValue: Float) {
        guard let sdk = sdk else { return }
        guard sdk.settings.notifications.value else { return }
        guard newValue >= 0 else { return }
        notifications?.cancelAllExpiredHormoneNotifications()
        let newMinutesBeforeValue = Int(newValue)
        sdk.settings.setNotificationsMinutesBefore(to: newMinutesBeforeValue)
        notifications?.requestAllExpiredHormoneNotifications()
    }

    private func close(_ picker: SettingsPickerView) {
        picker.close()
        guard let setting = picker.setting else { return }
        let row = picker.selectedRow(inComponent: 0)
        if let factory = alertFactory {
            saver.save(setting, selectedRow: row, alertFactory: factory)
        }
    }
}
