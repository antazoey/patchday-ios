//
//  SettingsReflector.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/20/19.

import Foundation
import PDKit

class SettingsReflector: CodeBehindDependencies<SettingsReflector> {

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
        loadNotifications()
        loadNotificationsMinutesBefore()
    }

    private func loadDeliveryMethod() {
        guard let method = sdk?.settings.deliveryMethod.rawValue else { return }
        controls.deliveryMethodButton.setTitle(method)
    }

    private func loadExpirationInterval() {
        guard let interval = sdk?.settings.expirationInterval.displayableString else { return }
        controls.expirationIntervalButton.setTitle(interval)
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

    private func loadNotifications() {
        guard let notifications = sdk?.settings.notifications.value else { return }
        controls.notificationsSwitch.setOn(notifications)
    }

    private func loadNotificationsMinutesBefore() {
        guard let minutesBefore = sdk?.settings.notificationsMinutesBefore.value else { return }
        controls.notificationsMinutesBeforeSlider.maximumValue = Float(
            DefaultSettings.MaxSupportedNotificationsMinutesBefore
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
