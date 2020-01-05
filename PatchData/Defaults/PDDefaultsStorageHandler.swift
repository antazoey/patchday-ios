//
//  PDDefaultProtocol.swift
//  PatchData
//
//  Created by Juliya Smith on 4/21/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class PDDefaultsStorageHandler: NSObject, Storing {

    override open var description: String {
        """
        Handles pushing and pulling from UserDefaults.
        """
    }
    
    private let stdDefaults = UserDefaults.standard
    private var meter: DataShareDelegate? = nil

    public init(meter: DataShareDelegate) {
        self.meter = meter
    }

     @discardableResult public func replace<T>(_ v: inout T, to new: T.Value) -> Storing where T : KeyStorable {
        v.value = new
        meter?.defaults?.set(v.rawValue, forKey: T.key.rawValue)
        stdDefaults.set(v.rawValue, forKey: T.key.rawValue)
        return self
    }
    
    public func find<T>(_ v: inout T) -> Bool where T: KeyStorable {
        let def1 = meter?.defaults?.object(forKey: T.key.rawValue) as? T.RawValue
        let def2 = stdDefaults.object(forKey: T.key.rawValue) as? T.RawValue
        let fv = def1 ?? def2 ?? v.rawValue
        v = T(with: fv)
        return def1 != nil || def2 != nil
    }
    
    @discardableResult public func load<T>(_ v: inout T) -> Storing where T : KeyStorable {
        let found = find(&v)
        if !found {
            self.replace(&v, to: v.value)
        }
        return self
    }
}
