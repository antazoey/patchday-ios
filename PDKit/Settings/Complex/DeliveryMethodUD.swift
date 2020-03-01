//
//  DeliveryMethodUD.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation


public class DeliveryMethodUD: PDUserDefault<DeliveryMethod, String>, KeyStorable {

    public static let PatchesKey = { "Patches" }()
    public static let InjectionsKey = { "Injections" }()

    public typealias Value = DeliveryMethod
    public typealias RawValue = String
    public let setting: PDSetting = .DeliveryMethod
    
    public override var value: DeliveryMethod {
        switch rawValue {
        case DeliveryMethodUD.InjectionsKey: return .Injections
        default: return .Patches
        }
    }
}
