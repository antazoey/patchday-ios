//
//  ColonStrings.swift
//  PDKit
//
//  Created by Juliya Smith on 10/8/19.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

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

    private static func createPatchViewStrings(_ patch: Hormonal) -> HormoneViewStrings {
        HormoneViewStrings(getPatchExpiredText(patch), DateAndTimeApplied, _Site)
    }

    private static func getPatchExpiredText(_ patch: Hormonal) -> String {
        if patch.isPastNotificationTime && !patch.isExpired {
            return ExpiresSoon
        } else if patch.isExpired {
            return Expired
        } else {
            return Expires
        }
    }

    private static func createInjectionViewStrings(_ injection: Hormonal) -> HormoneViewStrings {
        HormoneViewStrings(NextDue, DateAndTimeInjected, LastSiteInjected)
    }

    private static func createGelViewStrings(_ gel: Hormonal) -> HormoneViewStrings {
        HormoneViewStrings(NextDue, DateAndTimeApplied, _Site)
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

    private static var ExpiresSoon: String {
        NSLocalizedString("Expires soon: ", comment: "There is room.")
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
