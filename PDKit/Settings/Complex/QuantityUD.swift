//
//  QuantityUD.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation


public class QuantityUD: PDUserDefault<Quantity, Int>, KeyStorable {

    public typealias Value = Quantity
    public typealias RawValue = Int
    public let setting: PDSetting = .Quantity

    public override var value: Quantity {
        return Quantity(rawValue: rawValue) ?? Quantity.Four
    }
}
