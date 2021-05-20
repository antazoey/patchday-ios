//
//  ColonStrings.swift
//  PDKit
//
//  Created by Juliya Smith on 10/8/19.

import Foundation
import PDKit

public class HormoneStrings {

    private static let c1 = "Displayed on a label, plenty of room."
    private static let c2 = "Label next to date. Easy on room."

    public static func create(_ hormone: Hormonal) -> HormoneViewStrings {
        switch hormone.deliveryMethod {
            case .Patches: return createPatchViewStrings(hormone)
            case .Injections: return createInjectionViewStrings(hormone)
            case .Gel: return createGelViewStrings(hormone)
        }
    }

    public static func getExpirationDateText(expiration: Date, now: PDNow?=nil) -> String {
        expiration.isWithin(minutes: Minutes.IN_WEEK, of: now?.now ?? Date())
            ? PDDateFormatter.formatDay(expiration)
            : PDDateFormatter.formatDate(expiration)
    }

    private static func createPatchViewStrings(_ patch: Hormonal) -> HormoneViewStrings {
        HormoneViewStrings(Exp, DateAndTimeApplied, _Site)
    }

    private static func createInjectionViewStrings(_ injection: Hormonal) -> HormoneViewStrings {
        HormoneViewStrings(Next, DateAndTimeInjected, LastSiteInjected)
    }

    private static func createGelViewStrings(_ gel: Hormonal) -> HormoneViewStrings {
        HormoneViewStrings(Next, DateAndTimeApplied, _Site)
    }

    private static var Exp: String {
        NSLocalizedString("Exp:", comment: c1)
    }

    private static var Count: String {
        NSLocalizedString("Count:", comment: c1)
    }

    private static var Time: String {
        NSLocalizedString("Time:", comment: c1)
    }

    private static var Next: String {
        NSLocalizedString("Next:", comment: c2)
    }

    private static var DateAndTimeApplied: String {
        NSLocalizedString("Date and time applied: ", comment: c2)
    }

    private static var DateAndTimeInjected: String {
        NSLocalizedString("Date and time injected: ", comment: c2)
    }

    private static var DateAndTimeTaken: String {
        NSLocalizedString("Date and time taken: ", comment: c2)
    }

    private static var _Site: String {
        NSLocalizedString("Site: ", comment: c2)
    }

    private static var LastSiteInjected: String {
        NSLocalizedString("Site injected: ", comment: c2)
    }
}
