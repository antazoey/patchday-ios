//
//  PickerOptions.swift
//  PDKit
//
//  Created by Juliya Smith on 4/29/19.

import Foundation

public class SettingsOptions {
    private static let comment = "Displayed on a button and in a picker."
    public static let OnceDaily = NSLocalizedString("Once Daily", tableName: nil, comment: comment)
    public static let TwiceWeekly = NSLocalizedString(
        "Twice Weekly", tableName: nil, comment: comment
    )
    public static let OnceWeekly = NSLocalizedString(
        "Once Weekly", tableName: nil, comment: comment
    )
    public static let OnceEveryTwoWeeks = NSLocalizedString(
        "Once Every Two Weeks", comment: comment
    )
    public static let EveryXDays = NSLocalizedString("Every X Days", comment: comment)

    public static var deliveryMethods: [String] {
        [
            NSLocalizedString("Patches", comment: comment),
            NSLocalizedString("Injections", comment: comment),
            NSLocalizedString("Gel", comment: comment)
        ]
    }

    public static var xDaysValues: [String] {
        (1...SupportedExpirationIntervalDaysLimit).map { "\($0)" }
    }

    public static var expirationIntervals: [String] {
        [OnceDaily, TwiceWeekly, OnceWeekly, OnceEveryTwoWeeks, EveryXDays]
    }

    public static func getDeliveryMethod(at i: Index) -> DeliveryMethod {
        let choice = deliveryMethods.tryGet(at: i)
        return getDeliveryMethod(for: choice)
    }

    public static func getDeliveryMethodString(for method: DeliveryMethod) -> String {
        switch method {
            case .Patches: return deliveryMethods[0]
            case .Injections: return deliveryMethods[1]
            case .Gel: return deliveryMethods[2]
        }
    }

    public static func getDeliveryMethod(for pickerString: String?) -> DeliveryMethod {
        switch pickerString {
            case deliveryMethods[0]: return .Patches
            case deliveryMethods[1]: return .Injections
            case deliveryMethods[2]: return .Gel
            default: return DefaultSettings.DeliveryMethodValue
        }
    }

    public static func getQuantity(at index: Index) -> Quantity {
        if let quantityString = quantities.tryGet(at: index),
            let quantityInt = Int(quantityString),
            let quantity = Quantity(rawValue: quantityInt) {
            return quantity
        }
        return .One
    }

    public static func getPickerOption(key: PDSetting, row: Index) -> String? {
        switch key {
            case .DeliveryMethod: return deliveryMethods.tryGet(at: row)
            case .Quantity: return quantities.tryGet(at: row)
            case .ExpirationInterval: return expirationIntervals.tryGet(at: row)
            default: return nil
        }
    }

    public static func getExpirationInterval(for interval: ExpirationInterval) -> String {
        switch interval {
            case .OnceDaily: return expirationIntervals[0]
            case .TwiceWeekly: return expirationIntervals[1]
            case .OnceWeekly: return expirationIntervals[2]
            case .EveryTwoWeeks: return expirationIntervals[3]
            case .EveryXDays: return expirationIntervals[4]
        }
    }

    public static func getExpirationInterval(for pickerString: String) -> ExpirationInterval {
        switch pickerString {
            case expirationIntervals[0]: return .OnceDaily
            case expirationIntervals[1]: return .TwiceWeekly
            case expirationIntervals[2]: return .OnceWeekly
            case expirationIntervals[3]: return .EveryTwoWeeks
            case expirationIntervals[4]: return .EveryXDays
            default: return DefaultSettings.ExpirationIntervalValue
        }
    }

    public static subscript(setting: PDSetting?) -> [String] {
        guard let setting = setting else { return [] }
        switch setting {
            case .DeliveryMethod: return deliveryMethods
            case .ExpirationInterval: return expirationIntervals
            case .Quantity: return quantities
            case .XDays: return xDaysValues
            default: return []
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
}
