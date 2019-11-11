//
//  PDDefaultProtocol.swift
//  PatchData
//
//  Created by Juliya Smith on 4/21/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class PDDefaultsStorageHandler: NSObject, PDDefaultStorageHandling {

    override open var description: String {
        """
        Handles pushing and pulling from UserDefaults.
        """
    }
    
    private let stdDefaults = UserDefaults.standard
    private var meter: PDDataMeting? = nil

    public init(meter: PDDataMeting) {
        self.meter = meter
    }

     @discardableResult public func replace<T>(_ v: inout T, to new: T.Value) -> PDDefaultStorageHandling where T : PDKeyStorable {
        v.value = new
        meter?.defaults?.set(v.rawValue, forKey: T.key.rawValue)
        stdDefaults.set(v.rawValue, forKey: T.key.rawValue)
        return self
    }
    
    public func find<T>(_ v: inout T) -> Bool where T: PDKeyStorable {
        let def1 = meter?.defaults?.object(forKey: T.key.rawValue) as? T.RawValue
        let def2 = stdDefaults.object(forKey: T.key.rawValue) as? T.RawValue
        let fv = def1 ?? def2 ?? v.rawValue
        v = T(with: fv)
        return def1 != nil || def2 != nil
    }
    
    @discardableResult public func load<T>(_ v: inout T) -> PDDefaultStorageHandling where T : PDKeyStorable {
        let found = find(&v)
        if !found {
            self.replace(&v, to: v.value)
        }
        return self
    }
}
