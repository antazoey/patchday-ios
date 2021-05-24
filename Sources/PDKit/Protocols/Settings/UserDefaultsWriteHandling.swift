//
//  Storing.swift
//  PDKit
//
//  Created by Juliya Smith on 11/1/19.

import Foundation

public protocol UserDefaultsWriteHandling {
    func replace<T>(_ v: T, to newValue: T.RawValue) where T: KeyStorable
    func load<T>(_ setting: PDSetting) -> T?
}
