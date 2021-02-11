//
//  PillAttributes.swift
//  PDKit
//
//  Created by Juliya Smith on 2/2/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//
import Foundation

public class PillAttributes {

    public var description: String { "Pill DTO" }

    // Pill Properties
    public var name: String?
    public var expirationInterval: PillExpirationInterval?
    public var times: String?
    public var notify: Bool?
    public var timesTakenToday: Int?
    public var lastTaken: Date?

    public init(
        name: String?,
        expirationInterval: PillExpirationInterval?,
        times: String?,
        notify: Bool?,
        timesTakenToday: Int?,
        lastTaken: Date?
    ) {
        self.name = name
        self.expirationInterval = expirationInterval
        self.times = times
        self.notify = notify
        self.timesTakenToday = timesTakenToday
        self.lastTaken = lastTaken
    }

    public init() {
    }

    /// Returns true if these attributes contain any non-nil attributes. Optionally pass in exceptions and it will also make sure
    /// the attribute is not equal to the property in the exceptions.
    public func anyAttributeExists(exclusions: PillAttributes? = nil) -> Bool {
        let exclusions = exclusions != nil ? exclusions! : PillAttributes()
        let nameExists = name != nil && name != exclusions.name
        let intervalExists = expirationInterval != nil
            && expirationInterval != exclusions.expirationInterval
        let timesExists = times != nil && times != exclusions.times
        let notifyExists = notify != nil && notify != exclusions.notify
        let timesTakenTodayExists = timesTakenToday != nil
            && timesTakenToday != exclusions.timesTakenToday
        let lastTakenExists = lastTaken != nil && lastTaken != exclusions.lastTaken

        return nameExists
            || intervalExists
            || timesExists
            || timesTakenTodayExists
            || notifyExists
            || timesTakenTodayExists
            || lastTakenExists
    }

    /// Set all properties to nil.
    public func reset() {
        name = nil
        expirationInterval = nil
        times = nil
        notify = nil
        timesTakenToday = nil
        lastTaken = nil
    }
}
