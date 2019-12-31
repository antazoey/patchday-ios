//
// Created by Juliya Smith on 12/31/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation


public class PillComparator {

    // nil is always at the end of a sort

    public static func lessThan(lhs: Swallowable, rhs: Swallowable) -> Bool {
        switch(lhs.due, rhs.due) {
        case (nil, nil) : return false
        case (nil, _) : return false
        case (_, nil) : return true
        default : return lhs.due < rhs.due
        }
    }

    public static func greatThan(lhs: Swallowable, rhs: Swallowable) -> Bool {
        switch(lhs.due, rhs.due) {
        case (nil, nil) : return false
        case (nil, _) : return true
        case (_, nil) : return false
        default : return lhs.due > rhs.due
        }
    }

    public static func equalTo(lhs: Swallowable, rhs: Swallowable) -> Bool {
        lhs.id == rhs.id
    }
}
