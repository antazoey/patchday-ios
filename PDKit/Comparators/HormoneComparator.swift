//
// Created by Juliya Smith on 12/31/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation


public class HormoneComparator {
    
    public static func lessThan(lhs: Hormonal, rhs: Hormonal) -> Bool {
        lhs.date < rhs.date && !lhs.date.isDefault() || rhs.date.isDefault()
    }

    public static func equalTo(lhs: Hormonal, rhs: Hormonal) -> Bool {
        lhs.id == rhs.id
    }
}
