//
//  SettingsViewModel.swift
//  PatchDay
//
//  Created by Juliya Smith on 10/29/19.

import Foundation
import PDKit

class SettingsViewModel: CodeBehindDependencies<SettingsViewModel>, SettingsViewModelProtocol {

    var reflector: SettingsReflecting
    var saver: SettingsSaver
    var alertFactory: AlertProducing?

    convenience init(controls: SettingsControls) {
        let reflector = SettingsReflector(controls)
        let saver = SettingsSaver(controls: controls)
        self.init(reflector, saver, nil)
    }

    init(
        _ reflector: SettingsReflecting,
        _ saver: SettingsSaver,
        _ alertFactory: AlertProducing? = nil
    ) {
        self.reflector = reflector
        self.saver = saver
        self.alertFactory = alertFactory
        super.init()
    }

    init(
        _ reflector: SettingsReflecting,
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
        sdk?.settings.deliveryMethod.choiceIndex ?? 0
    }

    var quantityStartIndex: Index {
        sdk?.settings.quantity.choiceIndex ?? 0
    }

    var expirationIntervalStartIndex: Index {
        sdk?.settings.expirationInterval.choiceIndex ?? 0
    }

    var xDaysStartIndex: Index {
        sdk?.settings.expirationInterval.xDays.choiceIndex ?? 0
    }

    var usesXDays: Bool {
        sdk?.settings.expirationInterval.value == .EveryXDays
    }

    func activatePicker(_ picker: SettingsPicking) {
        picker.isHidden ? picker.open() : close(picker)
    }

    @discardableResult
    func handleNewNotificationsMinutesValue(_ newValue: Float) -> String {
        let newValue = newValue.rounded()
        let titleString = "\(newValue)"
        guard let sdk = sdk else { return titleString }
        guard sdk.settings.notifications.value else { return titleString }
        guard newValue >= 0 else { return titleString }
        notifications?.cancelAllExpiredHormoneNotifications()
        let newMinutesBeforeValue = Int(newValue)
        setNotificationsMinutes(newMinutesBeforeValue)
        return titleString
    }

    func reflect() {
        reflector.reflect()
    }

    func setNotifications(_ newValue: Bool) {
        sdk?.settings.setNotifications(to: newValue)
        if newValue {
            notifications?.requestAllExpiredHormoneNotifications()
        } else {
            // disabling
            notifications?.cancelAllExpiredHormoneNotifications()
            sdk?.settings.setNotificationsMinutesBefore(to: 0)
        }
    }

    private func setNotificationsMinutes(_ newValue: Int) {
        sdk?.settings.setNotificationsMinutesBefore(to: newValue)
        notifications?.requestAllExpiredHormoneNotifications()
    }

    private func close(_ picker: SettingsPicking) {
        picker.close(setSelectedRow: true)
        guard let setting = picker.setting else { return }
        let row = picker.selectedRow(inComponent: 0)
        saver.save(setting, selectedRow: row)
    }
}
