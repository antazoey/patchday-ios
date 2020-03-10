//
// Created by Juliya Smith on 12/19/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation


public struct PillDueDateFinderParams {
    public var timesTakenToday: Int
    public var timesaday: Int
    public var times: [Time]

    public init(_ timesTakenToday: Int, _ timesaday: Int, _ times: [Time]) {
        self.timesTakenToday = timesTakenToday
        self.timesaday = timesaday
        self.times = times
    }
}
