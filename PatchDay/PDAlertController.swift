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
                let alertStyle: UIAlertControllerStyle = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad) ? .alert : .actionSheet
                currentAlert = UIAlertController(title: PDStrings.AlertStrings.loseDataAlert.title, message: PDStrings.AlertStrings.loseDataAlert.message, preferredStyle: alertStyle)
                let continueAction = UIAlertAction(title: PDStrings.ActionStrings.cont, style: .destructive) {
                    (void) in
                    // Note: newCount is start_i because reset only occurs when decreasing count
                    ScheduleController.estrogenController.resetEstrogenData(start_i: newC, end_i: 3)
                    UserDefaultsController.setQuantityWithoutWarning(to: newCount)
                    
                    // Tab bar image / badgeValue
                    if let vcs = navController?.tabBarController?.viewControllers, vcs.count > 0 {
                        let c = ScheduleController.totalEstrogenDue()
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
    
    internal static func alertForChangingDeliveryMethod(newMethod: String, oldMethod: String, oldCount: Int, deliveryButton: UIButton, countButton: UIButton, newImage: UIImage?, newTitle: String?, navController: UINavigationController?){
        if let currentVC = getRootVC() {
            let alertStyle: UIAlertControllerStyle = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad) ? .alert : .actionSheet
            currentAlert = UIAlertController(title: PDStrings.AlertStrings.loseDataAlert.title, message: PDStrings.AlertStrings.loseDataAlert.message, preferredStyle: alertStyle)
            let continueAction = UIAlertAction(title: PDStrings.ActionStrings.cont, style: .destructive) {
                (void) in
                ScheduleController.estrogenController.resetEstrogenData(start_i: 0, end_i: 3)
                let c = (newMethod == PDStrings.PickerData.deliveryMethods[0]) ? "3" : "1"
                UserDefaultsController.setQuantityWithoutWarning(to: c)
                UserDefaultsController.setDeliveryMethod(to: newMethod)
                ScheduleController.deliveryMethodChanged = true

                // Tab bar image / badgeValue
                if let vcs = navController?.tabBarController?.viewControllers, vcs.count > 0 {
                    vcs[0].tabBarItem.image = newImage
                    vcs[0].tabBarItem.title = newTitle
                    vcs[0].tabBarItem.badgeValue = nil
                }
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
            currentAlert = UIAlertController(title: PDStrings.AlertStrings.startUp.title, message: PDStrings.AlertStrings.startUp.message, preferredStyle: alertStyle)
            let closeAction = UIAlertAction(title: PDStrings.ActionStrings.dismiss, style:     UIAlertActionStyle.cancel, handler: nil)
            let goToAction = UIAlertAction(title: PDStrings.AlertStrings.startUp.support, style: .default) {
                (void) in
                if let url = URL(string: "http://www.juliyasmith.com/patchday.html") {
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
    
    //MARK: - Core data errors
    
    internal static func alertForCoreDataError() {
        if let currentVC = getRootVC() {
            currentAlert = UIAlertController(title: PDStrings.AlertStrings.coreDataAlert.title, message: PDStrings.AlertStrings.coreDataAlert.message, preferredStyle: .alert)
            let closeAction = UIAlertAction(title: PDStrings.ActionStrings.dismiss, style: UIAlertActionStyle.cancel, handler: nil)
            currentAlert.addAction(closeAction)
            currentVC.present(currentAlert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Persistent store load error
    
    internal static func alertForPersistentStoreLoadError(error: NSError) {
        if let currentVC = getRootVC() {
            currentAlert = UIAlertController(title: PDStrings.AlertStrings.coreDataAlert.title, message: "(\(String(describing: error))", preferredStyle: .alert)
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
