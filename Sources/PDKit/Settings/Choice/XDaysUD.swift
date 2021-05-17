//
//  XDaysUD.swift
//  PDKit
//
//  Created by Juliya Smith on 5/2/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public class XDaysUD: ComplexSetting<String, String>, KeyStorable {

    public var setting: PDSetting = .XDays

    public convenience init() {
        self.init(DefaultSettings.XDaysRawValue)
    }

    public convenience init(_ intValue: Int) {
        self.init("\(intValue)")
    }

    public required init(_ rawValue: String) {
        super.init(rawValue)
        self.choices = SettingsOptions.xDaysValues
    }

    public var days: Double {
        Double(rawValue) ?? DefaultSettings.XDaysRawValueDouble
    }

    public var hours: Int {
        let daysDouble = Double(Hours.InDay)
        return Int(daysDouble * days)  // Should always be a whole number.
    }
}
