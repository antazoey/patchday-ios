//
//  PillTimesQuotient.swift
//  PDKit
//
//  Created by Juliya Smith on 4/25/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public class PillTimesQuotient {
    private var _timesTakenToday: Int
    private var _timesaday: Int

    private var timesTakenToday: Int {
        if _timesTakenToday < 0 {
            _timesTakenToday = 0
        }
        if _timesTakenToday > timesaday {
            _timesTakenToday = timesaday
        }
        return _timesTakenToday
    }

    private var timesaday: Int {
        if _timesaday < 0 {
            _timesaday = 1
        }
        return _timesaday
    }

    public init(timesTakenToday: Int, timesaday: Int) {
        self._timesTakenToday = timesTakenToday
        self._timesaday = timesaday
    }

    public func toString() -> String {
        let minDefaultString = "0 / \(timesaday))"
        let maxDefaultString = "\(timesaday)) / \(timesaday))"
        guard timesTakenToday >= 0 else { return minDefaultString }
        guard timesaday >= 0 else { return minDefaultString }
        guard timesaday >= timesTakenToday else { return maxDefaultString }
        return "\(timesTakenToday) / \(timesaday)"
    }
}
