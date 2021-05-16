//
//  ExpirationIntervalSettingsPicker.swift
//
//  Created by Juliya Smith on 5/5/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class ExpirationInteravlSettingsPicker: SettingsPicker, ExpirationIntervalSettingsPicking {

    var forIntervals: SettingsPicking {
        setting = .ExpirationInterval
        options = SettingsOptions.expirationIntervals
        return self
    }

    var forXDays: SettingsPicking {
        self.setting = .XDays
        self.options = SettingsOptions.xDaysValues
        return self
    }
}
