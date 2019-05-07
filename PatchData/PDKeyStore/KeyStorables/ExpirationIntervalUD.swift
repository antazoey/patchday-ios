//
//  ExpirationIntervalUD.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class ExpirationIntervalValueHolder: PDValueHolding {
    
    public typealias KeyIndex = ExpirationInterval
    
    public typealias RawValue = String
    
    var indexer: ExpirationInterval
    
    required public init(indexer: ExpirationInterval) {
        self.indexer = indexer
    }
    
    public var heldValue: String {
        get {
            switch indexer {
            case .TwiceAWeek: return "One half-week"
            case .OnceAWeek: return "One week"
            case .EveryTwoWeeks: return "Two weeks"
            }
        }
    }
}

// MARK: - Private

public class ExpirationIntervalUD: PDKeyStorable {
    
    public typealias Value = ExpirationInterval
    
    private var valueHolder: ExpirationIntervalValueHolder
    
    public typealias RawValue = String
    
    public var value: ExpirationInterval
    
    public var rawValue: String {
        get { return valueHolder.heldValue }
    }
    
    public static var key = PDDefault.ExpirationInterval
    
    public required convenience init(with val: String) {
        var interval: ExpirationInterval
        if let rawExp = ExpirationInterval(rawValue: val) {
            interval = rawExp
        } else if let expFromhuman = ExpirationIntervalUD.makeExpirationInterval(from: val) {
            interval = expFromhuman
        } else {
            interval = ExpirationInterval.TwiceAWeek
        }
        self.init(with: interval)
    }
    
    public required init(with val: ExpirationInterval) {
        value = val
        valueHolder = ExpirationIntervalValueHolder(indexer: value)
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
        get { return ExpirationIntervalUD.getHumanPresentableValue(from: rawValue)! }
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
