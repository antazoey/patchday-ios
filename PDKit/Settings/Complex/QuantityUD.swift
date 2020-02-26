//
//  QuantityUD.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

//public class QuantityValueHolder: ComplexValueHolding {
//
//    public typealias KeyIndex = Quantity
//    public typealias RawValue = Int
//
//    var indexer: Quantity
//
//    required public init(indexer: Quantity) {
//        self.indexer = indexer
//    }
//
//    public var heldValue: Int {
//        switch indexer {
//        case .One: return 1
//        case .Two: return 2
//        case .Three: return 3
//        case .Four: return 4
//        }
//    }
//}

public class QuantityUD: PDUserDefault<Quantity, Int>, KeyStorable {
    
    private var v: Quantity
    private var valueHolder: QuantityValueHolder
    
    public typealias Value = Quantity
    public typealias RawValue = Int
    
    public required convenience init(_ rawValue: Int) {
        
    }
    
    public convenience required init() {
        self.init(DefaultSettings.DefaultQuantity)
    }
    
    public var value: Quantity {
        switch rawValue {
        case <#pattern#>:
            <#code#>
        default:
            <#code#>
        }
    }
    
    public var rawValue: Int
    
    public static var key = PDSetting.Quantity
}
