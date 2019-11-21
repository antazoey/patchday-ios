//
//  SettingsCodeBehind.swift
//  PatchDay
//
//  Created by Juliya Smith on 10/29/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class SettingsCodeBehind : CodeBehindDependencies {
    
    func saveQuantity(quantityIndex: Index, cancelAction: @escaping (_ originalQuantity: Int) -> ()) {
        let newQuantity = PickerOptions.getQuantity(at: quantityIndex).rawValue
        QuantityMutator(
            sdk: sdk,
            alerts: alerts,
            tabs: tabs,
            notifications: notifications,
            cancel: cancelAction
        ).setQuantity(to: newQuantity)
    }
    
    func saveDeliveryMethod(deliveryMethodIndex: Index, controls: SettingsControls) {
        if let sdk = sdk {
            let newMethod = PickerOptions.getDeliveryMethod(at: deliveryMethodIndex)
            if sdk.isFresh {
                sdk.defaults.setDeliveryMethod(to: newMethod)
            } else {
                presentDeliveryMethodMutationAlert(choice: newMethod, controls: controls)
            }
        }
    }
    
    func saveExpirationInterval(expirationIntervalIndex: Index) {
        let newInterval = PickerOptions.expirationIntervals[expirationIntervalIndex]
        sdk?.defaults.setExpirationInterval(to: newInterval)
    }
    
    func saveTheme(themeIndex: Index) {
        if let themeName = PickerOptions.getTheme(at: themeIndex) {
            let theme = PickerOptions.getTheme(for: themeName)
            sdk?.defaults.setTheme(to: theme)
            styles?.applyTheme(theme)
        }
    }
    
    private func presentDeliveryMethodMutationAlert(choice: DeliveryMethod, controls: SettingsControls) {
        alerts?.presentDeliveryMethodMutationAlert(newMethod: choice) {
            void in
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
    }
}
