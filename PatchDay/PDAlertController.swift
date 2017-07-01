//
//  AlertController.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/20/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import UIKit

class PDAlertController {
    
    static public var currentVC = getRootVC()
    
    static public var currentAlert = UIAlertController()
    
    //MARK: - core data save error
    
    static public func alertForCoreDataSaveError() {
        print(PatchDayStrings.coreDataSaveAlertTitle)
        print(PatchDayStrings.coreDataSaveAlertMessage)
        currentAlert = UIAlertController(title: PatchDayStrings.coreDataSaveAlertTitle, message: PatchDayStrings.coreDataSaveAlertMessage, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: PatchDayStrings.dismiss_string, style: UIAlertActionStyle.cancel, handler: nil)
        currentAlert.addAction(closeAction)
        currentVC.present(currentAlert, animated: true, completion: nil)
    }
    
    static public func alertForCoreDataError() {
        print(PatchDayStrings.coreDataSaveAlertTitle)
        print(PatchDayStrings.coreDataAlertMessage)
        currentAlert = UIAlertController(title: PatchDayStrings.coreDataAlertTitle, message: PatchDayStrings.coreDataAlertMessage, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: PatchDayStrings.dismiss_string, style: UIAlertActionStyle.cancel, handler: nil)
        currentAlert.addAction(closeAction)
        currentVC.present(currentAlert, animated: true, completion: nil)
    }
    
    // MARK: - changing patch count
    
    static public func alertForChangingPatchCount(newPatchCount: Int, numberOfPatchesButton: UIButton) {
        print(PatchDayStrings.changingNumberOfPatchesAlertTitle)
        print(PatchDayStrings.changingNumberOfPatchesAlertMessage)
        currentAlert = UIAlertController(title: PatchDayStrings.changingNumberOfPatchesAlertTitle, message: PatchDayStrings.changingNumberOfPatchesAlertMessage, preferredStyle: .alert)
        // accepting stored the new patch count in user defaults
        let acceptAction = UIAlertAction(title: PatchDayStrings.accept_string, style: UIAlertActionStyle.default) {
            (void) in
            // update User Defaults
            SettingsController.setNumberOfPatches(with: PatchDayStrings.patchCounts[newPatchCount])
            // set button title
            numberOfPatchesButton.setTitle(SettingsController.getNumberOfPatchesString(), for: .normal)
        }
        // declining dismisses the alert
        let declineAction = UIAlertAction(title: PatchDayStrings.decline_string, style: UIAlertActionStyle.cancel, handler: nil)
        currentAlert.addAction(acceptAction)
        currentAlert.addAction(declineAction)
        currentVC.present(currentAlert, animated: true, completion: nil)
    }
    
    // MARK: - enabling or disabling "Auto suggest location"
    
    static public func alertForAutoSuggestLocationDescription(changingTo: Bool) {
        print(PatchDayStrings.suggestLocationAlertTitle)
        print(PatchDayStrings.suggestLocationAlertMessage)
        currentAlert = UIAlertController(title: PatchDayStrings.suggestLocationAlertTitle,
                                         message: PatchDayStrings.suggestLocationAlertMessage,
                                         preferredStyle: .alert)
        let continueAction = UIAlertAction(title: PatchDayStrings.continue_string, style: UIAlertActionStyle.default) {
            (void) in
            SettingsController.setAutoChoose(bool: changingTo)
        }
        currentAlert.addAction(continueAction)
        currentVC.present(currentAlert, animated: true, completion: nil)
        
    }
    
    // MARK: - resetting patch data
    
    static public func alertForResettingPatchData() {
        print(PatchDayStrings.resetPatchDataAlertTitle)
        print(PatchDayStrings.resetPatchDataAlertMessage)
        currentAlert = UIAlertController(title: PatchDayStrings.resetPatchDataAlertTitle, message: PatchDayStrings.resetPatchDataAlertMessage, preferredStyle: .alert)
        let acceptAction = UIAlertAction(title: PatchDayStrings.accept_string, style: .default) {
            (void) in
            // reset the patch data
            PatchDataController.resetPatchData()
        }
        let declineAction = UIAlertAction(title: PatchDayStrings.decline_string, style: .cancel, handler: nil)
        currentAlert.addAction(acceptAction)
        currentAlert.addAction(declineAction)
        currentVC.present(currentAlert, animated: true, completion: nil)
        
    }
    
    // MARK: - try notifications alert
    
    static public func alertForMaybeYouShouldUseNotifications() {
        print(PatchDayStrings.maybeYouShouldUseNotificationsAlertTitle)
        print(PatchDayStrings.maybeYouShouldUseNotificationsAlertMessage)
        currentAlert = UIAlertController(title: PatchDayStrings.maybeYouShouldUseNotificationsAlertTitle, message: PatchDayStrings.maybeYouShouldUseNotificationsAlertMessage, preferredStyle: .alert)
        let goToSettingsAction = UIAlertAction(title: PatchDayStrings.yes_string, style: .default) {
            (void) in
            if let url = URL(string: "App-Prefs:root=NOTIFICATIONS_ID") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        let dontGoAction = UIAlertAction(title: PatchDayStrings.no_string, style: .default)
        currentAlert.addAction(goToSettingsAction)
        currentAlert.addAction(dontGoAction)
        currentVC.present(currentAlert, animated: true, completion: nil)
        
    }
    
    // MARK: - persistent store load error
    
    static public func alertForPersistentStoreLoadError(error: NSError) {
        print(PatchDayStrings.coreDataAlertTitle)
        print(String(describing: error))
        currentAlert = UIAlertController(title: PatchDayStrings.coreDataAlertTitle, message: "(\(String(describing: error))", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: PatchDayStrings.accept_string, style: .destructive) {
            (void) in
            fatalError()
        }
        currentAlert.addAction(cancelAction)
        currentVC.present(currentAlert, animated: true, completion: nil)
    }
    
    // MARK: - private, getting current view
    
    // get keywindow
    static private func getKeyWindow() -> UIWindow {
        if let window = UIApplication.shared.keyWindow {
            return window
        }
        return UIWindow()
    }
    
    // get rootvc
    static private func getRootVC() -> UIViewController {
        let window = getKeyWindow()
        if let root = window.rootViewController {
            return root
        }
        return UIViewController()
    }
    
    static private func settingsToScheduleSegue() {
        currentVC.performSegue(withIdentifier: PatchDayStrings.settingsToScheduleID, sender: currentVC)
    }

}
