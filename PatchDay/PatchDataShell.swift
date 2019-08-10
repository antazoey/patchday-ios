//
//  PDPickerStrings.swift
//  PDKit
//
//  Created by Juliya Smith on 4/29/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit
import PatchData

public class PatchDataShell {
    
    typealias S = PDPickerStrings
    
    init(_ sdk: PatchDataSDK) {
        self.sdk = sdk
    }
    
    let sdk: PatchDataSDK
    
    public func getSuggestedSite(for site: String) -> String {
        let set = sdk.defaults.setSiteIndex
        if let suggestedSite = sdk.siteSchedule.suggest(changeIndex: set) {
            return suggestedSite.name ?? ""
        }
        return ""
    }
    
    public func getPickerStrings(for key: PDDefault) -> [String] {
        switch key {
        case PDDefault.DeliveryMethod:
            return S.deliveryMethods
        case PDDefault.ExpirationInterval:
            return S.expirationIntervals
        case PDDefault.Quantity:
            return S.quantities
        case PDDefault.Theme:
            return S.themes
        default:
            return []
        }
    }
    
    public  var currentDeliveryMethod: String {
        get {
            let deliv = sdk.defaults.deliveryMethod.value
            return PDPickerStrings.getDeliveryMethod(for: deliv)
        }
    }
    
    public func getDefaultOptionsCount(for def: PDDefault?) -> Int {
        if let d = def {
            switch (d) {
            case .DeliveryMethod:
                return S.deliveryMethods.count
            case .ExpirationInterval:
                return S.expirationIntervals.count
            case .Quantity:
                return S.quantities.count
            case .Theme:
                return S.themes.count
            default:
                return 0
            }
        }
        return 0
    }
    
    public func getDeliveryMethod(at i: Index) -> DeliveryMethod {
        if i < S.deliveryMethods.count && i >= 0 {
            let choice = S.deliveryMethods[i]
            return S.getDeliveryMethod(for: choice)
        }
        return .Patches
    }
    
    public func setDeliveryMethodIfSafe(to method: DeliveryMethod) -> Bool {
        if sdk.estrogenSchedule.isEmpty() &&
            sdk.siteSchedule.isDefault(deliveryMethod: method) {

            sdk.defaults.setDeliveryMethod(to: method)
            return true
        }
        return false
    }
    
    public func setThemeIfSafe(toMethodAt i: Index) -> String {
        if i < S.themes.count && i >= 0 {
            let choice = PDPickerStrings.themes[i]
            let theme = PDPickerStrings.getTheme(for: choice)
            sdk.defaults.setTheme(to: theme)
            return choice
        }
        return ""
    }
    
    public func setExpirationIntervalIfSafe(at i: Index) -> (didSet: Bool, chosenIntervalRaw: String) {
        if i < S.expirationIntervals.count && i >= 0 {
            let choice = S.expirationIntervals[i]
            if let interval = ExpirationIntervalUD.makeExpirationInterval(from: choice) {
                
                sdk.defaults.setExpirationInterval(to: interval)
                return (true, choice)
            }
        }
        return (false, "")
    }
    
    public func setQuantity(to q: Int,
                            oldQuantityRaw: Int,
                            reset: @escaping ((Int) -> ()),
                            cancel: @escaping ((Int) -> ())) {
        if q < S.quantities.count && q >= 0, let newQuantityRaw = Int(S.quantities[q]) {
            sdk.state.oldQuantity = oldQuantityRaw
            
            // Decreasing - will result in deletions if user agrees
            if newQuantityRaw < oldQuantityRaw {
                sdk.state.decreasedCount = true
                app.alerts.presentQuantityMutationAlert(oldQuantity: oldQuantityRaw,
                                                        newQuantity: newQuantityRaw,
                                                        simpleSetQuantity: sdk.defaults.setQuantity(to:),
                                                        reset: reset,
                                                        cancel: cancel)
            } else {
                sdk.defaults.setQuantity(to: newQuantityRaw)
                reset(newQuantityRaw)
            }
        }
    }
    
    public let pillCounts: [String] = { return [S.quantities[0], S.quantities[1]] }()
    
    private func setDeliveryMethod(to method: DeliveryMethod) {
        sdk.defaults.setDeliveryMethod(to: method)
        sdk.defaults.setSiteIndex(to: 0)
        sdk.schedule.setEstrogenDataForToday()
    }
}
