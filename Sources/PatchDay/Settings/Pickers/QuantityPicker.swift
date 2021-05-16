//
//  QuantityPicker.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/16/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import UIKit

class QuantityPicker: SettingsPicker {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setting = .Quantity
        self.getStartRow = { self.indexer?.quantityStartIndex ?? 0 }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setting = .Quantity
        self.getStartRow = { self.indexer?.quantityStartIndex ?? 0 }
    }
}
