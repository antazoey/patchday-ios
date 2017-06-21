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
    
    static public func alertForCoreDataSaveError() {
        currentAlert = UIAlertController(title: PatchDayStrings.coreDataSaveAlertTitle, message: PatchDayStrings.coreDataSaveAlertMessage, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: PatchDayStrings.dismiss_string, style: UIAlertActionStyle.cancel, handler: nil)
        currentAlert.addAction(closeAction)
        currentVC.present(currentAlert, animated: true, completion: nil)
    }
    
    static public func alertForChangingPatchCount(newPatchCount: Int, numberOfPatchesButton: UIButton) {
        currentAlert = UIAlertController(title: PatchDayStrings.changingNumberOfPatchesAlertTitle, message: PatchDayStrings.changingNumberOfPatchesAlertMessage, preferredStyle: .alert)
        // accepting stored the new patch count in user defaults
        let acceptAction = UIAlertAction(title: PatchDayStrings.proceed_string, style: UIAlertActionStyle.default) {
            (void) in
            // update User Defaults
            SettingsController.setNumberOfPatches(with: PatchDayStrings.patchCounts[newPatchCount])
            // set button title
            numberOfPatchesButton.setTitle(SettingsController.getNumberOfPatchesString(), for: .normal)
        }
        // declining dismisses the alert
        let declineAction = UIAlertAction(title: PatchDayStrings.forget_it_string, style: UIAlertActionStyle.cancel, handler: nil)
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
