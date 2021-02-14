//
//  KeyStorable.swift
//  PatchData
//
//  Created by Juliya Smith on 4/28/19.

import Foundation

public protocol KeyStorable {
    associatedtype Value
    associatedtype RawValue
    init(_ rawValue: RawValue)
    var value: Value { get }
    var rawValue: RawValue { get set }
    var setting: PDSetting { get }
    var displayableString: String { get }
}
