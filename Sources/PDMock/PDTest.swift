//
//  File.swift
//  PDMock
//
//  Created by Juliya Smith on 5/16/20.

import Foundation
import PDKit

public class PDTest {

    public static func equiv(_ d1: Date, _ d2: Date) -> Bool {
        Calendar.current.isDate(d1, equalTo: d2, toGranularity: .nanosecond)
    }

    public static func equiv(_ d1: Double, _ d2: Double, _ granularity: Double = 0.01) -> Bool {
        abs(d1 - d2) < granularity
    }

    public static func sameTime(_ t1: Date, _ t2: Date) -> Bool {
        let c1 = Calendar.current.dateComponents([.hour, .minute, .second], from: t1)
        let c2 = Calendar.current.dateComponents([.hour, .minute, .second], from: t2)
        let h1 = c1.hour
        let h2 = c2.hour
        let m1 = c1.minute
        let m2 = c2.minute
        let s1 = c1.second
        let s2 = c2.second
        return h1 == h2 && m1 == m2 && s1 == s2
    }
}
