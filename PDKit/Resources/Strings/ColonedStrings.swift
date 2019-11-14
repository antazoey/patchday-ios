//
//  ColonedStrings.swift
//  PDKit
//
//  Created by Juliya Smith on 10/8/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation


public class ColonedStrings {

    private static let c1 = "Displayed on a label, plenty of room."
    private static let c2 = "Label next to date. Easy on room."

    public static let count = {
        NSLocalizedString("Count:", comment: c1)
    }()

    public static let time = {
        NSLocalizedString("Time:", comment: c1)
    }()

    public static let firstTime = {
        NSLocalizedString("First time:", comment: c1)
    }()

    public static let expires = {
        NSLocalizedString("Expires: ", comment: c2)
    }()

    public static let expired = {
        NSLocalizedString("Expired: ", comment: c2)
    }()

    public static let lastInjected = {
        NSLocalizedString("Injected: ", comment: c2)
    }()

    public static let nextDue = {
        NSLocalizedString("Next due: ", comment: c2)
    }()

    public static let dateAndTimeApplied = {
        NSLocalizedString("Date and time applied: ", comment: c2)
    }()

    public static let dateAndTimeInjected = {
        NSLocalizedString("Date and time injected: ", comment: c2)
    }()

    public static let site = {
        NSLocalizedString("Site: ", comment: c2)
    }()

    public static let lastSiteInjected = {
        NSLocalizedString("Site injected: ", comment: c2)
    }()
    
    public static func getDateTitle(for mone: Hormonal, method: DeliveryMethod) -> String {
        var title = ""
        switch method {
        case .Patches:
            if let exp = mone.expiration {
                let intro = mone.isExpired ? self.expired : self.expires
                title += intro + DateHelper.dayOfWeekString(date: exp)
            }
        case .Injections:
            let day = DateHelper.dayOfWeekString(date: mone.date)
            title += self.lastInjected + day
        }
        return title
    }
    
    public static func getHormoneViewStrings(
        deliveryMethod: DeliveryMethod,
        hormone: Hormonal
    ) -> (expirationText: String, dateAndTimePlacedText: String, siteLabeText: String) {
        switch deliveryMethod {
        case .Patches :
            let expText = hormone.isExpired ? expired : expires
            return (
                expirationText: expText,
                dateAndTimePlacedText: dateAndTimeApplied,
                siteLabeText: site
            )
        case .Injections:
            return (
                expirationText: nextDue,
                dateAndTimePlacedText: dateAndTimeInjected,
                siteLabeText: lastSiteInjected
            )
        }
    }
}
