//
//  DeliveryMethodButtonSet.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/20/19.

import UIKit
import PDKit

struct SettingsControls {
    let deliveryMethodButton: UIButton
    let quantityButton: UIButton
    let quantityArrowButton: UIButton
    let expirationIntervalButton: UIButton
    let xDaysButton: UIButton
    let notificationsSwitch: UISwitch
    let notificationsMinutesBeforeSlider: UISlider
    let notificationsMinutesBeforeValueLabel: UILabel

    func reflect(method: DeliveryMethod) {
        switch method {
            case .Gel, .Injections:
                quantityButton.isEnabled = false
                quantityArrowButton.isEnabled = false
            default:
                quantityButton.isEnabled = true
                quantityArrowButton.isEnabled = true
        }
    }
}
