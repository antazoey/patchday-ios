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
    
    internal static var save: String = NSLocalizedString("Save", comment: "for closing a picker view")
    
    internal static var undo: String = NSLocalizedString("undo", comment: "for undoing an action, placed on button")
    
    internal static var due: String = NSLocalizedString("due", comment: "the word due, just in text, indicating something is due")
    
    internal static var time: String = NSLocalizedString("Time:", comment: "for letting know the time when medication is taken")
    
    internal static var tb_disabled: String = NSLocalizedString("T-Blocker (disabled)", comment: "for letting know the t-blocker functionality is disabled, in a title")
    
    internal static var pg_disabled: String = NSLocalizedString("Progesterone (disabled)", comment: "for letting know the progesterone functionality is disabled, in a title")
    
    internal static var expiresSoon: String = NSLocalizedString("Before expiration:", comment: "for indicating whether the user wants to recieve a notification before an expiration")
    
    internal static var timeBeforeExp: String = NSLocalizedString("Time before:", comment: "for indicating the amount of time to recieve a reminder notification before medication expires")
    
    internal static var first_time: String = NSLocalizedString("First ime:", comment: "for letting know the time when medication is taken")
    
    internal static var hasNoDate: String = NSLocalizedString("Patch has no date!", comment: "for when there is no date associated with the patch")
    
    internal static var addPatch_string: String = NSLocalizedString("Add Patch", comment: "Label for view when adding a new patch")
    
    internal static var changePatch_string: String = NSLocalizedString("Change Patch", comment: "Label for view when changing a patch")
    
    internal static var changePatchSoon_string: String = NSLocalizedString("Change Patch Soon", comment: "Label for view when changing a patch")
    
    internal static var expiredPatch_string: String = NSLocalizedString("Expired Patch", comment: "Label for view when changing a patch")
    
    internal static var emptyDateInstruction: String = NSLocalizedString("choose date", comment: "placeholder in date text field when it's a new patch")
    
    internal static var emptyLocationInstruction: String = NSLocalizedString("type or choose location", comment: "placeholder in location text field when it's a new patch")
    
    internal static var expirationIntervals: [String] = [NSLocalizedString("One half-week", tableName: nil, comment: "Displayed in a picker."), NSLocalizedString("One week", tableName: nil, comment: "Displayed in a picker."), NSLocalizedString("Two weeks", comment: "Displayed in a picker.")]
    
    internal static var locationNames: [String] = [NSLocalizedString("Right Buttock", tableName: nil, comment: "location on body for where to place patch"), NSLocalizedString("Left Buttock", tableName: nil, comment: "location on body for where to place patch"), NSLocalizedString("Right Stomach", tableName: nil, comment: "location on body for where to place patch"), NSLocalizedString("Left Stomach", tableName: nil, comment: "location on body for where to place patch")]
    
    internal static var patchDetailsInstruction: String = NSLocalizedString("...", tableName: nil, comment: "instruction for empty patch")
    
    internal static var patchExpires_string: String = NSLocalizedString("Expires: ", tableName: nil, comment: "instruction for patch details")
    
    internal static var patchExpired_string: String = NSLocalizedString("Expired: ", tableName: nil, comment: "instruction for patch details")
    
    internal static var pill_taken: String = NSLocalizedString("✔️", tableName: nil, comment: "letting you know a pill was taken, displayed on a button.")
    
    // notifications
    
    internal static var notificationIntros: [String : String] = ["Right Stomach" : NSLocalizedString("Change patch on your 'Right Stomach' ", comment: "notification telling you where and when to change your patch."),"Left Stomach" : NSLocalizedString("Change patch on your 'Left Stomach' ", comment: "notification telling you where and when to change your patch."),"Right Buttock" : NSLocalizedString("Change patch on your 'Right Buttock' ", comment: "notification telling you where and when to change your patch."),"Left Buttock" : NSLocalizedString("Change patch on your 'Left Buttock' ", comment: "notification telling you where and when to change your patch.")]
    
    internal static var notificationForCustom: String = NSLocalizedString("Change patch ", comment: "notification message for a custom located patch")
    internal static var notificationForCustom_at: String = NSLocalizedString("at: ", comment: " for displaying the date of the expired patch for a custom located notification, occruing directly after notificationForCustom message")
    
    internal static var notificationSuggestion: String = NSLocalizedString("Place new patch here: ", comment: "followed by a suggest location; second line in the notification if and only if the user enabled Suggestion Location Functionality on the SettingsVC")
    
    internal static var notificationWithoutLocation: String = NSLocalizedString("Change a patch ", comment: "notification when there is no location pressent, this really should never happen")
    
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
    
    internal static var suggestLocationAlertTitle: String = NSLocalizedString("Suggested Locations", comment: "a descriptive alert title that appears when enabling or disabling the SLF bool from the Settings")
    
    internal static var suggestLocationAlertMessage: String = NSLocalizedString("When 'Suggest' is turned on, the 'Change Patch' button from the Patch Details View chooses the optimal general location based on the current general locations in the patch schedule.  It also enables changing the patch from a 'Patch Expired' notification.", comment: "a descriptive alert message that appears when enabling or disabling the Suggest Location Functionality bool from the Settings")
    
    // MARK: - disclaimer
    
    internal static var disclaimerAlertTitle: String = NSLocalizedString("Disclaimer", comment: "Title for an alert that shows up the first time the app launches.")
    
    internal static var disclaimerAlertMessage: String = NSLocalizedString("Use PatchDay responsibly, and please follow prescription or drug instructions!  Go to tryum.ph/patch_day.html to learn more about how to use PatchDay.", comment: "Message for an alert that shows up the first time the app launches.")
    
    internal static var goToSupport: String = NSLocalizedString("Support page", comment: "")
    
    // MARK: - numerical
    
    internal static var patchCounts: [String] = { return ["1", "2", "3", "4"] }()
    
    internal static var timesadayCounts: [String] = { return ["1", "2"] }()
    
    internal static var notificationSettings: [String] = { return ["30 minutes", "60 minutes", "120 minutes"] }()
    
    // MARK: - general
    
    internal static var unplaced_string: String = { return "unplaced"}()
    
    internal static var entityName: String = { return "Patch" }()
    
    // MARK: - ScheduleController
    
    internal static var moPropertyNames: [String] = {return ["datePlaced","location"] }()
    
    internal static var entityNames: [String] = { return ["PatchA", "PatchB", "PatchC", "PatchD"] }()
    
    internal static var persistantContainer_key: String = { return "patchData" }()
    
    // MARK: - SettingsDefaultsController
    
    internal static var defaultKeys: [String] = { return ["patchChangeInterval", "numberOfPatches", "autoChooseLocation", "notification", "remindMe", "mentioned", "i_tb", "i_pg", "tb_time", "pg_time", "tb_timesaday", "pg_timesaday", "tb_time2", "pg_time2", "remindMeUpon", "tb1_s", "tb2_s", "pg1_s", "pg2_s"] }()
    
    internal static func interval_key() -> String {
        return defaultKeys[0]
    }
    
    internal static func count_key() -> String {
        return defaultKeys[1]
    }
    
    internal static func slf_key() -> String {
        return defaultKeys[2]
    }
    
    internal static func notif_key() -> String {
        return defaultKeys[3]
    }
    
    internal static func rMeBefore_key() -> String {
        return defaultKeys[4]
    }
    
    internal static func mentionedDisc_key() -> String {
        return defaultKeys[5]
    }
    
    internal static func includeTB_key() -> String {
        return defaultKeys[6]
    }
    
    internal static func includePG_key() -> String {
        return defaultKeys[7]
    }
    
    internal static func tbTime_key() -> String {
        return defaultKeys[8]
    }
    
    internal static func pgTime_key() -> String {
        return defaultKeys[9]
    }
    
    internal static func tb_timesaday_key() -> String {
        return defaultKeys[10]
    }
    
    internal static func pg_timesaday_key() -> String {
        return defaultKeys[11]
    }
    
    internal static func tb2Time_key() -> String {
        return defaultKeys[12]
    }
    
    internal static func pg2Time_key() -> String {
        return defaultKeys[13]
    }
    
    internal static func rMeUpon_key() -> String {
        return defaultKeys[14]
    }
    
    internal static func tb1Stamp_key() -> String {
        return defaultKeys[15]
    }
    
    internal static func tb2Stamp_key() -> String {
        return defaultKeys[16]
    }
    
    internal static func pg1Stamp_key() -> String {
        return defaultKeys[17]
    }
    
    internal static func pg2Stamp_key() -> String {
        return defaultKeys[18]
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
        return locationNames[0]
    }
    
    internal static func leftButt() -> String {
        return locationNames[1]
    }
    
    internal static func rightStom() -> String {
        return locationNames[2]
    }
    
    internal static func leftStom() -> String {
        return locationNames[3]
    }
    
    // MARK: - notification related
    
    internal static var patchChangeSoonIDs: [Int: String] = [0: "CHANGEPATCH1", 1: "CHANGEPATCH2", 2: "CHANGEPATCH3", 3: "CHANGEPATCH4"]
    
    // MARK: - segue id's
    
    internal static var scheduleToSettingsID: String = { return "idScheduleToSettingsSegue" }()
    internal static var settingsToScheduleID: String = { return "idSettingsToScheduleSegue" }()
    internal static var patchDetailsSegueID: String = { return "idPatchDetailsSegue" }()
    internal static var scheduleToPillSegueID: String = { return "idScheduleToPillSegue" }()
    internal static var pillToScheduleSegueID: String = { return "idPillToScheduleSegue" }()
    
    // MARK: - patch button id's
    internal static var patchButtonIDs: [String] = { return ["patch1", "patch2", "patch3", "patch4"] }()
    
    
}
