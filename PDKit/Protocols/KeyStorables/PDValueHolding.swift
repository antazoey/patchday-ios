//
//  PdKeyHolding.swift
//  PatchData
//
//  Created by Juliya Smith on 5/6/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol PDValueHolding {
    associatedtype KeyIndex
    associatedtype RawValue
    init(indexer: KeyIndex)
    var heldValue: RawValue { get }
}
