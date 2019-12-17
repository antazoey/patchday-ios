//
//  AlertDispatcher.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/20/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class AlertDispatcher: NSObject, AlertDispatching {

    override var description: String { "Controls alerts." }

    private let sdk: PatchDataDelegate?

    private var style: UIAlertController.Style = {
        AppDelegate.isPad ? .alert : .actionSheet
    }()

    private var rootViewController: UIViewController? = {
        if let window = UIApplication.shared.keyWindow {
            return window.rootViewController
        }
        return nil
    }()

    init(sdk: PatchDataDelegate?) {
        self.sdk = sdk
    }

    /// Alert that occurs when the delivery method has changed because data could now be lost.
    func presentDeliveryMethodMutationAlert(
        newMethod: DeliveryMethod, decline: @escaping ((Int) -> ())
    ) {
        if let root = rootViewController, let sdk = sdk {
            let oldQuantity = sdk.defaults.quantity.rawValue
            let oldMethod = sdk.defaults.deliveryMethod.value
            DeliveryMethodMutationAlert(
                parent: root,
                style: self.style,
                oldDeliveryMethod: oldMethod,
                newDeliveryMethod: newMethod,
                oldQuantity: oldQuantity,
                decline: decline
            ).present()
        }
    }

    /// Alert for changing the count of hormones causing a loss of data.
    func presentQuantityMutationAlert(
        oldQuantity: Int,
        newQuantity: Int,
        setter: @escaping (_ newQuantity: Int) -> (),
        reset: @escaping (_ newQuantity: Int) -> (),
        cancel: @escaping (_ oldQuantity: Int) -> ()
    ) {
        if newQuantity > oldQuantity {
            setter(newQuantity)
            return
        }
        if let root = rootViewController {
            let continueAction: (_ newQuantity: Int) -> () = {
                (newQuantity) in
                self.sdk?.hormones.delete(after: newQuantity)
                setter(newQuantity)
                reset(newQuantity)
            }
            let handler = QuantityMutationActionHandler(
                cont: continueAction,
                cancel: cancel
            )
            QuantityMutationAlert(
                parent: root,
                style: self.style,
                actionHandler: handler,
                oldQuantity: oldQuantity,
                newQuantity: newQuantity
            ).present()
        }
    }

    /// Alert that displays a quick tutorial and disclaimer on installation.
    func presentDisclaimerAlert() {
        if let root = rootViewController {
            DisclaimerAlert(parent: root, style: style).present()
        }
    }

    /// Alert that gives the user the option to add a new site they typed out in the UI.
    func presentNewSiteAlert(with name: SiteName, at index: Index, hormoneDetailVC: HormoneDetailVC) {
        if let root = rootViewController {
            let handler: () -> () = {
                () in
                let handler = hormoneDetailVC.viewModel?.handleNewSite ?? { }
                self.sdk?.sites.insertNew(name: name, completion: handler)
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
	Dictionary(uniqueKeysWithValues: input.map {
        key, value in
        (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)
    })
}
