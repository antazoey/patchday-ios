//
//  PDTypes.swift
//  PDKit
//
//  Created by Juliya Smith on 5/5/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public enum DeliveryMethod {
    case Patches
    case Injections
}

public enum Quantity: Int {
    case One = 1
    case Two = 2
    case Three = 3
    case Four = 4
}

public enum ExpirationInterval {
    case TwiceAWeek
    case OnceAWeek
    case EveryTwoWeeks
}

public enum PDTheme {
    case Light
    case Dark
}
