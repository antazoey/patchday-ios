//
//  DeliveryMethodUD.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public enum DeliveryMethod: String {
    case Patches = "Patches"
    case Injections = "Injections"
}

public class DeliveryMethodUD: PDKeyStorable {
    
    public typealias Value = DeliveryMethod
    
    public typealias RawValue = String
    
    public var value: DeliveryMethod
    
    public var rawValue: String {
        get {
            return value.rawValue
        }
    }
    
    public static var key = PDDefault.DeliveryMethod
    
    public required init(with val: String) {
        if let i = DeliveryMethod(rawValue: val) {
            value = i
        } else {
            value = DeliveryMethod.Patches
        }
    }
    
    public required init(with val: DeliveryMethod) {
        value = val
    }
}
