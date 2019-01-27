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
    internal static func alertForChangingDeliveryMethod(newMethod: String,
                                                        oldMethod: String,
                                                        oldCount: Int,
                                                        deliveryButton: UIButton,
                                                        countButton: UIButton,
                                                        settingsVC: SettingsVC?) {
        if let currentVC = getRootVC() {
            let alertStyle: UIAlertControllerStyle =
                (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad)
                    ? .alert : .actionSheet
            let title = PDStrings.AlertStrings.LoseDataAlert.title
            let msg = PDStrings.AlertStrings.LoseDataAlert.message
            currentAlert = UIAlertController(title: title,
                                             message: msg,
                                             preferredStyle: alertStyle)
            let continueAction = UIAlertAction(title: PDStrings.ActionStrings.cont,
                                               style: .destructive) {
                void in
                EstrogenScheduleRef.reset() {
                    let patches = PDStrings.PickerData.deliveryMethods[0]
                    let c = (newMethod == patches) ? 3 : 1
                    Defaults.setQuantityWithoutWarning(to: c)
                    Defaults.setDeliveryMethod(to: newMethod)
                }
                Defaults.setSiteIndex(to: 0)
                State.deliveryMethodChanged = true
                settingsVC?.resetEstrogensVCTabBarItem()
                Schedule.setEstrogenDataForToday()
                
            }
            let declineAction = UIAlertAction(title: PDStrings.ActionStrings.decline,
                                              style: .cancel) {
                void in
                if oldMethod == PDStrings.PickerData.deliveryMethods[0] {
                    countButton.isEnabled = true
                    countButton.setTitle(String(oldCount), for: .disabled)
                    countButton.setTitle(String(oldCount), for: .normal)
                } else {
                    countButton.isEnabled = false
                    countButton.setTitle("1", for: .disabled)
                    countButton.setTitle("1", for: .normal)
                    Defaults.setQuantityWithoutWarning(to: 1)
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
            let alertStyle: UIAlertControllerStyle =
                (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad) ?
                    .alert : .actionSheet
            let title = PDStrings.AlertStrings.StartUp.title
            let msg = PDStrings.AlertStrings.StartUp.message
            currentAlert = UIAlertController(title: title,
                                             message: msg,
                                             preferredStyle: alertStyle)
            let dismiss = PDStrings.ActionStrings.dismiss
            let closeAction = UIAlertAction(title: dismiss,
                                            style: UIAlertActionStyle.cancel,
                                            handler: nil)
            let support = PDStrings.AlertStrings.StartUp.support
            let goToAction = UIAlertAction(title: support,
                                           style: .default) {
                void in
                if let url = URL(string: "http://www.patchdayhrt.com") {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:],
                                                  completionHandler: nil)
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
    internal static func alertForAddSite(with name: SiteName,
                                         at index: Index,
                                         estroVC: EstrogenVC) {
        if let currentVC = getRootVC() {
            let alertStyle: UIAlertControllerStyle =
                (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad) ?
                    .alert : .actionSheet
            let title = PDStrings.AlertStrings.AddSite.title
            currentAlert = UIAlertController(title: title, message: "",
                preferredStyle: alertStyle)
            let add = PDStrings.AlertStrings.AddSite.addActionTitle
            let addAction = UIAlertAction(title: add, style: .default) {
                void in
                if let site = Schedule.siteSchedule.insert() as? MOSite {
                    site.setName(name)
                    estroVC.sitePicker.reloadAllComponents()
                }
            }
            let decline = PDStrings.AlertStrings.AddSite.declineActionTitle
            let declineAction = UIAlertAction(title: decline, style: .default)
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
