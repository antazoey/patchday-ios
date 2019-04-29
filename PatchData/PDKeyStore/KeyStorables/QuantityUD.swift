//
//  QuantityUD.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public enum Quantity: Int {
    case One = 1
    case Two = 2
    case Three = 3
    case Four = 4
}

public class QuantityUD: PDKeyStorable {
    
    public typealias Value = Quantity
    
    public typealias RawValue = Int
    
    public var value: Quantity
    
    public var rawValue: Int {
        get {
            return value.rawValue
        }
    }
    
    public static var key = PDDefault.Quantity
    
    
    public init(with val: Int) {
        if let q = Quantity.init(rawValue: val) {
            value = q
        }
        value = Quantity.Four
    }
    
    public init(with val: Quantity) {
        value = val
    }
}
