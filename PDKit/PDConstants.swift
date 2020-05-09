//
//  PDConstants.swift
//  PDKit
//
//  Created by Juliya Smith on 11/20/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public let OnlySupportedInjectionsQuantity = 1
public let SupportedHormoneUpperQuantityLimit = 4

public let HoursInADay = 24
public let HoursInHalfWeek = 84
public let HoursInWeek = HoursInHalfWeek * 2
public let HoursInTwoWeeks = HoursInWeek * 2

public class DefaultSettings {
	public static let ExpirationIntervalValue = ExpirationInterval.TwiceWeekly
	public static let ExpirationIntervalRawValue = ExpirationIntervalUD.TwiceWeeklyKey
	public static let ExpirationIntervalHours = 84
	public static let QuantityValue = Quantity.Three
	public static let QuantityRawValue = 3
	public static let DeliveryMethodValue = DeliveryMethod.Patches
	public static let DeliveryMethodRawValue = DeliveryMethodUD.PatchesKey
	public static let NotificationsRawValue = true
	public static let NotificationsMinutesBeforeRawValue = 0
	public static let MentionedDisclaimerRawValue = false
	public static let SiteIndexRawValue = 0
}

public class DefaultPillAttributes {

	public static let time = { Calendar.current.date(bySetting: .hour, value: 9, of: Date()) }()
	public static let timesaday = 1
	public static let timesTakenToday = 0
	public static let notify = true
    public static let expirationInterval = PillExpirationInterval.EveryDay
}

public class DefaultQuantities {

	public static func getForHormone(for deliveryMethod: DeliveryMethod) -> Int {
		switch deliveryMethod {
			case .Injections: return 1
			case .Patches: return 3
			case .Gel: return 1
		}
	}

	public static func getForSite(for deliveryMethod: DeliveryMethod) -> Int {
		switch deliveryMethod {
			case .Injections: return 1
			case .Patches: return 4
			case .Gel: return 2
		}
	}
}

public var DotDotDot: String {
	NSLocalizedString("...", comment: "Instruction for empty patch")
}
