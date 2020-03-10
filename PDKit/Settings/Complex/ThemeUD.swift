//
//  ThemeUD.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation


public class ThemeUD: ComplexSetting<PDTheme, String>, KeyStorable {

    public static let LightThemeKey = { "Light" }()
    public static let DarkThemeKey = { "Dark" }()
    
    public typealias Value = PDTheme
    public typealias RawValue = String
    public let setting: PDSetting = .Theme
    
    public convenience init(_ value: PDTheme) {
        let rv = ThemeUD.getRawValue(for: value)
        self.init(rv)
    }
    
    public required init(_ rawValue: String) {
        super.init(rawValue)
        self.choices = PickerOptions.themes
    }
    
    public override var value: PDTheme {
        switch rawValue {
        case ThemeUD.DarkThemeKey: return .Dark
        default: return .Light
        }
    }
    
    public static func getRawValue(for value: PDTheme) -> String {
        switch value {
        case .Light: return LightThemeKey
        case.Dark: return DarkThemeKey
        }
    }
}
