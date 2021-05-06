//
//  ExpirationIntervalSettingsPicking.swift
//  PDTest
//
//  Created by Juliya Smith on 5/5/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public protocol ExpirationIntervalSettingsPicking {

    /// This instance in a mode for picking expiration interval values.
    var forIntervals: SettingsPicking { get }
    
    /// This instance in a mode for picking XDays values.
    var forXDays: SettingsPicking { get }
}
