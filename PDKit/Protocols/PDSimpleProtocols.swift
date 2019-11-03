//
//  PDSimpleProtocols.swift
//  PDKit
//
//  Created by Juliya Smith on 10/28/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol PDCountable {
    var count: Int { get }
}

public protocol PDSorting {
    func sort()
}

public protocol PDSaving {
    func save()
}

public protocol PDDeleting {
    func delete(at index: Index)
}

public protocol PDResetting {
 
/// Reset all properties to their default values and returns the new count.
@discardableResult func reset(deliveryMethod: DeliveryMethod, interval: ExpirationIntervalUD) -> Int
}
