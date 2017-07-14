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
    
    // MARK: - disclaimer / tutorial alert
    
    static public func alertForDisclaimerAndTutorial() {
        print(PatchDayStrings.disclaimerAlertTitle)
        print(PatchDayStrings.disclaimerAlertMessage)
        currentAlert = UIAlertController(title: PatchDayStrings.disclaimerAlertTitle, message: PatchDayStrings.disclaimerAlertMessage, preferredStyle: .actionSheet)
        let closeAction = UIAlertAction(title: PatchDayStrings.dismiss_string, style: UIAlertActionStyle.cancel, handler: nil)
        let goToAction = UIAlertAction(title: PatchDayStrings.goToSupport, style: .default) {
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
    
    // MARK: - enabling or disabling "Auto suggest location"
    
    static public func alertForAutoSuggestLocationDescription(changingTo: Bool) {
        print(PatchDayStrings.suggestLocationAlertTitle)
        print(PatchDayStrings.suggestLocationAlertMessage)
        currentAlert = UIAlertController(title: PatchDayStrings.suggestLocationAlertTitle,
                                         message: PatchDayStrings.suggestLocationAlertMessage,
                                         preferredStyle: .alert)
        let continueAction = UIAlertAction(title: PatchDayStrings.continue_string, style: UIAlertActionStyle.default) {
            (void) in
            SettingsDefaultsController.setAutoChooseLocation(to: changingTo)
        }
        currentAlert.addAction(continueAction)
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
