//
//  DeliveryMethodPicker.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/16/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import UIKit

class DeliveryMethodPicker: SettingsPicker {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setting = .DeliveryMethod
        self.getStartRow = { self.indexer?.deliveryMethodStartIndex ?? 0 }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setting = .DeliveryMethod
        self.getStartRow = { self.indexer?.deliveryMethodStartIndex ?? 0 }
    }
}
