//
//  UserDefaultsWriteHandler.swift
//  PatchData
//
//  Created by Juliya Smith on 4/21/19.

import Foundation
import PDKit

public class UserDefaultsWriteHandler: NSObject, UserDefaultsWriteHandling {

    override open var description: String { "Handles pushing and pulling from UserDefaults." }

    private var base: UserDefaultsProtocol
    private var dataSharer: UserDefaultsProtocol

    public convenience init(dataSharer: UserDefaultsProtocol) {
        self.init(baseDefaults: PDUserDefaults(), dataSharer: dataSharer)
    }

    public init(baseDefaults: UserDefaultsProtocol, dataSharer: UserDefaultsProtocol) {
        self.base = baseDefaults
        self.dataSharer = dataSharer
    }

    public func replace<T>(_ v: T, to newValue: T.RawValue) where T: KeyStorable {
        dataSharer.set(newValue, for: v.setting.rawValue)
        base.set(newValue, for: v.setting.rawValue)
    }

    public func load<T>(_ setting: PDSetting) -> T? {
        let s1 = dataSharer.object(for: setting.rawValue) as? T
        let s2 = base.object(for: setting.rawValue) as? T
        return s1 ?? s2
    }
}
