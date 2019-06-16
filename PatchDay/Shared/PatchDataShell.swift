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
    
    private static let comment1 = "Displayed on a button and in a picker."
    private static let comment2 = "Displayed in a picker."
    
    typealias S = PDPickerStrings
    
    public static func getSuggestedSite(for site: String) -> String {
        let set = patchData.defaults.setSiteIndex
        if let suggestedSite = patchData.siteSchedule.suggest(changeIndex: set) {
            return suggestedSite.getName() ?? ""
        }
        return ""
    }
    
    public static func getPickerStrings(for key: PDDefault) -> [String] {
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
    
    public static var currentDeliveryMethod: String {
        get {
            let deliv = patchData.defaults.deliveryMethod.value
            return PDPickerStrings.getDeliveryMethod(for: deliv)
        }
    }
    
    public static func getDefaultOptionsCount(for def: PDDefault?) -> Int {
        if let d = def {
            switch (d) {
            case .DeliveryMethod:
                return PDPickerStrings.deliveryMethods.count
            case .ExpirationInterval:
                return PDPickerStrings.expirationIntervals.count
            case .Quantity:
                return PDPickerStrings.quantities.count
            case .Theme:
                return PDPickerStrings.themes.count
            default:
                return 0
            }
        }
        return 0
    }
    
    public static func getDeliveryMethod(at i: Index) -> DeliveryMethod {
        if i < S.deliveryMethods.count && i >= 0 {
            let choice = S.deliveryMethods[i]
            return PDPickerStrings.getDeliveryMethod(for: choice)
        }
        return .Patches
    }
    
    public static func setDeliveryMethodIfSafe(to method: DeliveryMethod) -> Bool {
        if patchData.estrogenSchedule.isEmpty() &&
            patchData.siteSchedule.isDefault(deliveryMethod: method) {

            PatchDataShell.setDeliveryMethod(to: method)
            return true
        }
        return false
    }
    
    public static func setThemeIfSafe(toMethodAt i: Index) -> String {
        if i < PDPickerStrings.themes.count && i >= 0 {
            let choice = PDPickerStrings.themes[i]
            let theme = PDPickerStrings.getTheme(for: choice)
            patchData.defaults.set(&patchData.defaults.theme, to: theme)
            return choice
        }
        return ""
    }
    
    public static func setExpirationIntervalIfSafe(at i: Index) -> (didSet: Bool, chosenIntervalRaw: String) {
        if i < PDPickerStrings.expirationIntervals.count && i >= 0 {
            let choice = PDPickerStrings.expirationIntervals[i]
            if let interval = ExpirationIntervalUD.makeExpirationInterval(from: choice) {
                patchData.defaults.set(&patchData.defaults.expirationInterval, to: interval)
                return (true, choice)
            }
        }
        return (false, "")
    }
    
    public static func setQuantity(to q: Int,
                                   oldQuantityRaw: Int,
                                   reset: @escaping ((Int) -> ()),
                                   cancel: @escaping ((Int) -> ())) {
        if q < PDPickerStrings.quantities.count && q >= 0,
            let oldQuantity = Quantity(rawValue: oldQuantityRaw),
            let newQuantityRaw = Int(PDPickerStrings.quantities[q]),
            let newQuantity = Quantity(rawValue: newQuantityRaw) {
            patchData.defaults.setQuantityWithWarning(to: newQuantity,
                                                      oldQ: oldQuantity,
                                                      reset: reset,
                                                      cancel: cancel)
        }
    }
    
    public static func getVCTitle(for deliveryMethod: DeliveryMethod) -> String {
            switch deliveryMethod {
            case .Patches:
                return PDStrings.VCTitles.patches
            case .Injections:
                return PDStrings.VCTitles.injections
            }
    }
    
    public static let pillCounts: [String] = { return [S.quantities[0], S.quantities[1]] }()
    
    private static func setDeliveryMethod(to method: DeliveryMethod) {
        patchData.defaults.setDeliveryMethod(to: method)
        patchData.defaults.setSiteIndex(to: 0)
        patchData.schedule.setEstrogenDataForToday()
    }
}
