//
//  DataSharer.swift
//  PatchData
//
//  Created by Juliya Smith on 1/18/20.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class DataSharer: UserDefaultsProtocol {

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: PDSharedDataGroupName)
    }

    public func set(_ value: Any?, for key: String) {
        sharedDefaults?.set(value, forKey: key)
    }

    public func object(for key: String) -> Any? {
        sharedDefaults?.object(forKey: key)
    }
}
