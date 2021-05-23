//
//  SettingsTestHelper.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 5/10/20.

import UIKit

@testable
import PatchDay

class SettingsTestHelper {

    private let deliveryMethodButton = SettingsPickerActivator()
    private let quantityButton = SettingsPickerActivator()
    private let quantityArrowButton = SettingsPickerActivator()
    private let expirationButton = SettingsPickerActivator()
    private let notificationsSwitch = UISwitch()
    private let notificationsSlider = UISlider()
    private let notificationsMinutesLabel = UILabel()
    private let useStaticExpirationTimeSwitch = UISwitch()

    public func createControls() -> SettingsControls {
        SettingsControls(
            deliveryMethodButton: deliveryMethodButton,
            quantityButton: quantityButton,
            quantityArrowButton: quantityArrowButton,
            expirationIntervalButton: expirationButton,
            notificationsSwitch: notificationsSwitch,
            notificationsMinutesBeforeSlider: notificationsSlider,
            notificationsMinutesBeforeValueLabel: notificationsMinutesLabel,
            useStaticExpirationTimeSwitch: useStaticExpirationTimeSwitch
        )
    }
}
