//
//  PillDataSharing.swift
//  PDKit
//
//  Created by Juliya Smith on 1/18/20.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public protocol PillDataSharing {
    func share(nextPill: Swallowable)
}
