//
//  ThemeUD.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation


public class PDThemeValueHolder: ComplexValueHolding {
    
    private static let lightThemeKey = { "Light" }()
    private static let darkThemeKey = { "Dark" }()
    
    var indexer: PDTheme
    
    required public init(indexer: PDTheme) {
        self.indexer = indexer
    }
    
    public convenience init(raw: String) {
        switch raw {
        case PDThemeValueHolder.darkThemeKey: self.init(indexer: .Dark)
        default: self.init(indexer: .Light)
        }
    }
    
    public var heldValue: String {
        switch indexer {
        case .Light: return PDThemeValueHolder.lightThemeKey
        case .Dark: return PDThemeValueHolder.darkThemeKey
        }
    }
}

public class PDThemeUD: KeyStorable {
    
    private var v: PDTheme
    private var valueHolder: PDThemeValueHolder
    
    public typealias Value = PDTheme
    public typealias RawValue = String
    
    public required init(_ val: String) {
        valueHolder = PDThemeValueHolder(raw: val)
        v = valueHolder.indexer
    }
    
    public required init(_ val: PDTheme) {
        v = val
        valueHolder = PDThemeValueHolder(indexer: v)
    }
    
    public convenience required init() {
        self.init(DefaultSettings.DefaultTheme)
    }
    
    public var value: PDTheme {
        get { v }
        set {
            v = newValue
            valueHolder = PDThemeValueHolder(indexer: newValue)
        }
    }
    
    public var rawValue: String { valueHolder.heldValue }
    
    public static var key = PDSetting.Theme
}
