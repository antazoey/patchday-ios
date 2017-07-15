//
//  AlertController.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/20/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import UIKit

class PDAlertController {
    
    static internal var currentVC = getRootVC()
    
    static internal var currentAlert = UIAlertController()
    
    // MARK: - disclaimer / tutorial alert
    
    static internal func alertForDisclaimerAndTutorial() {
        print(PDStrings.disclaimerAlertTitle)
        print(PDStrings.disclaimerAlertMessage)
        currentAlert = UIAlertController(title: PDStrings.disclaimerAlertTitle, message: PDStrings.disclaimerAlertMessage, preferredStyle: .actionSheet)
        let closeAction = UIAlertAction(title: PDStrings.dismiss_string, style: UIAlertActionStyle.cancel, handler: nil)
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
    
    //MARK: - core data save error
    
    static internal func alertForCoreDataSaveError() {
        print(PDStrings.coreDataSaveAlertTitle)
        print(PDStrings.coreDataSaveAlertMessage)
        currentAlert = UIAlertController(title: PDStrings.coreDataSaveAlertTitle, message: PDStrings.coreDataSaveAlertMessage, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: PDStrings.dismiss_string, style: UIAlertActionStyle.cancel, handler: nil)
        currentAlert.addAction(closeAction)
        currentVC.present(currentAlert, animated: true, completion: nil)
    }
    
    static internal func alertForCoreDataError() {
        print(PDStrings.coreDataSaveAlertTitle)
        print(PDStrings.coreDataAlertMessage)
        currentAlert = UIAlertController(title: PDStrings.coreDataAlertTitle, message: PDStrings.coreDataAlertMessage, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: PDStrings.dismiss_string, style: UIAlertActionStyle.cancel, handler: nil)
        currentAlert.addAction(closeAction)
        currentVC.present(currentAlert, animated: true, completion: nil)
    }
    
    // MARK: - enabling or disabling "Auto suggest location"
    
    static internal func alertForAutoSuggestLocationDescription(changingTo: Bool) {
        print(PDStrings.suggestLocationAlertTitle)
        print(PDStrings.suggestLocationAlertMessage)
        currentAlert = UIAlertController(title: PDStrings.suggestLocationAlertTitle,
                                         message: PDStrings.suggestLocationAlertMessage,
                                         preferredStyle: .alert)
        let continueAction = UIAlertAction(title: PDStrings.continue_string, style: UIAlertActionStyle.default) {
            (void) in
            SettingsDefaultsController.setAutoChooseLocation(to: changingTo)
        }
        currentAlert.addAction(continueAction)
        currentVC.present(currentAlert, animated: true, completion: nil)
        
    }
    
    // MARK: - persistent store load error
    
    static internal func alertForPersistentStoreLoadError(error: NSError) {
        print(PDStrings.coreDataAlertTitle)
        print(String(describing: error))
        currentAlert = UIAlertController(title: PDStrings.coreDataAlertTitle, message: "(\(String(describing: error))", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: PDStrings.accept_string, style: .destructive) {
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
        currentVC.performSegue(withIdentifier: PDStrings.settingsToScheduleID, sender: currentVC)
    }

}
