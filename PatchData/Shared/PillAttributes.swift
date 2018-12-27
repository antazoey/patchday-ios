//
//  PillAttributes.swift
//  PDKit
//
//  Created by Juliya Smith on 12/21/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public struct PillAttributes {
    
    public var description: String {
        return "Class for setting MOPill attributes."
    }
    
    public var name: String?
    public var timesaday: Int?
    public var time1: Time?
    public var time2: Time?
    public var notify: Bool?
    public var timesTakenToday: Int?
    public var lastTaken: Date?
    public init(name: String?, timesaday: Int?,
                time1: Time?, time2: Time?,
                notify: Bool?, timesTakenToday: Int?,
                lastTaken: Date?, id: UUID?) {
        self.name = name
        self.timesaday = timesaday
        self.time1 = time1
        self.time2 = time2
        self.notify = notify
        self.timesTakenToday = timesTakenToday
        self.lastTaken = lastTaken
    }
    // Default
    public init() {
        self.name = PDStrings.PlaceholderStrings.new_pill
        self.timesaday = 1
        self.time1 = Time()
        self.time2 = Time()
        self.notify = true
        self.timesTakenToday = 0
        self.lastTaken = nil
    }
}
