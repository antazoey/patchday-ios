//
//  Hormonal.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.

import Foundation

public protocol Hormonal: PDObjectified {

    /// Apply the given settings to the hormone instance and returns itself.
    func from(_ settings: UserDefaultsReading) -> Hormonal

    var id: UUID { get set }

    /// The way in which the hormone is delivered to the body, usually set from User Defaults.
    var deliveryMethod: DeliveryMethod { get set }

    /// The user default representing the length of time until the hormone expired.
    var expirationInterval: ExpirationIntervalUD { get set }

    /// The ID of the site this hormone applies to.
    var siteId: UUID? { get set }

    /// The name of the site this hormone applies to.
    var siteName: SiteName { get set }

    /// The Id referencing which site image is related to this hormone.
    var siteImageId: SiteName { get set }

    /// The date you applied this hormone to a site.
    var date: Date { get set }

    /// The date that this hormone runs out of juice.
    var expiration: Date? { get }

    /// Whether it is past this hormone's expiration date.
    var isExpired: Bool { get }

    /// Whether it is past the time to alert for this hormone's expiration date.
    var isPastNotificationTime: Bool { get }

    /// Whether the hormone expires between the hours of midnight and 6 am.
    var expiresOvernight: Bool { get }

    /// For preserving site data in case you delete the related Site.
    var siteNameBackUp: String? { get set }

    /// If this hormone without a site and date placed.
    var isEmpty: Bool { get }

    /// If this hormone has a site.
    var hasSite: Bool { get }

    /// If this hormone has a date.
    var hasDate: Bool { get }

    /// Set the date to now.
    func stamp()

    /// Create a would-be expiration date for the given start date using this hormone's expiration interval.
    func createExpirationDate(from startDate: Date) -> Date?
}
