//
//  ColonStrings.swift
//  PDKit
//
//  Created by Juliya Smith on 10/8/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation


public class ColonStrings {

    private static let c1 = "Displayed on a label, plenty of room."
    private static let c2 = "Label next to date. Easy on room."
    
    public static func createHormoneViewStrings(deliveryMethod: DeliveryMethod, hormone: Hormonal) -> HormoneViewStrings {
        switch deliveryMethod {
        case .Patches : return createPatchViewStrings(hormone)
        case .Injections: return createInjectionViewStrings(hormone)
        }
    }
    
    private static func createPatchViewStrings(_ patch: Hormonal) -> HormoneViewStrings {
        HormoneViewStrings(
            expirationText: patch.isExpired ? Expired : Expires,
            dateAndTimePlacedText: DateAndTimeApplied,
            siteLabelText: Site
        )
    }
    
    private static func createInjectionViewStrings(_ injection: Hormonal) -> HormoneViewStrings {
        HormoneViewStrings(
            expirationText: NextDue,
            dateAndTimePlacedText: DateAndTimeInjected,
            siteLabelText: LastSiteInjected
        )
    }

    private static var Count: String {
        NSLocalizedString("Count:", comment: c1)
    }

    private static var Time: String {
        NSLocalizedString("Time:", comment: c1)
    }

    private static var Expires: String {
        NSLocalizedString("Expires: ", comment: c2)
    }

    private static var Expired: String {
        NSLocalizedString("Expired: ", comment: c2)
    }

    private static var NextDue: String {
        NSLocalizedString("Next due: ", comment: c2)
    }

    private static var DateAndTimeApplied: String {
        NSLocalizedString("Date and time applied: ", comment: c2)
    }

    private static var DateAndTimeInjected: String {
        NSLocalizedString("Date and time injected: ", comment: c2)
    }

    private static var Site: String {
        NSLocalizedString("Site: ", comment: c2)
    }

    private static var LastSiteInjected: String {
        NSLocalizedString("Site injected: ", comment: c2)
    }
}
