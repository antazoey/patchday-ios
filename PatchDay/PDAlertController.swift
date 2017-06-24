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
        currentAlert = UIAlertController(title: PatchDayStrings.coreDataSaveAlertTitle, message: PatchDayStrings.coreDataSaveAlertMessage, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: PatchDayStrings.dismiss_string, style: UIAlertActionStyle.cancel, handler: nil)
        currentAlert.addAction(closeAction)
        currentVC.present(currentAlert, animated: true, completion: nil)
    }
    
    static public func alertForCoreDataError() {
        print(PatchDayStrings.coreDataSaveAlertTitle)
        currentAlert = UIAlertController(title: PatchDayStrings.coreDataAlertTitle, message: PatchDayStrings.coreDataAlertMessage, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: PatchDayStrings.dismiss_string, style: UIAlertActionStyle.cancel, handler: nil)
        currentAlert.addAction(closeAction)
        currentVC.present(currentAlert, animated: true, completion: nil)
    }
    
    // MARK: - changing patch count
    
    static public func alertForChangingPatchCount(newPatchCount: Int, numberOfPatchesButton: UIButton) {
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
    
    // MARK: - resetting patch data
    
    static public func alertForResettingPatchData() {
        currentAlert = UIAlertController(title: PatchDayStrings.resetPatchDataAlertTitle, message: PatchDayStrings.resetPatchDataAlertMessage, preferredStyle: .alert)
        let acceptAction = UIAlertAction(title: PatchDayStrings.accept_string, style: UIAlertActionStyle.default) {
            (void) in
            // reset the patch data
            PatchDataController.resetPatchData()
        }
        let declineAction = UIAlertAction(title: PatchDayStrings.decline_string, style: .cancel, handler: nil)
        currentAlert.addAction(acceptAction)
        currentAlert.addAction(declineAction)
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
