//
//  ExpirationIntervalSettingsPicking.swift
//
//  Created by Juliya Smith on 5/5/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public protocol ExpirationIntervalSettingsPicking: SettingsPicking {

    /// This instance in a mode for picking expiration interval values.
    var forIntervals: SettingsPicking { get }

    /// This instance in a mode for picking XDays values.
    var forXDays: SettingsPicking { get }

    /// The button that activates the picker in expiration interval mode.
    var expirationIntervalButton: UIButton { get set }

    /// The button that activates the picker in x-days mode.
    var xDaysButton: UIButton { get set }
}
