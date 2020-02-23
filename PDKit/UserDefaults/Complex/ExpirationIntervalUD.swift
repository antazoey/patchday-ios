//
//  ExpirationIntervalUDTests.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public class ExpirationIntervalValueHolder: ComplexValueHolding {
    
    static var twiceAWeekKey = { "One half-week" }()
    static var onceAWeekKey = { "One week" } ()
    static var everyTwoWeeksKey = { "Two weeks" }()
    
    public typealias KeyIndex = ExpirationInterval
    
    public typealias RawValue = String
    
    var indexer: ExpirationInterval
    
    required public init(indexer: ExpirationInterval) {
        self.indexer = indexer
    }
    
    public convenience init(raw: String) {
        switch raw {
        case ExpirationIntervalValueHolder.everyTwoWeeksKey:
            self.init(indexer: .EveryTwoWeeks)
        case ExpirationIntervalValueHolder.onceAWeekKey:
            self.init(indexer: .OnceWeekly)
        default:
            self.init(indexer: .TwiceWeekly)
        }
    }
    
    public var heldValue: String {
        switch indexer {
        case .TwiceWeekly: return ExpirationIntervalValueHolder.twiceAWeekKey
        case .OnceWeekly: return ExpirationIntervalValueHolder.onceAWeekKey
        case .EveryTwoWeeks: return ExpirationIntervalValueHolder.everyTwoWeeksKey
        }
    }
}

public class ExpirationIntervalUD: KeyStorable {
    
    private var v: ExpirationInterval
    private var valueHolder: ExpirationIntervalValueHolder
    
    public typealias Value = ExpirationInterval
    public typealias RawValue = String
    
    public required init(_ val: String) {
        valueHolder = ExpirationIntervalValueHolder(raw: val)
        v = valueHolder.indexer
    }
    
    public required init(_ val: ExpirationInterval) {
        v = val
        valueHolder = ExpirationIntervalValueHolder(indexer: v)
    }
    
    public convenience required init() {
        self.init(DefaultSettings.DefaultExpirationInterval)
    }
    
    public var value: ExpirationInterval {
        get { v }
        set {
            v = newValue
            valueHolder = ExpirationIntervalValueHolder(indexer: v)
        }
    }
    
    public var rawValue: String { return valueHolder.heldValue }
    
    public static var key = PDSetting.ExpirationInterval
    
    public var hours: Int {
        switch value {
        case .TwiceWeekly: return 84
        case .OnceWeekly: return 168
        case .EveryTwoWeeks: return 336
        }
    }
    
    public var humanPresentableValue: String {
        ExpirationIntervalUD.getHumanPresentableValue(from: rawValue)!
    }
    
    public static func makeExpirationInterval(from humanReadableStr: String) -> ExpirationInterval? {
        switch humanReadableStr {
        case PickerOptions.expirationIntervals[0]:
            return ExpirationInterval.TwiceWeekly
        case PickerOptions.expirationIntervals[1]:
            return ExpirationInterval.OnceWeekly
        case PickerOptions.expirationIntervals[2]:
            return ExpirationInterval.EveryTwoWeeks
        default:
            return nil
        }
    }
    
    private static func getHumanPresentableValue(from v: String) -> String? {
        let strs = PickerOptions.expirationIntervals
        let strDict = [
            ExpirationIntervalValueHolder.twiceAWeekKey : strs[0],
            ExpirationIntervalValueHolder.onceAWeekKey : strs[1],
            ExpirationIntervalValueHolder.everyTwoWeeksKey : strs[2]
        ]
        return strDict[v]
    }
}
