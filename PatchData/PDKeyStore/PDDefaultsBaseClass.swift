//
//  PDDefaultProtocol.swift
//  PatchData
//
//  Created by Juliya Smith on 4/21/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

open class PDDefaultsBaseClass: NSObject {
    
    override open var description: String {
        return """
        The PDDefaults makes calls to User Defaults
        that are unique to the user and their schedule.
        The data stored here is simple enough that PatchDay
        stores it as key-value pairs.
        """
    }
    
    private let std_defaults = UserDefaults.standard
    private var shared: PDSharedData? = nil
    
    open func set<T>(_ v: inout T, to new: T.Value) where T: PDKeyStorable {
        v.value = new
        shared?.defaults?.set(v.rawValue, forKey: T.key.rawValue)
        std_defaults.set(v.rawValue, forKey: T.key.rawValue)
    }
    
    open func find<T>(_ v: inout T) -> Bool where T: PDKeyStorable {
        let def1 = shared?.defaults?.object(forKey: T.key.rawValue) as? T.RawValue
        let def2 = std_defaults.object(forKey: T.key.rawValue) as? T.RawValue
        let fv = def1 ?? def2 ?? v.rawValue
        v = T(with: fv)
        return def1 != nil || def2 != nil
    }
    
    open func load<T>(_ v: inout T) where T: PDKeyStorable {
        let found = find(&v)
        if !found {
            self.set(&v, to: v.value)
        }
    }
}
