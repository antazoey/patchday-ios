//
//  SettingsPickerList.swift
//  PDKit
//
//  Created by Juliya Smith on 5/2/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class SettingsPickerList {
    private let quantityPicker: SettingsPickerViewing
    private let deliveryMethodPicker: SettingsPickerViewing
    private let expirationIntervalPicker: SettingsPickerViewing
    private lazy var log = PDLog<SettingsPickerList>()

    init(
        quantityPicker: SettingsPickerViewing,
        deliveryMethodPicker: SettingsPickerViewing,
        expirationIntervalPicker: SettingsPickerViewing
    ) {
        self.quantityPicker = quantityPicker
        self.deliveryMethodPicker = deliveryMethodPicker
        self.expirationIntervalPicker = expirationIntervalPicker
    }

    var all: [SettingsPickerViewing] {
        [
            quantityPicker,
            deliveryMethodPicker,
            expirationIntervalPicker
        ]
    }

    subscript(_ setting: PDSetting) -> SettingsPickerViewing? {
        switch setting {
            case .Quantity: return quantityPicker
            case .DeliveryMethod: return deliveryMethodPicker
            case .ExpirationInterval: return expirationIntervalPicker
            case .XDays: return expirationIntervalPicker
            default:
                log.error("No picker for given setting \(setting)")
                return nil
        }
    }

    @discardableResult
    func select(_ setting: PDSetting) -> SettingsPickerViewing? {
        guard let selectedPicker = self[setting] else { return nil }
        for picker in all where picker.view != selectedPicker.view {
            picker.close(setSelectedRow: false)
        }
        return selectedPicker
    }
}
