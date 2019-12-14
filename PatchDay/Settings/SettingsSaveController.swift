//
//  SettingsSaveController.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/20/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


class SettingsSaveController {
    
    private let viewModel: SettingsViewModel
    private let controls: SettingsControls
    
    init(viewModel: SettingsViewModel, controls: SettingsControls) {
        self.controls = controls
        self.viewModel = viewModel
    }
    
    public func save(_ key: PDDefault, for row: Int) {
        viewModel.notifications?.cancelAllExpiredHormoneNotifications()
        switch key {
        case .DeliveryMethod: saveDeliveryMethodChange(row)
        case .Quantity: saveQuantityChange(row)
        case .ExpirationInterval: saveIntervalChange(row)
        case .Theme: saveThemeChange(row)
        default: print("Error: No picker for key \(key)")
        }
        viewModel.notifications?.requestAllExpiredHormoneNotifications()
    }
    
    private func saveDeliveryMethodChange(_ row: Int) {
        viewModel.saveDeliveryMethod(deliveryMethodIndex: row, controls: controls)
    }
    
    private func saveQuantityChange(_ row: Int) {
        let cancel = createCancelSaveQuantityButtonClosure()
        viewModel.saveQuantity(quantityIndex: row, cancelAction: cancel)
    }
    
    private func saveIntervalChange(_ row: Int) {
        viewModel.saveExpirationInterval(expirationIntervalIndex: row)
    }
    
    private func saveThemeChange(_ row: Int) {
        viewModel.saveTheme(themeIndex: row)
    }
    
    private func createCancelSaveQuantityButtonClosure() -> (Int) -> () {
        let cancel: (Int) -> () = {
            oldQuantity in
            self.controls.quantityButton.setTitle("\(oldQuantity)")
        }
        return cancel
    }
}
