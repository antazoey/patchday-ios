//
//  SettingsStateSaver.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/20/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


class SettingsStateSaver: CodeBehindDependencies<SettingsStateSaver> {

    private let controls: SettingsControls
    private let applyTheme: () -> ()
    
    init(controls: SettingsControls, themeChangeHook: @escaping () -> ()) {
        self.controls = controls
        self.applyTheme = themeChangeHook
        super.init()
    }
    
    public func save(_ key: PDSetting, selectedRow: Index) {
        notifications?.cancelAllExpiredHormoneNotifications()
        switch key {
        case .DeliveryMethod: saveDeliveryMethodChange(selectedRow)
        case .Quantity: saveQuantity(selectedRow)
        case .ExpirationInterval: saveExpirationInterval(selectedRow)
        case .Theme: saveTheme(selectedRow)
        default: log.error("Error: No picker for key \(key)")
        }
        notifications?.requestAllExpiredHormoneNotifications()
    }
    
    private func saveDeliveryMethodChange(_ selectedRow: Index) {
        if let sdk = sdk {
            let newMethod = PickerOptions.getDeliveryMethod(at: selectedRow)
            if sdk.isFresh {
                sdk.settings.setDeliveryMethod(to: newMethod)
            } else {
                presentDeliveryMethodMutationAlert(choice: newMethod, controls: controls)
            }
        }
    }
    
    private func presentDeliveryMethodMutationAlert(choice: DeliveryMethod, controls: SettingsControls) {
        let decline = {
            (_ method: DeliveryMethod) -> () in
            let methodTitle = PickerOptions.getDeliveryMethodString(for: choice)
            switch choice {
            case .Patches:
                controls.deliveryMethodButton.setTitleForNormalAndDisabled(methodTitle)
                controls.quantityButton.isEnabled = true
                controls.quantityArrowButton.isEnabled = true
            case .Injections:
                controls.deliveryMethodButton.setTitleForNormalAndDisabled(methodTitle)
                controls.quantityButton.isEnabled = false
                controls.quantityArrowButton.isEnabled = false
            }
        }
        let handlers = DeliveryMethodMutationAlertActionHandler(decline: decline)
        alerts?.presentDeliveryMethodMutationAlert(newMethod: choice, handlers: handlers)
    }
    
    private func saveQuantity(_ selectedRow: Index) {
        let cancel = createCancelSaveQuantityButtonClosure()
        let newQuantity = PickerOptions.getQuantity(at: selectedRow).rawValue
        QuantityMutator(
            sdk: sdk,
            alerts: alerts,
            tabs: tabs,
            notifications: notifications,
            cancel: cancel
        ).setQuantity(to: newQuantity)
    }
    
    private func createCancelSaveQuantityButtonClosure() -> (Int) -> () {
        let cancel: (Int) -> () = {
            oldQuantity in
            self.controls.quantityButton.setTitle("\(oldQuantity)")
        }
        return cancel
    }
    
    private func saveExpirationInterval(_ selectedRow: Index) {
        if let newInterval = PickerOptions.expirationIntervals.tryGet(at: selectedRow) {
            sdk?.settings.setExpirationInterval(to: newInterval)
        }
    }
    
    private func saveTheme(_ selectedRow: Int) {
        if let themeName = PickerOptions.getTheme(at: selectedRow) {
            let theme = PickerOptions.getTheme(for: themeName)
            sdk?.settings.setTheme(to: theme)
        }
        applyTheme()
    }
}
