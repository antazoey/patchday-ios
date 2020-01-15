//
//  DeliveryMethodUD.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public class DeliveryMethodValueHolder: ComplexValueHolding {
    
    static let pkey = { "Patches" }()
    static let ikey = { "Injections" }()
    
    var indexer: DeliveryMethod
    
    required public init(indexer: DeliveryMethod) {
        self.indexer = indexer
    }
    
    public convenience init(raw: String) {
        switch raw {
        case DeliveryMethodValueHolder.ikey:
            self.init(indexer: .Injections)
        default:
            self.init(indexer: .Patches)
        }
    }
    
    public var heldValue: String {
        switch indexer {
        case .Patches: return DeliveryMethodValueHolder.pkey
        case .Injections: return DeliveryMethodValueHolder.ikey
        }
    }
}

public class DeliveryMethodUD: KeyStorable {
    
    private var v: DeliveryMethod
    private var valueHolder: DeliveryMethodValueHolder
    
    public typealias Value = DeliveryMethod
    public typealias RawValue = String
    
    public required init(_ val: String) {
        valueHolder = DeliveryMethodValueHolder(raw: val)
        v = valueHolder.indexer
    }
    
    public required init(_ val: DeliveryMethod) {
        v = val
        valueHolder = DeliveryMethodValueHolder(indexer: v)
    }
    
    public convenience required init() {
        self.init(.Patches)
    }
    
    public var value: DeliveryMethod {
        get { v }
        set {
            v = newValue
            valueHolder = DeliveryMethodValueHolder(indexer: newValue)
        }
    }
    
    public var rawValue: String { valueHolder.heldValue }
    
    public static var key = PDDefault.DeliveryMethod
}
