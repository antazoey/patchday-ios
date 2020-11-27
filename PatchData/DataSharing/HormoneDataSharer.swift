//
//  HormoneDataSharer.swift
//  PatchData
//
//  Created by Juliya Smith on 11/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class HormoneDataSharer: HormoneDataSharing {

    private let base: UserDefaultsProtocol

    init(baseSharer: UserDefaultsProtocol) {
        self.base = baseSharer
    }

    public func share(nextHormone: Hormonal) {
        let expiration = nextHormone.expiration
        let method = nextHormone.deliveryMethod
        base.set(expiration, for: SharedDataKey.NextHormoneDate.rawValue)
        base.set(expiration, for: SharedDataKey.)
        base.set(nextHormone.expiration, for: SharedDataKey.NextHormoneDate.rawValue)
    }
}
