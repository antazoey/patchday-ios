//
//  ThemeUD.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public enum PDTheme: String {
    case Light = "Light"
    case Dark = "Dark"
}

public class ThemeUD: PDKeyStorable {
    
    public typealias Value = PDTheme
    
    public typealias RawValue = String
    
    public var value: PDTheme
    
    public var rawValue: String {
        get { return value.rawValue }
    }
    
    public static var key = PDDefault.Theme
    
    public required init(with val: String) {
        if let theme = PDTheme(rawValue: val) {
            value = theme
        } else {
            value = .Light
        }
    }
    
    public required init(with val: PDTheme) { value = val }
}
