//
//  ExpirationIntervalSettingsPicker.swift
//  PDTest
//
//  Created by Juliya Smith on 5/5/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class ExpirationInteravlSettingsPicker: ExpirationIntervalSettingsPicking {

    var forXDays: SettingPicking {
        self.
        self.options = SettingsOptions.xDaysValues
        return self
    }

    var forIntervals: SettingsPicking {
        self.options = SettingsOptions.expirationIntervals
        return self
    }
}
