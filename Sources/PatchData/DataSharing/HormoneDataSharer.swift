//
//  HormoneDataSharer.swift
//  PatchData
//
//  Created by Juliya Smith on 11/10/19.

import Foundation
import PDKit

public class HormoneDataSharer: HormoneDataSharing {

    private let base: UserDefaultsProtocol

    init(baseSharer: UserDefaultsProtocol) {
        self.base = baseSharer
    }

    public func share(nextHormone: Hormonal) {
        base.set(nextHormone.expiration, for: SharedDataKey.NextHormoneDate.rawValue)
    }
}
