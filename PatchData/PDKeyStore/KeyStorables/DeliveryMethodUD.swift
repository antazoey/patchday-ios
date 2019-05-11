//
//  DeliveryMethodUD.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class DeliveryMethodValueHolder: PDValueHolding {
    
    static let pkey = { return "Patches" }()
    static let ikey = { return "Injections" }()

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
        get {
            switch indexer {
            case .Patches: return DeliveryMethodValueHolder.pkey
            case .Injections: return DeliveryMethodValueHolder.ikey
            }
        }
    }
}

public class DeliveryMethodUD: PDKeyStorable {
    
    private var v: DeliveryMethod
    private var valueHolder: DeliveryMethodValueHolder
    
    public typealias Value = DeliveryMethod
    public typealias RawValue = String
    
    public var value: DeliveryMethod {
        get { return v }
        set {
            v = newValue
            valueHolder = DeliveryMethodValueHolder(indexer: newValue)
        }
    }
    
    public var rawValue: String {
        get { return valueHolder.heldValue }
    }
    
    public static var key = PDDefault.DeliveryMethod
    
    public required init(with val: String) {
        valueHolder = DeliveryMethodValueHolder(raw: val)
        v = valueHolder.indexer
    }
    
    public required init(with val: DeliveryMethod) {
        v = val
        valueHolder = DeliveryMethodValueHolder(indexer: v)
    }
}
