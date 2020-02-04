//
//  ColonedStrings.swift
//  PDKit
//
//  Created by Juliya Smith on 10/8/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation


public class ColonStrings {

    private static let c1 = "Displayed on a label, plenty of room."
    private static let c2 = "Label next to date. Easy on room."

    public static let Count = {
        NSLocalizedString("Count:", comment: c1)
    }()

    public static let Time = {
        NSLocalizedString("Time:", comment: c1)
    }()

    public static let expires = {
        NSLocalizedString("Expires: ", comment: c2)
    }()

    public static let Expired = {
        NSLocalizedString("Expired: ", comment: c2)
    }()

    public static let LastInjected = {
        NSLocalizedString("Injected: ", comment: c2)
    }()

    public static let NextDue = {
        NSLocalizedString("Next due: ", comment: c2)
    }()

    public static let DateAndTimeApplied = {
        NSLocalizedString("Date and time applied: ", comment: c2)
    }()

    public static let DateAndTimeInjected = {
        NSLocalizedString("Date and time injected: ", comment: c2)
    }()

    public static let Site = {
        NSLocalizedString("Site: ", comment: c2)
    }()

    public static let LastSiteInjected = {
        NSLocalizedString("Site injected: ", comment: c2)
    }()
    
    public static func getDateTitle(for hormone: Hormonal, method: DeliveryMethod) -> String {
        var title = ""
        switch method {
        case .Patches:
            if let exp = hormone.expiration {
                let intro = hormone.isExpired ? self.Expired : self.expires
                title += intro + PDDateFormatter.formatDate(exp)
            }
        case .Injections:
            let day = PDDateFormatter.formatDate(hormone.date)
            title += self.LastInjected + day
        }
        return title
    }
    
    public static func createHormoneViewStrings(deliveryMethod: DeliveryMethod, hormone: Hormonal) -> HormoneViewStrings {
        switch deliveryMethod {
        case .Patches :
            let expText = hormone.isExpired ? Expired : expires
            return HormoneViewStrings(
                expirationText: expText,
                dateAndTimePlacedText: DateAndTimeApplied,
                siteLabelText: Site
            )
        case .Injections:
            return HormoneViewStrings(
                expirationText: NextDue,
                dateAndTimePlacedText: DateAndTimeInjected,
                siteLabelText: LastSiteInjected
            )
        }
    }
}
