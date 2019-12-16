//
//  PillAttributes.swift
//  PDKit
//
//  Created by Juliya Smith on 12/21/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation

public struct PillAttributes {

    private let defaultName = PDStrings.PlaceholderStrings.newPill
    
    public var description: String { "Pill DTO" }
    
    public var name: String?
    public var timesaday: Int?
    public var time1: Time?
    public var time2: Time?
    public var notify: Bool?
    public var timesTakenToday: Int?
    public var lastTaken: Date?
    public init(
        name: String?,
        timesaday: Int?,
        time1: Time?,
        time2: Time?,
        notify: Bool?,
        timesTakenToday: Int?,
        lastTaken: Date?
    ) {
        self.name = name
        self.timesaday = timesaday
        self.time1 = time1
        self.time2 = time2
        self.notify = notify
        self.timesTakenToday = timesTakenToday
        self.lastTaken = lastTaken
    }

    public init() {
        self.notify = true
    }
}
