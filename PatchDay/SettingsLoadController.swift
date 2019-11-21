//
//  SettingsLoadController.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/20/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class SettingsLoadController {
    
    private let codeBehind: SettingsCodeBehind
    private let controls: SettingsControls
    
    init(codeBehind: SettingsCodeBehind, controls: SettingsControls) {
        self.codeBehind = codeBehind
        self.controls = controls
    }
    
    public func loadSettings() {
        loadDeliveryMethod()
        loadExpirationInterval()
        loadQuantity()
        loadNotifications()
        loadNotificationsMinutesBefore()
        loadTheme()
    }
    
    private func loadDeliveryMethod() {
        if let method = codeBehind.sdk?.defaults.deliveryMethod.rawValue {
            controls.deliveryMethodButton.setTitle(method)
        }
    }
    
    private func loadExpirationInterval() {
        if let interval = codeBehind.sdk?.defaults.expirationInterval.humanPresentableValue {
            controls.expirationIntervalButton.setTitle(interval)
        }
    }
    
    private func loadQuantity() {
        if let defaults = codeBehind.sdk?.defaults {
            let quantity = defaults.quantity.rawValue
            let method = defaults.deliveryMethod.value
            controls.quantityButton.setTitle("\(quantity)")
            if method == .Injections {
                controls.quantityButton.isEnabled = false
                controls.quantityArrowButton.isEnabled = false
                if quantity != PDConstants.OnlySupportedInjectionsQuantity {
                    defaults.setQuantity(to: PDConstants.OnlySupportedInjectionsQuantity)
                }
            }
        }
    }
    
    private func loadNotifications() {
        let isOn = codeBehind.sdk?.defaults.notifications.value
        controls.notificationsSwitch.setOn(isOn ?? false)
    }
    
    private func loadNotificationsMinutesBefore() {
        if let defaults = codeBehind.sdk?.defaults, controls.notificationsSwitch.isOn {
            let minutesBefore = defaults.notificationsMinutesBefore.value
            controls.notificationsMinutesBeforeSlider.value = Float(minutesBefore)
            controls.notificationsMinutesBeforeValueLabel.text = String(minutesBefore)
            controls.notificationsMinutesBeforeValueLabel.textColor = UIColor.black
        } else {
            controls.notificationsMinutesBeforeValueLabel.textColor = UIColor.lightGray
        }
    }
    
    private func loadTheme() {
        if let theme = codeBehind.sdk?.defaults.theme.value {
            let title = PickerOptions.getTheme(for: theme)
            controls.themeButton.setTitle(title, for: .normal)
        }
    }
}
