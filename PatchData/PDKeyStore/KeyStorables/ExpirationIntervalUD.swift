//
//  ExpirationIntervalUD.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public enum ExpirationInterval: String {
    case TwiceAWeek = "One half-week"
    case OnceAWeek = "One week"
    case EveryTwoWeeks = "Two weeks"
}

// MARK: - Private

public class ExpirationIntervalUD: PDKeyStorable {
    
    public typealias Value = ExpirationInterval
    
    public typealias RawValue = String
    
    public var value: ExpirationInterval
    
    public var rawValue: String {
        get {
            return value.rawValue
        }
    }
    
    public static var key = PDDefault.ExpirationInterval
    
    public required init(with val: String) {
        if let rawExp = ExpirationInterval(rawValue: val) {
            value = rawExp
        } else if let expFromhuman = ExpirationIntervalUD.makeExpirationInterval(from: val) {
            value = expFromhuman
        } else {
            value = ExpirationInterval.TwiceAWeek
        }
    }
    
    public required init(with val: ExpirationInterval) {
        value = val
    }
    
    public var hours: Int {
        get {
            switch value {
            case .TwiceAWeek:
                return 84
            case .OnceAWeek:
                return 168
            case .EveryTwoWeeks:
                return 336
            }
        }
    }
    
    public var humanPresentableValue: String {
        get {
            return ExpirationIntervalUD.getHumanPresentableValue(from: rawValue)!
        }
    }
    
    public static func makeExpirationInterval(from humanReadableStr: String) -> ExpirationInterval? {
        switch humanReadableStr {
        case PDPickerStrings.expirationIntervals[0]:
            return ExpirationInterval.TwiceAWeek
        case PDPickerStrings.expirationIntervals[1]:
            return ExpirationInterval.OnceAWeek
        case PDPickerStrings.expirationIntervals[2]:
            return ExpirationInterval.EveryTwoWeeks
        default:
            return nil
        }
    }
    
    private static func getHumanPresentableValue(from v: String) -> String? {
        let dispStrs = PDPickerStrings.expirationIntervals
        let strDict = [ExpirationInterval.TwiceAWeek.rawValue : dispStrs[0],
                       ExpirationInterval.OnceAWeek.rawValue : dispStrs[1],
                       ExpirationInterval.EveryTwoWeeks.rawValue : dispStrs[2]]
        return strDict[v]
    }
}
