//
//  PDAlertController.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/20/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit

internal class PDAlertController {
    
    // Description:  class for controlling PatchDay's alerts.
    
    static internal var currentAlert = UIAlertController()
    
    // MARK: - disclaimer / tutorial alert
    
    static internal func alertForChangingCount(startIndexForReset: Int, endIndexForReset: Int, newCount: String, countButton: UIButton) {
        if let currentVC = self.getRootVC() {
            var alertStyle: UIAlertControllerStyle
            // ipad -> .alert
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad) {
                alertStyle = .alert
            }
                // iphone -> .actionSheet
            else {
                alertStyle = .actionSheet
            }
            currentAlert = UIAlertController(title: PDStrings.changeCountAlertTitle, message: PDStrings.changeCountAlertMessage, preferredStyle: alertStyle)
            let continueAction = UIAlertAction(title: PDStrings.continue_string, style: .destructive) {
                (void) in
                ScheduleController.coreData.resetData(start_i: startIndexForReset, end_i: endIndexForReset)
                UserDefaultsController.setQuantityWithoutWarning(to: newCount)
                print("New count: " + newCount)
            }
            let cancelAction = UIAlertAction(title: PDStrings.cancel_string, style: .cancel) {
                (void) in
                countButton.setTitle(String(endIndexForReset), for: .normal)
            }
            currentAlert.addAction(continueAction)
            currentAlert.addAction(cancelAction)
            currentVC.present(currentAlert, animated: true, completion: nil)
        }
    }
    
    static internal func alertForDisclaimerAndTutorial() {
        if let currentVC = self.getRootVC() {
            // ipad -> .alert
            var alertStyle: UIAlertControllerStyle
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad) {
            alertStyle = .alert
            }
                // iphone -> .actionSheet
            else {
                alertStyle = .actionSheet
            }
            currentAlert = UIAlertController(title: PDStrings.disclaimerAlertTitle, message: PDStrings.disclaimerAlertMessage, preferredStyle: alertStyle)
            let closeAction = UIAlertAction(title: PDStrings.dismiss_string, style:     UIAlertActionStyle.cancel, handler: nil)
            let goToAction = UIAlertAction(title: PDStrings.goToSupport, style: .default) {
                (void) in
                if let url = URL(string: "http://tryum.ph/patch_day.html") {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            }
            currentAlert.addAction(goToAction)
            currentAlert.addAction(closeAction)
            currentVC.present(currentAlert, animated: true, completion: nil)
        }
    }
    
    //MARK: - core data save error
    
    static internal func alertForCoreDataSaveError() {
        if let currentVC = self.getRootVC() {
            currentAlert = UIAlertController(title: PDStrings.coreDataSaveAlertTitle, message:  PDStrings.coreDataSaveAlertMessage, preferredStyle: .alert)
            let closeAction = UIAlertAction(title: PDStrings.dismiss_string, style:     UIAlertActionStyle.cancel, handler: nil)
            currentAlert.addAction(closeAction)
            currentVC.present(currentAlert, animated: true, completion: nil)
        }
    }
    
    static internal func alertForCoreDataError() {
        if let currentVC = self.getRootVC() {
            currentAlert = UIAlertController(title: PDStrings.coreDataAlertTitle, message: PDStrings.coreDataAlertMessage, preferredStyle: .alert)
            let closeAction = UIAlertAction(title: PDStrings.dismiss_string, style: UIAlertActionStyle.cancel, handler: nil)
            currentAlert.addAction(closeAction)
            currentVC.present(currentAlert, animated: true, completion: nil)
        }
    }
    
    // MARK: - enabling or disabling "Suggest location functionality"
    
    // alertSLF(changingTo) : an alert displaying the description of the SLF: Suggestion Location Functionality.
    static internal func alertSLF(changingTo: Bool) {
        if let currentVC = self.getRootVC() {
            currentAlert = UIAlertController(title: PDStrings.suggestLocationAlertTitle,
            message: PDStrings.suggestLocationAlertMessage, preferredStyle: .alert)
            let continueAction = UIAlertAction(title: PDStrings.continue_string, style: UIAlertActionStyle.default) {
                (void) in
                UserDefaultsController.setSLF(to: changingTo)
            }
            currentAlert.addAction(continueAction)
            currentVC.present(currentAlert, animated: true, completion: nil)
        }
        
    }
    
    // MARK: - persistent store load error
    
    static internal func alertForPersistentStoreLoadError(error: NSError) {
        if let currentVC = self.getRootVC() {
            currentAlert = UIAlertController(title: PDStrings.coreDataAlertTitle, message: "(\(String(describing: error))", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: PDStrings.accept_string, style: .destructive) {
            (void) in
            fatalError()
            }
            currentAlert.addAction(cancelAction)
            currentVC.present(currentAlert, animated: true, completion: nil)
        }
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
    static private func getRootVC() -> UIViewController? {
        let window = getKeyWindow()
        return window.rootViewController
    }
}
