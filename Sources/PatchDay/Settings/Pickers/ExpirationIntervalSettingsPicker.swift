//
//  ExpirationIntervalSettingsPicker.swift
//
//  Created by Juliya Smith on 5/5/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class ExpirationIntervalSettingsPicker: SettingsPicker{

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setting = .ExpirationInterval
        self.getStartRow = { self.indexer?.expirationIntervalStartIndex ?? 0 }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setting = .ExpirationInterval
        self.getStartRow = { self.indexer?.expirationIntervalStartIndex ?? 0 }
    }
}
