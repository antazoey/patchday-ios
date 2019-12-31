//
// Created by Juliya Smith on 12/31/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation


public class HormoneComparator {

    // nil > all.

    public static func lessThan(lhs: Hormonal, rhs: Hormonal) -> Bool {
        switch(lhs.date, rhs.date) {
        case (nil, nil) : return false
        case (nil, _) : return false
        case (_, nil) : return true
        default : return lhs.date < rhs.date
        }
    }

    public static func greaterThan(lhs: Hormonal, rhs: Hormonal) -> Bool {
        switch(lhs.date, rhs.date) {
        case (nil, nil) : return false
        case (nil, _) : return true
        case (_, nil) : return false
        default : return lhs.date > rhs.date
        }
    }

    public static func equalTo(lhs: Hormonal, rhs: Hormonal) -> Bool {
        lhs.id == rhs.id
    }
}
