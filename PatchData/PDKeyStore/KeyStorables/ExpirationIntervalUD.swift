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
    
    public init(with val: String) {
        if let ei = ExpirationInterval(rawValue: val) {
            value = ei
        }
        value = ExpirationInterval.TwiceAWeek
    }
    
    public init(with val: ExpirationInterval) {
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
}
