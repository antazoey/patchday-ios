//
//  PDAlertController.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/20/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

internal class PDAlertController {
    
    // Description:  class for controlling PatchDay's alerts.
    
    internal static var currentAlert = UIAlertController()
    
    // MARK: - Changing count
    
    /// Safety alert for changing the count of estrogens causing a loss of data.
    internal static func alertForChangingCount(oldCount: Int, newCount: String, countButton: UIButton, navController: UINavigationController?) {
        if let newC = Int(newCount) {
            if (newC > oldCount) {
                UserDefaultsController.setQuantityWithoutWarning(to: newCount)
                return
            }
            if let currentVC = getRootVC() {
                let alertStyle: UIAlertControllerStyle  = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad) ? .alert : .actionSheet
                currentAlert = UIAlertController(title: PDStrings.AlertStrings.LoseDataAlert.title, message: PDStrings.AlertStrings.LoseDataAlert.message, preferredStyle: alertStyle)
                let continueAction = UIAlertAction(title: PDStrings.ActionStrings.cont, style: .destructive) {
                    (void) in
                    // Note: newCount is start_i because reset only occurs when decreasing count
                    ScheduleController.estrogenController.resetEstrogenData(start_i: newC, end_i: 3)
                    UserDefaultsController.setQuantityWithoutWarning(to: newCount)
                    
                    // Tab bar image / badgeValue
                    if let vcs = navController?.tabBarController?.viewControllers, vcs.count > 0 {
                        let c = ScheduleController.totalEstrogenDue(intervalStr: UserDefaultsController.getTimeIntervalString())
                        vcs[0].navigationController?.tabBarItem.badgeValue = (c > 0) ? String(c) : nil
                    }
                }
                let cancelAction = UIAlertAction(title: PDStrings.ActionStrings.decline, style: .cancel) {
                    (void) in
                    countButton.setTitle(String(oldCount), for: .normal)
                }
                currentAlert.addAction(continueAction)
                currentAlert.addAction(cancelAction)
                currentVC.present(currentAlert, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Changing delivery method
    
    internal static func alertForChangingDeliveryMethod(newMethod: String, oldMethod: String, oldCount: Int, deliveryButton: UIButton, countButton: UIButton, settingsVC: SettingsVC?){
        if let currentVC = getRootVC() {
            let alertStyle: UIAlertControllerStyle = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad) ? .alert : .actionSheet
            currentAlert = UIAlertController(title: PDStrings.AlertStrings.LoseDataAlert.title, message: PDStrings.AlertStrings.LoseDataAlert.message, preferredStyle: alertStyle)
            let continueAction = UIAlertAction(title: PDStrings.ActionStrings.cont, style: .destructive) {
                (void) in
                ScheduleController.estrogenController.resetEstrogenData()
                let c = (newMethod == PDStrings.PickerData.deliveryMethods[0]) ? "3" : "1"
                UserDefaultsController.setQuantityWithoutWarning(to: c)
                UserDefaultsController.setDeliveryMethod(to: newMethod)
                UserDefaultsController.setSiteIndex(to: 0)
                ScheduleController.deliveryMethodChanged = true
                settingsVC?.resetEstrogensVCTabBarItem()
                ScheduleController.setEstrogenDataForToday()
            }
            let declineAction = UIAlertAction(title: PDStrings.ActionStrings.decline, style: .cancel) {
                (void) in
                if oldMethod == PDStrings.PickerData.deliveryMethods[0] {
                    countButton.isEnabled = true
                    countButton.setTitle(String(oldCount), for: .disabled)
                    countButton.setTitle(String(oldCount), for: .normal)
                }
                else {
                    countButton.isEnabled = false
                    countButton.setTitle("1", for: .disabled)
                    countButton.setTitle("1", for: .normal)
                    UserDefaultsController.setQuantityWithoutWarning(to: "1")
                }
                deliveryButton.setTitle(oldMethod, for: .normal)
                
            }
            currentAlert.addAction(continueAction)
            currentAlert.addAction(declineAction)
            currentVC.present(currentAlert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Disclaimer + tutorial
    
    internal static func alertForDisclaimerAndTutorial() {
        if let currentVC = getRootVC() {
            let alertStyle: UIAlertControllerStyle = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad) ? .alert : .actionSheet
            currentAlert = UIAlertController(title: PDStrings.AlertStrings.StartUp.title, message: PDStrings.AlertStrings.StartUp.message, preferredStyle: alertStyle)
            let closeAction = UIAlertAction(title: PDStrings.ActionStrings.dismiss, style:     UIAlertActionStyle.cancel, handler: nil)
            let goToAction = UIAlertAction(title: PDStrings.AlertStrings.StartUp.support, style: .default) {
                (void) in
                if let url = URL(string: "http://www.patchdayhrt.com") {
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
    
    // MARK: - Add site
    
    internal static func alertForAddSite(with name: SiteName, at index: Index, estroVC: EstrogenVC) {
        if let currentVC = getRootVC() {
            let alertStyle: UIAlertControllerStyle = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad) ? .alert : .actionSheet
            currentAlert = UIAlertController(title: PDStrings.AlertStrings.AddSite.title, message: "", preferredStyle: alertStyle)
            let addAction = UIAlertAction(title: PDStrings.AlertStrings.AddSite.addActionTitle, style: .default) {
                (void) in
                if let _ = SiteDataController.appendSite(name: name, order: index, sites: &ScheduleController.siteController.siteArray) {
                    estroVC.sitePicker.reloadAllComponents()
                }
                
            }
            let declineAction = UIAlertAction(title: PDStrings.AlertStrings.AddSite.declineActionTitle, style: .default)
            currentAlert.addAction(addAction)
            currentAlert.addAction(declineAction)
            currentVC.present(currentAlert, animated: true, completion: nil)
        }
    }
    
    //MARK: - Core data errors
    
    internal static func alertForCoreDataError() {
        if let currentVC = getRootVC() {
            currentAlert = UIAlertController(title: PDStrings.AlertStrings.CoreDataAlert.title, message: PDStrings.AlertStrings.CoreDataAlert.message, preferredStyle: .alert)
            let closeAction = UIAlertAction(title: PDStrings.ActionStrings.dismiss, style: UIAlertActionStyle.cancel, handler: nil)
            currentAlert.addAction(closeAction)
            currentVC.present(currentAlert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Persistent store load error
    
    internal static func alertForPersistentStoreLoadError(error: NSError) {
        if let currentVC = getRootVC() {
            currentAlert = UIAlertController(title: PDStrings.AlertStrings.CoreDataAlert.title, message: "(\(String(describing: error))", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: PDStrings.ActionStrings.accept, style: .destructive) {
            (void) in
            fatalError()
            }
            currentAlert.addAction(cancelAction)
            currentVC.present(currentAlert, animated: true, completion: nil)
        }
    }
    
    // MARK: - private, getting current view
    
    /// Gets keywindow.
    private static func getKeyWindow() -> UIWindow {
        if let window = UIApplication.shared.keyWindow {
            return window
        }
        return UIWindow()
    }
    
    /// Gets root VC.
    private static func getRootVC() -> UIViewController? {
        let window = getKeyWindow()
        return window.rootViewController
    }
}
