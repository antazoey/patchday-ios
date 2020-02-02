//
// Created by Juliya Smith on 12/31/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation


public class SiteComparator {

    public static func lessThan(lhs: Bodily, rhs: Bodily) -> Bool {
        // keep negative orders at the end
        if lhs.order < 0 {
            return false
        }
        
        if rhs.order < 0 {
            return true
        }
        return lhs.order < rhs.order
    }
}
