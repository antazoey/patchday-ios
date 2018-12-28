//
//  PDAlertController.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/20/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit
import PatchData

internal class PDAlertController: NSObject {
    
    override var description: String {
        return "Singleton for controllnig PatchDay's alerts."
    }
    
    internal static var currentAlert = UIAlertController()
    
    // MARK: - Changing delivery method
    
    /// Alert that occurs when the delivery method has changed because data could now be lost.
    internal static func alertForChangingDeliveryMethod(newMethod: String, oldMethod: String, oldCount: Int, deliveryButton: UIButton, countButton: UIButton, settingsVC: SettingsVC?) {
        if let currentVC = getRootVC() {
            let alertStyle: UIAlertControllerStyle = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad) ? .alert : .actionSheet
            currentAlert = UIAlertController(title: PDStrings.AlertStrings.LoseDataAlert.title, message: PDStrings.AlertStrings.LoseDataAlert.message, preferredStyle: alertStyle)
            let continueAction = UIAlertAction(title: PDStrings.ActionStrings.cont, style: .destructive) {
                (void) in
                PDSchedule.estrogenSchedule.reset()
                let c = (newMethod == PDStrings.PickerData.deliveryMethods[0]) ? "3" : "1"
                UserDefaultsController.setQuantityWithoutWarning(to: c)
                UserDefaultsController.setDeliveryMethod(to: newMethod)
                UserDefaultsController.setSiteIndex(to: 0)
                PDSchedule.estrogenSchedule.getEffectManager().deliveryMethodChanged = true
                settingsVC?.resetEstrogensVCTabBarItem()
                TodayData.setEstrogenDataForToday()
                
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
    
    /// Alert that displays a quick tutorial and disclaimer on installation.
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
    
    /// Alert that gives the user the option to add a new site they typed out in the UI.
    internal static func alertForAddSite(with name: SiteName, at index: Index, estroVC: EstrogenVC) {
        if let currentVC = getRootVC() {
            let alertStyle: UIAlertControllerStyle = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad) ? .alert : .actionSheet
            currentAlert = UIAlertController(title: PDStrings.AlertStrings.AddSite.title, message: "", preferredStyle: alertStyle)
            let addAction = UIAlertAction(title: PDStrings.AlertStrings.AddSite.addActionTitle, style: .default) {
                (void) in
                if let _ = PDSchedule.siteSchedule.insert() {
                    estroVC.sitePicker.reloadAllComponents()
                }
                
            }
            let declineAction = UIAlertAction(title: PDStrings.AlertStrings.AddSite.declineActionTitle, style: .default)
            currentAlert.addAction(addAction)
            currentAlert.addAction(declineAction)
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
