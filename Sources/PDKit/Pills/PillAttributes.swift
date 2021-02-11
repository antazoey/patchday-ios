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

    public var anyAttributeExists: Bool {
        name != nil ||
        expirationInterval != nil ||
        times != nil ||
        notify != nil ||
        timesTakenToday != nil ||
        lastTaken != nil
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
