//
//  SettingsViewModelProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 5/2/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public protocol SettingsViewModelProtocol: SettingsPickerIndexing {

    /// Whether the expiration interval involves the use of the xDays property.
    var usesXDays: Bool { get }

    /// Close or open a picker.
    func activatePicker(_ picker: SettingsPicking)

    /// Set the new notifications value and execute other app side-effects.
    /// Returns a stringified version of the new value.
    @discardableResult
    func handleNewNotificationsMinutesValue(_ newValue: Float) -> String

    /// Set UI properties using stored values.
    func reflect()

    /// Set the notifications setting.
    func setNotifications(_ newValue: Bool)
}
