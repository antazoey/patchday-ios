//
//  SettingsViewModelProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 5/2/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public protocol SettingsViewModelProtocol {

    /// The index to open the delivery method picker at.
    var deliveryMethodStartIndex: Index { get }

    /// The index to open the quantity picker at.
    var quantityStartIndex: Index { get }

    /// The index to open the expiration interval picker at.
    var expirationIntervalStartIndex: Index { get }

    /// Whether the expiration interval involves the use of the xDays property.
    var usesXDays: Bool { get }

    /// Close or open a picker.
    func activatePicker(_ picker: SettingsPickerViewing)

    /// Set the new notifications value and execute other app side-effects. Returns a stringified version of the new value.
    func handleNewNotificationsMinutesValue(_ newValue: Float) -> String

    /// Set UI properties using stored values.
    func reflect()

    /// Set the notifications setting.
    func setNotifications(_ newValue: Bool)

    /// Set the notifications-before-minutes setting.
    func setNotificationsMinutes(_ newValue: Int)
}
