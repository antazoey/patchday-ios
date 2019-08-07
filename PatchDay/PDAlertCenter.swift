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

class PDAlertCenter: NSObject {
    
    override var description: String {
        return "Singleton for controllnig PatchDay's alerts."
    }
    
    private var estrogenSchedule: EstrogenSchedule
    
    private var style: UIAlertController.Style = {
        return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad)
                ? .alert : .actionSheet
    }()
    
    private var rootViewController: UIViewController? = {
        if let window = UIApplication.shared.keyWindow {
            return window.rootViewController
        }
        return nil
    }()
    
    init(estrogenSchedule: EstrogenSchedule) {
        self.estrogenSchedule = estrogenSchedule
    }

    /// Alert that occurs when the delivery method has changed because data could now be lost.
    func alertForDeliveryMethodSet(newMethod: DeliveryMethod,
                                   oldMethod: DeliveryMethod,
                                   oldQuantity: Quantity,
                                   decline: @escaping ((Int) -> ())) {
        if let root = rootViewController {
            DeliveryMethodMutationAlert(parent: root,
                                        style: self.style,
                                        oldDeliveryMethod: oldMethod,
                                        newDeliveryMethod: newMethod,
                                        oldQuantity: oldQuantity.rawValue,
                                        decline: decline).present()
        }
    }

    /// Alert for changing the count of estrogens causing a loss of data.
    func alertForQuantitySet(oldQuantity: Int,
                             newQuantity: Int,
                             simpleSetQuantity: @escaping (_ newQuantity: Int) -> (),
                             reset: @escaping (_ newQuantity: Int) -> (),
                             cancel: @escaping (_ oldQuantity: Int) -> ()) {
        if newQuantity > oldQuantity {
            simpleSetQuantity(newQuantity)
            return
        }
        if let root = rootViewController {
            let cont: (_ newQuantity: Int) -> () = {
                (newQuantity) in
                self.estrogenSchedule.reset(from: newQuantity);
                simpleSetQuantity(newQuantity);
                reset(newQuantity)
            }
            let handler = QuantityMutationActionHandler(cont: cont, cancel: cancel)
            QuantityMutationAlert(parent: root,
                                  style: self.style,
                                  actionHandler: handler,
                                  oldQuantity: oldQuantity,
                                  newQuantity: newQuantity).present()
        }
    }
    
    /// Alert that displays a quick tutorial and disclaimer on installation.
    func alertForDisclaimerAndTutorial() {
        if let root = rootViewController {
            DisclaimerAlert(parent: root, style: style).present()
        }
    }
    
    /// Alert that gives the user the option to add a new site they typed out in the UI.
    func alertForAddSite(with name: SiteName, at index: Index, estroVC: EstrogenVC) {
        if let root = rootViewController {
            NewSiteAlert(root, style: style).present()
        }
        
        
        if let currentVC = getRootVC() {
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
            current.addAction(addAction)
            current.addAction(declineAction)
            currentVC.present(current, animated: true, completion: nil)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {
        key, value in
        (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)
    })
}
