//
//  DeliveryMethodButtonSet.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/20/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


struct PickerActivationProperties {
    var picker: UIPickerView
    var activator: UIButton
    var options: [String]
    var startRow: Index
    var propertyKey: PDDefault
}

struct SettingsControls {
    let deliveryMethodButton: UIButton
    let quantityButton: UIButton
    let quantityArrowButton: UIButton
    let expirationIntervalButton: UIButton
    let notificationsSwitch: UISwitch
    let notificationsMinutesBeforeSlider: UISlider
    let notificationsMinutesBeforeValueLabel: UILabel
    let themeButton: UIButton
}

struct SettingsPickers {
    let quantityPicker: UIPickerView
    let deliveryMethodPicker: UIPickerView
    let expirationIntervalPicker: UIPickerView
    let themePicker: UIPickerView
}
