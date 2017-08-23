//
//  PDStrings.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/4/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import Foundation

// read-only

class PDStrings {
    
    // MARK: - Localizable
    
    internal static var hasNoDate: String = { return NSLocalizedString("Patch has no date!", comment: "for when there is no date associated with the patch") }()
    
    internal static var addPatch_string: String = { return NSLocalizedString("Add Patch", comment: "Label for view when adding a new patch") }()
    
    internal static var changePatch_string: String = { return NSLocalizedString("Change Patch", comment: "Label for view when changing a patch") }()
    
    internal static var expiredPatch_string: String = { return NSLocalizedString("Expired Patch", comment: "Label for view when changing a patch") }()
    
    internal static var emptyDateInstruction: String = { return NSLocalizedString("choose date", comment: "placeholder in date text field when it's a new patch") }()
    
    internal static var emptyLocationInstruction: String = { return NSLocalizedString("type or choose location", comment: "placeholder in location text field when it's a new patch") }()
    
    internal static var expirationIntervals: [String] = { return [NSLocalizedString("Half-Week", tableName: nil, comment: "SettingsViewController, it's an option for choosing which interval the patches expire. "), NSLocalizedString("Week", tableName: nil, comment: "SettingsViewController, it's an option for choosing which interval the patches expire. ")] }()
    
    internal static var patchLocationNames: [String] = { return [NSLocalizedString("Right Buttock", tableName: nil, comment: "location on body for where to place patch"), NSLocalizedString("Left Buttock", tableName: nil, comment: "location on body for where to place patch"), NSLocalizedString("Right Stomach", tableName: nil, comment: "location on body for where to place patch"), NSLocalizedString("Left Stomach", tableName: nil, comment: "location on body for where to place patch")] }()
    
    internal static var patchDetailsInstruction: String = {return NSLocalizedString("...", tableName: nil, comment: "instruction for empty patch") }()
    
    internal static var patchExpires_string: String = { return NSLocalizedString("Expires: ", tableName: nil, comment: "instruction for patch details") }()
    
    internal static var patchExpired_string: String = { return NSLocalizedString("Expired: ", tableName: nil, comment: "instruction for patch details") }()
    
    // notifications
    
    internal static var notificationIntros: [String : String] = { return ["Right Stomach" : NSLocalizedString("Change patch on your 'Right Stomach' ", comment: "notification telling you where and when to change your patch."),"Left Stomach" : NSLocalizedString("Change patch on your 'Left Stomach' ", comment: "notification telling you where and when to change your patch."),"Right Buttock" : NSLocalizedString("Change patch on your 'Right Buttock' ", comment: "notification telling you where and when to change your patch."),"Left Buttock" : NSLocalizedString("Change patch on your 'Left Buttock' ", comment: "notification telling you where and when to change your patch.")] }()
    
    internal static var notificationForCustom: String = { return NSLocalizedString("Change patch ", comment: "notification message for a custom located patch") }()
    internal static var notificationForCustom_at: String = { return NSLocalizedString("at: ", comment: " for displaying the date of the expired patch for a custom located notification, occruing directly after notificationForCustom message") }()
    
    internal static var notificationSuggestion: String = { return NSLocalizedString("Place new patch here: ", comment: "followed by a suggest location; second line in the notification if and only if the user enabled autoChooseLocation on the SettingsViewcontroller") }()
    
    internal static var notificationWithoutLocation: String = { return NSLocalizedString("Change a patch ", comment: "notification when there is no location pressent, this really should never happen") }()
    
    // MARK: - core data alert
    
    internal static var coreDataSaveAlertTitle: String = NSLocalizedString("Save Error", comment: "this is a title to an alert displayed if patch data is not saved for some reason.")
    
    internal static var coreDataSaveAlertMessage: String = NSLocalizedString("there was a problem saving your patch data!", comment: "this is a message to an alert displayed if patch data is not saved for some reason.")
    
    internal static var coreDataAlertTitle: String = NSLocalizedString("Core Data Error", comment: "this is a title to an alert displayed if if a generic patch managed object cannot not created in the persistent store")
    
    internal static var coreDataAlertMessage: String = NSLocalizedString("there is a problem with managed object in the persistent store", comment: "this is a message to an alert displayed if if a generic patch managed object cannot not created in the persistent store")
    internal static var dismiss_string: String = NSLocalizedString("Dismiss", comment: "The word displayed on a button for dismissing an error message")
    
    internal static var accept_string: String = NSLocalizedString("Accept", comment: "an accept button title displayed on the 'changing number of patches' alert")
    
    internal static var yes_string: String = NSLocalizedString("Yes", comment: "a yes button for an alert")
    
    internal static var no_string: String = NSLocalizedString("No", comment: "a no button for an alert")
    
    // MARK: - change patch alert
    
    internal static var changePatchCountAlertTitle: String = NSLocalizedString("Warning", comment: "title for alert for changing number of patches (could result in loss of data)")
    
    internal static var changePatchCountAlertMessage: String = NSLocalizedString("Decreasing the number of patches will result in a loss of data.", comment: "title for alert for changing number of patches (could result in loss of data)")
    
    internal static var continue_string: String = NSLocalizedString("Continue", comment: "a button for proceeding during an alert")
    
    internal static var cancel_string: String = NSLocalizedString("Decline", comment: "a cancel button title displayed on the 'changing number of patches' alert")
    
    // MARK: - use notifications alert
    
    internal static var maybeYouShouldUseNotificationsAlertTitle: String = NSLocalizedString("Try Notifications?", comment: "a title for a popup alert asking the user to try the app with notifications turned on")
    
    internal static var maybeYouShouldUseNotificationsAlertMessage: String = NSLocalizedString("With notifications turned on, PatchDay is able to let you know when your patches expire. Turn on settings?", comment: "a message for a popup alert asking the user to try the app with notifications turned on")
    
    // MARK: - suggest location alert
    
    internal static var suggestLocationAlertTitle: String = NSLocalizedString("Suggested Locations", comment: "a descriptive alert title that appears when enabling or disabling the 'auto suggest' bool from the Settings")
    
    internal static var suggestLocationAlertMessage: String = NSLocalizedString("When 'Auto Suggest' is turned on, the 'Auto' button from the Patch Details View chooses the optimal general location based on the current general locations in the patch schedule.  It also enables changing the patch from a 'Patch Expired Notification'.", comment: "a descriptive alert message that appears when enabling or disabling the 'auto suggest' bool from the Settings")
    
    // MARK: - disclaimer
    
    internal static var disclaimerAlertTitle: String = NSLocalizedString("Disclaimer", comment: "Title for an alert that shows up the first time the app launches.")
    
    internal static var disclaimerAlertMessage: String = NSLocalizedString("Use PatchDay responsibly, and please follow prescription or drug instructions!  Go to tryum.ph/patch_day.html to learn more about how to use PatchDay.", comment: "Message for an alert that shows up the first time the app launches.")
    
    internal static var goToSupport: String = NSLocalizedString("Support page", comment: "")
    
    // MARK: - numerical
    
    internal static var patchCounts: [String] = { return ["1", "2", "3", "4"] }()
    
    internal static var notificationSettings: [String] = { return ["30", "60", "120"] }()
    
    // MARK: - general
    
    internal static var unplaced_string: String = { return "unplaced"}()
    
    internal static var entityName: String = { return "Patch" }()
    
    // MARK: - PatchDataController
    
    internal static var patchPropertyNames: [String] = {return ["datePlaced","location"] }()
    
    internal static var patchEntityNames: [String] = { return ["PatchA", "PatchB", "PatchC", "PatchD"] }()
    
    internal static var patchData: String = { return "patchData" }()
    
    // MARK: - SettingsDefaultsController
    
    internal static var settingsChoices: [String] = { return ["interval", "count", "notifications"] }()
    
    internal static var defaultKeys: [String] = { return ["patchChangeInterval", "numberOfPatches", "autoChooseLocation", "notification", "remindMe", "mentioned"] }()
    
    internal static func interval() -> String {
        return settingsChoices[0]
    }
    internal static func count() -> String {
        return settingsChoices[1]
    }
    internal static func notifications() -> String {
        return settingsChoices[2]
    }
    
    internal static func patchChangeInterval_string() -> String {
        return defaultKeys[0]
    }
    
    internal static func numberOfPatches_string() -> String {
        return defaultKeys[1]
    }
    
    internal static func autoChooseLocation_string() -> String {
        return defaultKeys[2]
    }
    
    internal static func notificationKey_string() -> String {
        return defaultKeys[3]
    }
    
    internal static func remindMe_string() -> String {
        return defaultKeys[4]
    }
    
    internal static func mentioned_string() -> String {
        return defaultKeys[5]
    }
    
    // MARK: - Colors
    
    internal static var colorKeys: [String] = { return ["offWhite","lightBlue","cuteGray","lighterCuteGray"] }()
    
    internal static func offWhite() -> String {
        return colorKeys[0]
    }
    
    internal static func lightBlue() -> String {
        return colorKeys[1]
    }
    
    internal static func cuteGray() -> String {
        return colorKeys[2]
    }
    
    internal static func lighterCuteGray() -> String {
        return colorKeys[3]
    }
    
    
    // MARK: - getting location names
    
    internal static func rightButt() -> String {
        return patchLocationNames[0]
    }
    
    internal static func leftButt() -> String {
        return patchLocationNames[1]
    }
    
    internal static func rightStom() -> String {
        return patchLocationNames[2]
    }
    
    internal static func leftStom() -> String {
        return patchLocationNames[3]
    }
    
    // MARK: - notification related
    
    internal static var patchChangeSoonIDs: [Int: String] = [0: "CHANGEPATCH1", 1: "CHANGEPATCH2", 2: "CHANGEPATCH3", 3: "CHANGEPATCH4"]
    
    // MARK: - segue id's
    
    internal static var scheduleToSettingsID: String = { return "idScheduleToSettingsSegue" }()
    internal static var settingsToScheduleID: String = { return "idSettingsToScheduleSegue" }()
    internal static var patchDetailsSegueID: String = { return "idPatchDetailsSegue" }()
    
    // MARK: - patch button id's
    internal static var patchButtonIDs: [String] = { return ["patch1", "patch2", "patch3", "patch4"] }()
    
    
}
