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
    public static let Patches = NSLocalizedString("Patches", comment: comment)
    public static let Injections = NSLocalizedString("Injections", comment: comment)
    public static let Gel = NSLocalizedString("Gel", comment: comment)

    public static var deliveryMethods: [String] {
        [Patches, Injections, Gel]
    }

    public static var expirationIntervals: [String] {
        xDaysValues.map {
            switch $0 {
                case "1.0": return OnceDaily
                case "3.5": return TwiceWeekly
                case "7.0": return OnceWeekly
                case "14.0": return OnceEveryTwoWeeks
                default: return XDaysUD.makeDisplayable($0)
            }
        }
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
            case Patches: return .Patches
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

    public static func getExpirationInterval(for interval: ExpirationIntervalUD) -> String {
        switch interval.value {
            case .OnceDaily: return OnceDaily
            case .TwiceWeekly: return TwiceWeekly
            case .OnceWeekly: return OnceWeekly
            case .EveryTwoWeeks: return OnceEveryTwoWeeks
            case .EveryXDays: return XDaysUD.makeDisplayable(interval.xDays.value)
        }
    }

    public static func getExpirationInterval(for pickerString: String) -> ExpirationInterval {
        switch pickerString {
            case OnceDaily: return .OnceDaily
            case TwiceWeekly: return .TwiceWeekly
            case OnceWeekly: return .OnceWeekly
            case OnceEveryTwoWeeks: return .EveryTwoWeeks
            default: return .EveryXDays
        }
    }

    public static subscript(setting: PDSetting?) -> [String] {
        guard let setting = setting else { return [] }
        switch setting {
            case .DeliveryMethod: return deliveryMethods
            case .ExpirationInterval: return expirationIntervals
            case .Quantity: return quantities
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

    private static var xDaysValues: [String] {
        (1...ExpirationIntervalDaysLastInteger).reduce([]) {
            $0 + ["\(Float($1))", "\(Float($1) + 0.5)"]
        }
    }
}
