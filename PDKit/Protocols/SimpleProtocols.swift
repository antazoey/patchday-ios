//
//  PDSimpleProtocols.swift
//  PDKit
//
//  Created by Juliya Smith on 10/28/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol Countable {
    var count: Int { get }
}

public protocol Sorting {
    func sort()
}

public protocol Saving {
    func save()
}

public protocol Deleting {
    func delete(at index: Index)
}

public protocol Resetting {
 
    /// Reset all properties to their default values and returns the new count.
    @discardableResult func reset() -> Int

}
