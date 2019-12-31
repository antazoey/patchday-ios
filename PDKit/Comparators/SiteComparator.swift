//
// Created by Juliya Smith on 12/31/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation


public class SiteComparator {

    /* For Sites, we want negative orders and nil orders to always be at the end of a sort,
        regardless of if it was sorted by < or >. */

    public static func lessThan(lhs: Bodily, rhs: Bodily) -> Bool {
        switch(lhs.order, rhs.order) {

        // both not set
        case (nil, nil) : return false
        case (let neg1, let neg2) where neg1 < 0 && neg2 < 0 : return false
        case (nil, let neg) where neg < 0 : return false
        case (let neg, nil) where neg < 0 : return false

        // left field not set
        case (nil, _) : return false
        case (let neg, _) where neg < 0 : return false

        // right field not set
        case (_, nil) : return true
        case (_, let neg) where neg < 0 : return true

        // both fields sets
        default : return lhs.order < rhs.order
        }
    }

    public static func greaterThan(lhs: Bodily, rhs: Bodily) -> Bool {
        switch (lhs.order, rhs.order) {

        // both not set
        case (nil, nil): return false
        case (let neg1, let neg2) where neg1 < 0 && neg2 < 0: return false
        case (nil, let neg) where neg < 0: return false
        case (let neg, nil) where neg < 0: return false

        // left field not set
        case (nil, _): return true
        case (let neg, _) where neg < 0: return true

        // right field not set
        case (_, nil): return false
        case (_, let neg) where neg < 0: return false

        // both fields sets
        default: return lhs.order > rhs.order
        }
    }
}
