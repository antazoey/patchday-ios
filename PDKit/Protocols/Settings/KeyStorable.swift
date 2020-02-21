//
//  KeyStorable.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol KeyStorable {
    associatedtype Value
    associatedtype RawValue
    init(_ val: Value)
    init(_ val: RawValue)
    var value: Value { get set }
    var rawValue: RawValue { get }
    static var key: PDSetting { get }
}
