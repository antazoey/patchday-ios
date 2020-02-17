//
//  PDDefaultProtocol.swift
//  PatchData
//
//  Created by Juliya Smith on 4/21/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


public class UserDefaultsWriteHandler: NSObject, UserDefaultsWriteHandling {

    override open var description: String { "Handles pushing and pulling from UserDefaults." }
    
    private let stdDefaults = UserDefaults.standard
    private var dataSharer: DataSharing

    public init(dataSharer: DataSharing) {
        self.dataSharer = dataSharer
    }

     @discardableResult
     public func replace<T>(_ v: inout T, to new: T.Value) -> UserDefaultsWriteHandling where T : KeyStorable {
        v.value = new
        dataSharer.share(v.rawValue, forKey: T.key.rawValue)
        stdDefaults.set(v.rawValue, forKey: T.key.rawValue)
        return self
    }
    
    @discardableResult
    public func load<T>(_ v: inout T) -> UserDefaultsWriteHandling where T : KeyStorable {
        let found = find(&v)
        if !found {
            self.replace(&v, to: v.value)
        }
        return self
    }

    // MARK: - Private

    private func find<T>(_ v: inout T) -> Bool where T: KeyStorable {
        let def1 = dataSharer.object(forKey: T.key.rawValue) as? T.RawValue
        let def2 = stdDefaults.object(forKey: T.key.rawValue) as? T.RawValue
        let fv = def1 ?? def2 ?? v.rawValue
        v = T(fv)
        return def1 != nil || def2 != nil
    }
}
