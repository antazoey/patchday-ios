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
    
    // This will only be called when the user decreases the delivery count and the patches being removed had data.
    static internal func alertForChangingCount(oldCount: Int, newCount: String, countButton: UIButton) {
        if let newC = Int(newCount) {
            if (newC > oldCount) {
                UserDefaultsController.setQuantityWithoutWarning(to: newCount)
                return
            }
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
                currentAlert = UIAlertController(title: PDStrings.alertStrings.loseDataAlert.title, message: PDStrings.alertStrings.loseDataAlert.message, preferredStyle: alertStyle)
                let continueAction = UIAlertAction(title: PDStrings.actionStrings.continue_, style: .destructive) {
                    (void) in
                    // Note: newCount is start_i because reset only occurs when decreasing count
                    CoreDataController.coreData.resetEstrogenData(start_i: newC, end_i: 3)
                    UserDefaultsController.setQuantityWithoutWarning(to: newCount)
                }
                let cancelAction = UIAlertAction(title: PDStrings.actionStrings.decline, style: .cancel) {
                    (void) in
                    countButton.setTitle(String(oldCount), for: .normal)
                }
                currentAlert.addAction(continueAction)
                currentAlert.addAction(cancelAction)
                currentVC.present(currentAlert, animated: true, completion: nil)
            }
        }
    }
    
    static internal func alertForChangingDeliveryMethod(newMethod: String, oldMethod: String, oldCount: Int, deliveryButton: UIButton, countButton: UIButton){
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
            currentAlert = UIAlertController(title: PDStrings.alertStrings.loseDataAlert.title, message: PDStrings.alertStrings.loseDataAlert.message, preferredStyle: alertStyle)
            let continueAction = UIAlertAction(title: PDStrings.actionStrings.continue_, style: .destructive) {
                (void) in
                CoreDataController.coreData.resetEstrogenData(start_i: 0, end_i: 3)
                let c = (newMethod == PDStrings.pickerData.deliveryMethods[0]) ? "3" : "1"
                UserDefaultsController.setQuantityWithoutWarning(to: c)
                UserDefaultsController.setDeliveryMethod(to: newMethod)
                CoreDataController.deliveryMethodChanged = true
            }
            let cancelAction = UIAlertAction(title: PDStrings.actionStrings.decline, style: .cancel) {
                (void) in
                if oldMethod == PDStrings.pickerData.deliveryMethods[0] {
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
            currentAlert = UIAlertController(title: PDStrings.alertStrings.startUp.title, message: PDStrings.alertStrings.startUp.message, preferredStyle: alertStyle)
            let closeAction = UIAlertAction(title: PDStrings.actionStrings.dismiss, style:     UIAlertActionStyle.cancel, handler: nil)
            let goToAction = UIAlertAction(title: PDStrings.alertStrings.startUp.support, style: .default) {
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
    
    //MARK: - core data save error
    
    static internal func alertForCoreDataError() {
        if let currentVC = self.getRootVC() {
            currentAlert = UIAlertController(title: PDStrings.alertStrings.coreDataAlert.title, message: PDStrings.alertStrings.coreDataAlert.message, preferredStyle: .alert)
            let closeAction = UIAlertAction(title: PDStrings.actionStrings.dismiss, style: UIAlertActionStyle.cancel, handler: nil)
            currentAlert.addAction(closeAction)
            currentVC.present(currentAlert, animated: true, completion: nil)
        }
    }
    
    // MARK: - persistent store load error
    
    static internal func alertForPersistentStoreLoadError(error: NSError) {
        if let currentVC = self.getRootVC() {
            currentAlert = UIAlertController(title: PDStrings.alertStrings.coreDataAlert.title, message: "(\(String(describing: error))", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: PDStrings.actionStrings.accept, style: .destructive) {
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
