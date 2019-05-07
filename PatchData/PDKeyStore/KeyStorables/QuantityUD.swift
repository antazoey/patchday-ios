//
//  QuantityUD.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class QuantityValueHolder: PDValueHolding {
    
    public typealias KeyIndex = Quantity
    
    public typealias RawValue = Int
    
    var indexer: Quantity
    
    required public init(indexer: Quantity) {
        self.indexer = indexer
    }
    
    public var heldValue: Int {
        get {
            switch indexer {
            case .One: return 1
            case .Two: return 2
            case .Three: return 3
            case .Four: return 4
            }
        }  
    }
}

public class QuantityUD: PDKeyStorable {
    
    public typealias Value = Quantity
    
    private var valueHolder: QuantityValueHolder
    
    public typealias RawValue = Int
    
    public var value: Quantity
    
    public var rawValue: Int {
        get { return valueHolder.heldValue }
    }
    
    public static var key = PDDefault.Quantity
    
    public required convenience init(with val: Int) {
        var count: Quantity;
        if let q = Quantity.init(rawValue: val) {
            count = q
        } else {
            count = Quantity.Four
        }
        self.init(with: count)
    }
    
    public required init(with val: Quantity) {
        value = val
        valueHolder = QuantityValueHolder(indexer: value)
    }
}
