//
//  SettingsReflector.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/20/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


class SettingsReflector: CodeBehindDependencies<SettingsReflector> {

    private let controls: SettingsControls
    
    init(controls: SettingsControls) {
        self.controls = controls
        super.init()
    }
    
    public func reflectStoredSettings() {
        loadDeliveryMethod()
        loadExpirationInterval()
        loadQuantity()
        loadNotifications()
        loadNotificationsMinutesBefore()
        loadTheme()
    }
    
    public func reflectNewButtonTitle(key: PDDefault, newTitle: String) {
        switch key {
        case .DeliveryMethod: controls.deliveryMethodButton.setTitle(newTitle)
        case .ExpirationInterval: controls.expirationIntervalButton.setTitle(newTitle)
        case .Quantity: controls.quantityButton.setTitle(newTitle)
        case .Theme: controls.themeButton.setTitle(newTitle)
        default: break
        }
    }
    
    private func loadDeliveryMethod() {
        if let method = sdk?.userDefaults.deliveryMethod.rawValue {
            controls.deliveryMethodButton.setTitle(method)
        }
    }
    
    private func loadExpirationInterval() {
        if let interval = sdk?.userDefaults.expirationInterval.humanPresentableValue {
            controls.expirationIntervalButton.setTitle(interval)
        }
    }
    
    private func loadQuantity() {
        if let defaults = sdk?.userDefaults {
            let quantity = defaults.quantity.rawValue
            let method = defaults.deliveryMethod.value
            controls.quantityButton.setTitle("\(quantity)")
            if method == .Injections {
                controls.quantityButton.isEnabled = false
                controls.quantityArrowButton.isEnabled = false
                if quantity != OnlySupportedInjectionsQuantity {
                    defaults.setQuantity(to: OnlySupportedInjectionsQuantity)
                }
            }
        }
    }
    
    private func loadNotifications() {
        let isOn = sdk?.userDefaults.notifications.value
        controls.notificationsSwitch.setOn(isOn ?? false)
    }
    
    private func loadNotificationsMinutesBefore() {
        if let defaults = sdk?.userDefaults, controls.notificationsSwitch.isOn {
            let minutesBefore = defaults.notificationsMinutesBefore.value
            controls.notificationsMinutesBeforeSlider.value = Float(minutesBefore)
            controls.notificationsMinutesBeforeValueLabel.text = String(minutesBefore)
            controls.notificationsMinutesBeforeValueLabel.textColor = UIColor.black
        } else {
            controls.notificationsMinutesBeforeValueLabel.textColor = UIColor.lightGray
        }
    }
    
    private func loadTheme() {
        if let theme = sdk?.userDefaults.theme.value {
            let title = PickerOptions.getTheme(for: theme)
            controls.themeButton.setTitle(title)
        }
    }
}
