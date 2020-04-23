//
//  SettingStrings.swift
//  PDKit
//
//  Created by Juliya Smith on 3/7/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation


// Useful since the above does has legacy strings
public var NameToSettingMap: [String: PDSetting] {
	[
		"deliverymethod": .DeliveryMethod,
		"expirationinterval": .ExpirationInterval,
		"quantity": .Quantity,
		"notifications": .Notifications,
		"notificationsminutesbefore": .NotificationsMinutesBefore,
		"mentioneddisclaimer": .MentionedDisclaimer,
		"siteindex": .SiteIndex
	]
}


public var SettingToTitle: [PDSetting: String] {
	[
			.DeliveryMethod: NSLocalizedString("Delivery Method", comment: ""),
			.ExpirationInterval: NSLocalizedString("Expiration Intervak", comment: ""),
			.Quantity: NSLocalizedString("Quantity", comment: ""),
	]
}
