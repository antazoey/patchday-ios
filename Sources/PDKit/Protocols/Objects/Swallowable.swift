//
//  Swallowable.swift
//  PDKit
//
//  Created by Juliya Smith on 8/14/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol Swallowable {

    var id: UUID { get set }

    /// The pill attributes DTO formed from this pill's attributes.
    var attributes: PillAttributes { get }

    /// The name of the pill.
    var name: String { get }

    /// The expiration interval of the pill as an object with additional helper methods.
    var expirationInterval: PillExpirationInterval { get }

    /// The expiration interval of the pill, such as every day or first ten days of the month, etc.
    var expirationIntervalSetting: PillExpirationIntervalSetting { get }

    /// The times, in order, for which to take pills on a day in the schedule.
    var times: [Time] { get }

    /// Adds a new pill time.
    func appendTime(_ time: Time)

    /// Whether you want to be notified when due.
    var notify: Bool { get set }

    /// The number of times you should take this pill a day.
    var timesaday: Int { get }

    /// The number of times you took this pill today.
    var timesTakenToday: Int { get }

    /// The date when you last took this pill.
    var lastTaken: Date? { get set }

    /// The days value used for certain expiration intervals, such as XDaysOnXDaysOff.
    var xDays: String? { get }

    /// The date when you should take this pill next.
    var due: Date? { get }

    /// Whether it is past the due date.
    var isDue: Bool { get }

    /// Whether you never took this pill before.
    var isNew: Bool { get }

    /// Whether the pill was ever given a name.
    var hasName: Bool { get }

    /// If you are done taking this pill today.
    var isDone: Bool { get }

    /// Sets this pill's attributes using the given DTO.
    func set(attributes: PillAttributes)

    /// Simulates taking the pill.
    func swallow()

    /// Configures properties that depend on a day-to-day basis, such as timesTakenToday.
    func awaken()
}
