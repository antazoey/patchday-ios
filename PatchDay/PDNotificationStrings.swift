//
//  PDNotificationStrings.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/27/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

internal class PDNotificationStrings {
    
    static let siteToExpiredPatchMessage: [String : String] =
        ["Right Abdomen" : NSLocalizedString("Change patch on your 'Right Abdomen' ", comment: comment),
         "Left Abdomen" : NSLocalizedString("Change patch on your 'Right Abdomen' ", comment: comment),
         "Right Glute" : NSLocalizedString("Change patch on your 'Right Glute' ", comment: comment),
         "Left Glute" : NSLocalizedString("Change patch on your 'Left Glute' ", comment: comment)]
    
    static func getEstrogenNotificationStrings(method: DeliveryMethod,
                                               minutesBefore: Double,
                                               expiringSiteName: String,
                                               suggestedSiteName: String? = nil) -> (String, String) {
        var titleBuilder: String
        var titleOptions: [String]
        var bodyBuilder: String
        var siteBody: String
        switch method {
        case .Patches:
            titleOptions = [patchExpired, patchExpires]
            bodyBuilder = patchBody
            siteBody = siteForNextPatch
        case .Injections:
            titleOptions = [injectionExpired, injectionExpires]
            bodyBuilder = injectionBody
            siteBody = siteForNextInjection
        }
        titleBuilder = (minutesBefore == 0) ? titleOptions[0] : titleOptions[1]
        bodyBuilder += siteBody + expiringSiteName
        if let n = suggestedSiteName {
            bodyBuilder += siteBody + n
        }
        return (titleBuilder, bodyBuilder)
    }

    // MARK: - User facing
    
    static let patchBody = {
        return NSLocalizedString("Expired patch site: ", comment: comment)
    }()
    
    static let injectionBody = {
        return NSLocalizedString("Your last injection site: ", comment: comment)
    }()
    
    static let siteForNextPatch = {
        return NSLocalizedString("Site for next patch: ", comment: comment)
    }()
    
    static let siteForNextInjection = {
        return NSLocalizedString("Site for next injection: ", comment: comment)
    }()
    
    static let autofill = {
        return NSLocalizedString("Change to suggested site?", comment: "Notification action label.")
    }()
    
    static let patchExpired = {
        return NSLocalizedString("Time for your next patch", comment: comment)
    }()
    
    static let patchExpires = {
        return NSLocalizedString("Almost time for your next patch", comment: comment)
    }()
    
    static let injectionExpired = {
        return NSLocalizedString("Time for your next injection", comment: comment)
    }()
    
    static let injectionExpires = {
        return NSLocalizedString("Almost time for your next injection", comment: comment)
    }()
    
    static let takePill = {
        return NSLocalizedString("Time to take pill: ", comment: comment)
    }()
    
    static let overnightPatch = {
        return NSLocalizedString("Patch expires overnight.", comment: comment)
    }()
    
    static let overnightInjection = {
        return NSLocalizedString("Injection due overnight", comment: comment)
    }()
    
    // MARK: - Comments
    
    private static let comment = { return "Notification telling you where and " +
        "when to change your patch." }()
    
    private static let titleComment = { return "Title of notification." }()
}
