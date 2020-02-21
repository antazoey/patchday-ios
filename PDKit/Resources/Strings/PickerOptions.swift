//
//  PickerOptions.swift
//  PDKit
//
//  Created by Juliya Smith on 4/29/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public class PickerOptions {
    
    public static var deliveryMethods: [String] {
        let comment = "Displayed on a button and in a picker."
        return [
            NSLocalizedString("Patches", comment: comment),
            NSLocalizedString("Injections", comment: comment)
        ]
    }
    
    public static func getDeliveryMethod(at i: Index) -> DeliveryMethod {
        let choice = deliveryMethods.tryGet(at: i)
        return getDeliveryMethod(for: choice)
    }
    
    public static func getDeliveryMethodString(for method: DeliveryMethod) -> String {
        switch method {
        case .Patches: return deliveryMethods[0]
        case .Injections: return deliveryMethods[1]
        }
    }
    
    public static func getDeliveryMethod(for pickerString: String?) -> DeliveryMethod {
        switch pickerString {
        case deliveryMethods[1]: return .Injections
        default: return .Patches
        }
    }
    
    public static func getQuantity(at i: Index) -> Quantity {
        if let quantityString = quantities.tryGet(at: i),
            let quantityInt = Int(quantityString),
            let quantity = Quantity(rawValue: quantityInt) {

            return quantity
        }
        return .One
    }
    
    public static func getDefaultQuantityString(deliveryMethod: DeliveryMethod) -> String {
        switch deliveryMethod {
        case .Patches: return quantities[2]
        case .Injections: return quantities[0]
        }
    }

    public static func getStrings(for key: PDSetting) -> [String] {
        switch key {
        case .DeliveryMethod: return deliveryMethods
        case .ExpirationInterval: return expirationIntervals
        case .Quantity: return quantities
        case .Theme: return themes
        default: return []
        }
    }
    
    public static func getPickerOption(key: PDSetting, row: Index) -> String? {
        switch key {
        case .DeliveryMethod: return deliveryMethods.tryGet(at: row)
        case .Quantity: return quantities.tryGet(at: row)
        case .ExpirationInterval: return expirationIntervals.tryGet(at: row)
        case .Theme: return themes.tryGet(at: row)
        default: return nil
        }
    }
    
    public static let expirationIntervals: [String] = {
        let comment1 = "Displayed on a button and in a picker."
        let comment2 = "Displayed in a picker."
        return [
            NSLocalizedString("Twice a week", tableName: nil, comment: comment1),
            NSLocalizedString("Once a week", tableName: nil, comment: comment2),
            NSLocalizedString("Once every two weeks", comment: comment1)
        ]
    }()
    
    public static func getExpirationInterval(for interval: ExpirationInterval) -> String {
        switch interval {
        case .TwiceAWeek: return expirationIntervals[0]
        case .OnceAWeek: return expirationIntervals[1]
        case .EveryTwoWeeks: return expirationIntervals[2]
        }
    }
    
    public static func getExpirationInterval(for pickerString: String) -> ExpirationInterval {
        switch pickerString {
        case expirationIntervals[1]: return .OnceAWeek
        case expirationIntervals[2]: return .EveryTwoWeeks
        default: return .TwiceAWeek
        }
    }
    
    public static func getOptionsCount(for def: PDSetting?) -> Int {
        guard let d = def else { return 0 }
        switch (d) {
        case .DeliveryMethod: return deliveryMethods.count
        case .ExpirationInterval: return expirationIntervals.count
        case .Quantity: return quantities.count
        case .Theme: return themes.count
        default: return 0
        }
    }
    
    public static let quantities: [String] = {
        let comment = "Displayed in a picker."
        return [
            NSLocalizedString("1", comment: comment),
            NSLocalizedString("2", comment: comment),
            NSLocalizedString("3", comment: comment),
            NSLocalizedString("4", comment: comment)
        ]
    }()
    
    public static let themes: [String] = {
        let comment = "Displayed in a picker."
        return [
            NSLocalizedString("Light", comment: comment),
            NSLocalizedString("Dark", comment: comment)
        ]
    }()
    
    public static func getTheme(for theme: PDTheme) -> String {
        switch theme {
        case .Light: return themes[0]
        case .Dark: return themes[1]
        }
    }
    
    public static func getTheme(for pickerString: String) -> PDTheme {
        switch pickerString {
        case themes[1]: return .Dark
        default: return .Light
        }
    }
    
    public static func getTheme(at index: Index) -> String? {
        themes.tryGet(at: index)
    }
 }
