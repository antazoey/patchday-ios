//
//  PDTypes.swift
//  PDKit
//
//  Created by Juliya Smith on 5/5/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public enum DeliveryMethod: String {
    case Patches
    case Injections
}

public enum Quantity: Int {
    case One
    case Two
    case Three
    case Four
}

public enum ExpirationInterval: String {
    case TwiceAWeek
    case OnceAWeek
    case EveryTwoWeeks
}
