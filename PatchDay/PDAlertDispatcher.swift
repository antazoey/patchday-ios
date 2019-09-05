//
//  PDAlertDispatchswift
//  PatchDay
//
//  Created by Juliya Smith on 6/20/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class PDAlertDispatcher: NSObject {
    
    override var description: String {
        return "Singleton for controllnig PatchDay's alerts."
    }
    
    private let estrogenSchedule: EstrogenScheduling
    private let siteSchedule: EstrogenSiteScheduling
    private let defaults: PDDefaultManaging
    
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
    
    convenience override init() {
        self.init(estrogenSchedule: patchData.sdk.estrogenSchedule,
                  siteSchedule: patchData.sdk.siteSchedule,
                  defaults: patchData.sdk.defaults)
    }
    
    init(estrogenSchedule: EstrogenScheduling, siteSchedule: EstrogenSiteScheduling, defaults: PDDefaultManaging) {
        self.estrogenSchedule = estrogenSchedule
        self.siteSchedule = siteSchedule
        self.defaults = defaults
    }

    /// Alert that occurs when the delivery method has changed because data could now be lost.
    func presentDeliveryMethodMutationAlert(newMethod: DeliveryMethod, decline: @escaping ((Int) -> ())) {
        if let root = rootViewController {
            let oldQuantity = defaults.quantity.rawValue
            let oldMethod = defaults.deliveryMethod.value
            DeliveryMethodMutationAlert(parent: root,
                                        style: self.style,
                                        oldDeliveryMethod: oldMethod,
                                        newDeliveryMethod: newMethod,
                                        oldQuantity: oldQuantity,
                                        decline: decline).present()
        }
    }

    /// Alert for changing the count of estrogens causing a loss of data.
    func presentQuantityMutationAlert(oldQuantity: Int,
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
    func presentDisclaimerAlert() {
        if let root = rootViewController {
            DisclaimerAlert(parent: root, style: style).present()
        }
    }
    
    /// Alert that gives the user the option to add a new site they typed out in the UI.
    func presentNewSiteAlert(with name: SiteName, at index: Index, estroVC: EstrogenVC) {
        if let root = rootViewController {
            let handler: () -> () = {
                () in
                if var site = self.siteSchedule.insert(completion: nil) as? Bodily {
                    site.name = name
                    estroVC.sitePicker.reloadAllComponents()
                }
            }
            NewSiteAlert(parent: root, style: style, appendActionHandler: handler).present()
        }
    }
    
    func presentGenericAlert() {
        if let root = rootViewController {
            PDGenericAlert(parent: root, style: style).present()
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
