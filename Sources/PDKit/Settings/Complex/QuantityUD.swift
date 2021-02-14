//
//  QuantityUD.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.
//  
//

import Foundation

public class QuantityUD: ComplexSetting<Quantity, Int>, KeyStorable {

    public typealias Value = Quantity
    public typealias RawValue = Int
    public let setting: PDSetting = .Quantity

    public convenience init() {
        self.init(DefaultSettings.QuantityValue)
    }

    public convenience init(_ value: Quantity) {
        self.init(value.rawValue)
    }

    public required init(_ rawValue: Int) {
        super.init(rawValue)
        self.choices = SettingsOptions.quantities
    }

    public override var value: Quantity {
        return Quantity(rawValue: rawValue) ?? DefaultSettings.QuantityValue
    }
}
