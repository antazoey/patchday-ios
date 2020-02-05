//
//  PillsHelper.swift
//  PDKit
//
//  Created by Juliya Smith on 6/20/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

public typealias Stamp = Date
public typealias Stamps = [Stamp?]?


public class PillHelper: NSObject {

    public enum NextDueDateError: Error {
        case notEnoughTimes
    }

    /// Return if the pill has been taken all of its times today.
    public static func isDone(timesTakenToday: Int, timesaday: Int) -> Bool {
        timesTakenToday >= timesaday
    }
}
