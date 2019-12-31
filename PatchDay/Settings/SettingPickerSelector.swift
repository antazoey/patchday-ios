//
//  SettingPickerSelector.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/21/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class SettingsPickerSelector {
    
    private let pickers: SettingsPickers
    private let log = PDLog<SettingsPickerSelector>()
    
    public init(pickers: SettingsPickers) {
        self.pickers = pickers
    }
    
    func selectPicker(key: PDDefault) -> UIPickerView? {
        switch key {
        case.Quantity: return pickers.quantityPicker
        case .DeliveryMethod: return pickers.deliveryMethodPicker
        case .ExpirationInterval: return pickers.expirationIntervalPicker
        case .Theme: return pickers.themePicker
        default:
            log.error("No picker for given key \(key)")
            return nil
        }
    }
}
