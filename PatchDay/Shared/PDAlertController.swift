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

class PDAlertController: NSObject {
    
    override var description: String {
        return "Singleton for controllnig PatchDay's alerts."
    }
    
    static var currentAlert = UIAlertController()
    
    // MARK: - Changing delivery method
    
    /// Alert that occurs when the delivery method has changed because data could now be lost.
    static func alertForChangingDeliveryMethod(newMethod: DeliveryMethod,
                                                        oldMethod: DeliveryMethod,
                                                        oldCount: Quantity,
                                                        deliveryButton: UIButton,
                                                        countButton: UIButton,
                                                        settingsVC: SettingsVC?) {
        if let currentVC = getRootVC() {
            let alertStyle: UIAlertController.Style =
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
                patchData.estrogenSchedule.reset() {
                    var q: Quantity
                    switch newMethod {
                    case .Patches:
                        q = Quantity.Three
                    case .Injections:
                        q = Quantity.One
                    }
                    patchData.defaults.setQuantityWithoutWarning(to: q.rawValue)
                    patchData.defaults.setDeliveryMethod(to: newMethod)
                }
                patchData.defaults.setSiteIndex(to: 0)
                patchData.state.deliveryMethodChanged = true
                app.tabs?.reflectEstrogen(deliveryMethod: newMethod)               
                patchData.schedule.setEstrogenDataForToday()
                
            }
            let declineAction = UIAlertAction(title: PDStrings.ActionStrings.decline,
                                              style: .cancel) {
                void in
                switch oldMethod {
                case .Patches:
                    countButton.isEnabled = true
                    countButton.setTitle("\(oldCount.rawValue)", for: [.disabled, .normal])
                case .Injections:
                    countButton.isEnabled = false
                    countButton.setTitle("1", for: [.disabled, .normal])
                    patchData.defaults.setQuantityWithoutWarning(to: 1)
                }
                let title = PDPickerStrings.getDeliveryMethod(for: oldMethod)
                deliveryButton.setTitle(title, for: .normal)
                
            }
            currentAlert.addAction(continueAction)
            currentAlert.addAction(declineAction)
            currentVC.present(currentAlert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Disclaimer + tutorial
    
    /// Alert that displays a quick tutorial and disclaimer on installation.
    static func alertForDisclaimerAndTutorial() {
        if let currentVC = getRootVC() {
            let alertStyle: UIAlertController.Style =
                (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad) ?
                    .alert : .actionSheet
            let title = PDStrings.AlertStrings.StartUp.title
            let msg = PDStrings.AlertStrings.StartUp.message
            currentAlert = UIAlertController(title: title,
                                             message: msg,
                                             preferredStyle: alertStyle)
            let dismiss = PDStrings.ActionStrings.dismiss
            let closeAction = UIAlertAction(title: dismiss,
                                            style: UIAlertAction.Style.cancel,
                                            handler: nil)
            let support = PDStrings.AlertStrings.StartUp.support
            let goToAction = UIAlertAction(title: support,
                                           style: .default) {
                void in
                if let url = URL(string: "http://www.patchdayhrt.com") {
                    if #available(iOS 10.0, *) {
                        let options = convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:])
                        UIApplication.shared.open(url, options: options, completionHandler: nil)
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
    static func alertForAddSite(with name: SiteName,
                                         at index: Index,
                                         estroVC: EstrogenVC) {
        if let currentVC = getRootVC() {
            let alertStyle: UIAlertController.Style =
                (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad) ?
                    .alert : .actionSheet
            let title = PDStrings.AlertStrings.AddSite.title
            currentAlert = UIAlertController(title: title, message: "",
                preferredStyle: alertStyle)
            let add = PDStrings.AlertStrings.AddSite.addActionTitle
            let addAction = UIAlertAction(title: add, style: .default) {
                void in
                if let site = patchData.schedule.siteSchedule.insert() as? MOSite {
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

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
