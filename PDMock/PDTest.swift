//
//  File.swift
//  PDMock
//
//  Created by Juliya Smith on 5/16/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation

public class PDTest {

    public static func equiv(_ d1: Date, _ d2: Date) -> Bool {
        Calendar.current.isDate(d1, equalTo: d2, toGranularity: .nanosecond)
    }

    public static func equiv(_ d1: Double, _ d2: Double, _ granularity: Double = 0.01) -> Bool {
        abs(d1 - d2) < granularity
    }
}
