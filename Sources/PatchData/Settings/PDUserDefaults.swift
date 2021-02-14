//
//  PDUserDefaults.swift
//  PatchData
//
//  Created by Juliya Smith on 5/9/20.
//  
//

import Foundation
import PDKit

public class PDUserDefaults: UserDefaultsProtocol {

    private let defaults = UserDefaults.standard

    public func set(_ newValue: Any?, for key: String) {
        defaults.set(newValue, forKey: key)
    }

    public func object(for key: String) -> Any? {
        defaults.object(forKey: key)
    }
}
