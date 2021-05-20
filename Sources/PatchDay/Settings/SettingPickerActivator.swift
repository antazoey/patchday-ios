//
//  SettingPickerActivator.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/19/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class SettingsPickerActivator: UIButton {

    private let buttonSubId = "Button"
    private let arrowSubId = "Arrow"

    /// Converts a `UIButton.restorationId` to a `PDSetting`.
    /// The ID must end with either `Button` or `ArrowButton` and be the name of a `PDSetting`.
    func getSettingFromButtonRestorationId() -> PDSetting? {
        guard let id = restorationIdentifier else { return nil }
        guard id.substring(from: id.count - buttonSubId.count) == buttonSubId else { return nil }
        var settingId = id.substring(to: id.count - buttonSubId.count)

        if settingId.substring(from: settingId.count - arrowSubId.count) == arrowSubId {
            // Is an arrow button
            settingId = settingId.substring(to: settingId.count - arrowSubId.count)
        }
        return IdToSettingMap[settingId.lowercased()]
    }

    /// Restoration IDs are defined in the storyboard. These only apply the settings that have options chosen via pickers.
    private var IdToSettingMap: [String: PDSetting] {
        [
            "deliverymethod": .DeliveryMethod,
            "expirationinterval": .ExpirationInterval,
            "quantity": .Quantity
        ]
    }
}
