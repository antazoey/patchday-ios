//
//  ExpirationIntervalSettingsPicker.swift
//
//  Created by Juliya Smith on 5/5/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class ExpirationInteravlSettingsPicker: SettingsPicker, ExpirationIntervalSettingsPicking {

    private var _expirationIntervalButton: UIButton?
    private var _xDaysButton: UIButton?

    var expirationIntervalButton: UIButton {
        get { _expirationIntervalButton ?? UIButton() }
        set { _expirationIntervalButton = newValue }
    }

    var xDaysButton: UIButton {
        get { _xDaysButton ?? UIButton() }
        set { _xDaysButton = newValue }
    }

    var forIntervals: SettingsPicking {
        setSetting(.ExpirationInterval)
        return self
    }

    var forXDays: SettingsPicking {
        setSetting(.XDays)
        return self
    }

    private func setSetting(_ setting: PDSetting) {
        self.setting = setting
        if setting == .ExpirationInterval {
            self.activator = expirationIntervalButton
            self.getStartRow = { self.indexer?.expirationIntervalStartIndex ?? 0 }
        } else if setting == .XDays {
            self.activator = xDaysButton
            self.getStartRow = { self.indexer?.xDaysStartIndex ?? 0 }
        }
    }

}
