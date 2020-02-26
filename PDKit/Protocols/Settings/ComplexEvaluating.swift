//
//  PdKeyHolding.swift
//  PatchData
//
//  Created by Juliya Smith on 5/6/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol ComplexValueHolding {
    associatedtype RawValue
    init(complexValueType: PDSetting)
    var heldValue: RawValue { get }
}
