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
    
    private let codeBehind: SettingsCodeBehind
    private let controls: SettingsControls
    
    init(codeBehind: SettingsCodeBehind, controls: SettingsControls) {
        self.controls = controls
        self.codeBehind = codeBehind
    }
    
    public func save(_ key: PDDefault, for row: Int) {
        codeBehind.notifications?.cancelAllExpiredHormoneNotifications()
        switch key {
        case .DeliveryMethod :
            saveDeliveryMethodChange(row)
        case .Quantity :
            saveQuantityChange(row)
        case .ExpirationInterval :
            saveIntervalChange(row)
        case .Theme :
            saveThemeChange(row)
        default:
            print("Error: No picker for key \(key)")
        }
        codeBehind.notifications?.resendAllExpiredHormoneNotifications()
    }
    
    private func saveDeliveryMethodChange(_ row: Int) {
        codeBehind.saveDeliveryMethod(deliveryMethodIndex: row, controls: controls)
    }
    
    private func saveQuantityChange(_ row: Int) {
        let cancel = createCancelSaveQuantityButtonClosure()
        codeBehind.saveQuantity(quantityIndex: row, cancelAction: cancel)
    }
    
    private func saveIntervalChange(_ row: Int) {
        codeBehind.saveExpirationInterval(expirationIntervalIndex: row)
    }
    
    private func saveThemeChange(_ row: Int) {
        codeBehind.saveTheme(themeIndex: row)
    }
    
    private func createCancelSaveQuantityButtonClosure() -> (Int) -> () {
        let cancel: (Int) -> () = {
            oldQuantity in
            self.controls.quantityButton.setTitle("\(oldQuantity)", for: .normal)
        }
        return cancel
    }
}
