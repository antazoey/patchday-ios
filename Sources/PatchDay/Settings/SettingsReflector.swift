//
//  SettingsReflector.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/20/19.

import Foundation
import PDKit

class SettingsReflector: CodeBehindDependencies<SettingsReflector>, SettingsReflecting {

    private let controls: SettingsControls

    init(_ controls: SettingsControls) {
        self.controls = controls
        super.init()
    }

    init(_ controls: SettingsControls, _ dependencies: DependenciesProtocol) {
        self.controls = controls
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

    public func reflect() {
        loadDeliveryMethod()
        loadExpirationInterval()
        loadQuantity()
        loadUseStaticExpirationTime()
        loadNotifications()
        loadNotificationsMinutesBefore()
    }

    private func loadDeliveryMethod() {
        guard let sdk = sdk else { return }
        controls.deliveryMethodButton.setTitle(sdk.settings.deliveryMethod.rawValue)
    }

    private func loadExpirationInterval() {
        guard let interval = sdk?.settings.expirationInterval else { return }
        controls.expirationIntervalButton.setTitle(interval.displayableString)
    }

    private func loadQuantity() {
        guard let settings = sdk?.settings else { return }
        let method = settings.deliveryMethod.value
        // Currently, only .Patches support a quantity > 1
        let quantity = method == .Patches ? settings.quantity.rawValue : 1
        if quantity != settings.quantity.rawValue {
            settings.setQuantity(to: quantity)
        }
        controls.quantityButton.setTitle("\(quantity)")
        controls.reflect(method: method)
    }

    private func loadUseStaticExpirationTime() {
        guard let sdk = sdk else { return }
        let useStaticExpirationTime = sdk.settings.useStaticExpirationTime.value
        controls.useStaticExpirationTimeSwitch.setOn(useStaticExpirationTime)
    }

    private func loadNotifications() {
        guard let sdk = sdk else { return }
        controls.notificationsSwitch.setOn(sdk.settings.notifications.value)
    }

    private func loadNotificationsMinutesBefore() {
        guard let sdk = sdk else { return }
        let minutesBefore = sdk.settings.notificationsMinutesBefore.value
        controls.notificationsMinutesBeforeSlider.maximumValue = Float(
            DefaultSettings.MAX_SUPPORTED_NOTIFICATIONS_MINUTES_BEFORE
        )
        if controls.notificationsSwitch.isOn {
            controls.notificationsMinutesBeforeSlider.value = Float(minutesBefore)
            controls.notificationsMinutesBeforeValueLabel.text = String(minutesBefore)
            controls.notificationsMinutesBeforeValueLabel.textColor = PDColors[.Text]
        } else {
            controls.notificationsMinutesBeforeValueLabel.textColor = UIColor.lightGray
        }
    }
}
