//
//  Storing.swift
//  PDKit
//
//  Created by Juliya Smith on 11/1/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol Storing {

    @discardableResult func replace<T>(_ v: inout T, to new: T.Value) -> Storing where T: KeyStorable
    
    func find<T>(_ v: inout T) -> Bool where T: KeyStorable
    
    @discardableResult func load<T>(_ v: inout T) -> Storing where T: KeyStorable
}
