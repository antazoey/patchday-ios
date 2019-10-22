//
//  ThemeUD.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public class PDThemeValueHolder: PDValueHolding {
    
    static let lkey = { return "Light" }()
    static let dkey = { return "Dark" }()
    
    var indexer: PDTheme
    
    required public init(indexer: PDTheme) {
        self.indexer = indexer
    }
    
    public convenience init(raw: String) {
        switch raw {
        case PDThemeValueHolder.dkey:
            self.init(indexer: .Dark)
        default:
            self.init(indexer: .Light)
        }
    }
    
    public var heldValue: String {
        switch indexer {
        case .Light: return PDThemeValueHolder.lkey
        case .Dark: return PDThemeValueHolder.dkey
        }
    }
}

public class PDThemeUD: PDKeyStorable {
    
    private var v: PDTheme
    private var valueHolder: PDThemeValueHolder
    
    public typealias Value = PDTheme
    public typealias RawValue = String
    
    public var value: PDTheme {
        get { return v }
        set {
            v = newValue
            valueHolder = PDThemeValueHolder(indexer: newValue)
        }
    }
    
    public var rawValue: String { return valueHolder.heldValue }
    
    public static var key = PDDefault.Theme
    
    public required init(with val: String) {
        valueHolder = PDThemeValueHolder(raw: val)
        v = valueHolder.indexer
    }
    
    public required init(with val: PDTheme) {
        v = val
        valueHolder = PDThemeValueHolder(indexer: v)
    }
}
