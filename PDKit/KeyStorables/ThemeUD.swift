//
//  ThemeUD.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public class PDThemeValueHolder: ComplexValueHolding {
    
    static let lkey = { "Light" }()
    static let dkey = { "Dark" }()
    
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

public class PDThemeUD: KeyStorable {
    
    private var v: PDTheme
    private var valueHolder: PDThemeValueHolder
    
    public typealias Value = PDTheme
    public typealias RawValue = String
    
    public required init(with val: String) {
        valueHolder = PDThemeValueHolder(raw: val)
        v = valueHolder.indexer
    }
    
    public required init(with val: PDTheme) {
        v = val
        valueHolder = PDThemeValueHolder(indexer: v)
    }
    
    public convenience required init() {
        self.init(with: .Light)
    }
    
    public var value: PDTheme {
        get { v }
        set {
            v = newValue
            valueHolder = PDThemeValueHolder(indexer: newValue)
        }
    }
    
    public var rawValue: String { valueHolder.heldValue }
    
    public static var key = PDDefault.Theme
}
