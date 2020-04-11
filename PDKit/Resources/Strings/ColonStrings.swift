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

    public static var Count: String {
        NSLocalizedString("Count:", comment: c1)
    }

    public static var Time: String {
        NSLocalizedString("Time:", comment: c1)
    }

    public static var Expires: String {
        NSLocalizedString("Expires: ", comment: c2)
    }

    public static var Expired: String {
        NSLocalizedString("Expired: ", comment: c2)
    }

    public static var LastInjected: String {
        NSLocalizedString("Injected: ", comment: c2)
    }

    public static var NextDue: String {
        NSLocalizedString("Next due: ", comment: c2)
    }

    public static var DateAndTimeApplied: String {
        NSLocalizedString("Date and time applied: ", comment: c2)
    }

    public static var DateAndTimeInjected: String {
        NSLocalizedString("Date and time injected: ", comment: c2)
    }

    public static var Site: String {
        NSLocalizedString("Site: ", comment: c2)
    }

    public static var LastSiteInjected: String {
        NSLocalizedString("Site injected: ", comment: c2)
    }
    
    public static func getDateTitle(for hormone: Hormonal) -> String {
        switch hormone.deliveryMethod {
        case .Patches: return getPatchTitle(hormone)
        case .Injections: return getInjectionTitle(hormone)
        }
    }
    
    private static func getPatchTitle(_ patch: Hormonal) -> String {
        guard let exp = patch.expiration else { return "" }
        let intro = patch.isExpired ? self.Expired : self.Expires
        return intro + PDDateFormatter.formatDate(exp)
    }
    
    private static func getInjectionTitle(_ injection: Hormonal) -> String {
        let day = PDDateFormatter.formatDate(injection.date)
        return self.LastInjected + day
    }
    
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
}
