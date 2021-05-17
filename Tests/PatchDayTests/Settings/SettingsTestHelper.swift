//
//  SettingsTestHelper.swift
//  PatchDayTests
//
//  Created by Juliya Smith on 5/10/20.

import UIKit

@testable
import PatchDay

class SettingsTestHelper {

    private let methodButton = UIButton()
    private let quantityButton = UIButton()
    private let quantityArrowButton = UIButton()
    private let xDaysButton = UIButton()
    private let expirationButton = UIButton()
    private let notificationsSwitch = UISwitch()
    private let notificationsSlider = UISlider()
    private let notificationsMinutesLabel = UILabel()

    public func createControls() -> SettingsControls {
        SettingsControls(
            deliveryMethodButton: methodButton,
            quantityButton: quantityButton,
            quantityArrowButton: quantityArrowButton,
            expirationIntervalButton: expirationButton,
            notificationsSwitch: notificationsSwitch,
            notificationsMinutesBeforeSlider: notificationsSlider,
            notificationsMinutesBeforeValueLabel: notificationsMinutesLabel
        )
    }
}
