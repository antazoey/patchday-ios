//
//  Storing.swift
//  PDKit
//
//  Created by Juliya Smith on 11/1/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation


public protocol UserDefaultsWriteHandling {

    @discardableResult func replace<T>(_ v: inout T, to new: T.Value) -> UserDefaultsWriteHandling where T: KeyStorable

    @discardableResult func load<T>(_ v: inout T) -> UserDefaultsWriteHandling where T: KeyStorable
}
