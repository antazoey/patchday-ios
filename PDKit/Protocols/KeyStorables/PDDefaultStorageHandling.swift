//
//  PDDefaultStorageHandling.swift
//  PDKit
//
//  Created by Juliya Smith on 11/1/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol PDDefaultStorageHandling {

    @discardableResult func replace<T>(_ v: inout T, to new: T.Value) -> PDDefaultStorageHandling where T: PDKeyStorable
    
    func find<T>(_ v: inout T) -> Bool where T: PDKeyStorable
    
    @discardableResult func load<T>(_ v: inout T) -> PDDefaultStorageHandling where T: PDKeyStorable
}
