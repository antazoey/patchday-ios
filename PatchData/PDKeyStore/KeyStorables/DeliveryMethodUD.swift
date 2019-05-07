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

    var indexer: DeliveryMethod
    
    required public init(indexer: DeliveryMethod) {
        self.indexer = indexer
    }
    
    public var heldValue: String {
        get {
            switch indexer {
            case .Patches: return "Patches"
            case .Injections: return "Injections"
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
        get { return v } set { }
    }
    
    public var rawValue: String {
        get { return valueHolder.heldValue }
    }
    
    public static var key = PDDefault.DeliveryMethod
    
    public required convenience init(with val: String) {
        var deliv: DeliveryMethod
        if let i = DeliveryMethod(rawValue: val) {
            deliv = i
        } else {
            deliv = DeliveryMethod.Patches
        }
        self.init(with: deliv)
    }
    
    public required init(with val: DeliveryMethod) {
        v = val
        valueHolder = DeliveryMethodValueHolder(indexer: v)
    }
}
