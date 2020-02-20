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

    private let sdk: PatchDataSDK?
    private let tabs: TabReflective?

    private var style: UIAlertController.Style = {
        AppDelegate.isPad ? .alert : .actionSheet
    }()

    private var rootViewController: UIViewController? = {
        KeyWindowFinder.keyWindw?.rootViewController
    }()

    init(sdk: PatchDataSDK?, tabs: TabReflective?=nil) {
        self.sdk = sdk
        self.tabs = tabs
    }

    /// Alert that occurs when the delivery method has changed because data could now be lost.
    func presentDeliveryMethodMutationAlert(
        newMethod: DeliveryMethod, handler: DeliveryMethodMutationAlertActionHandling
    ) {
        if let root = rootViewController, let sdk = sdk {
            let oldMethod = sdk.userDefaults.deliveryMethod.value
            let tabs = self.tabs ?? AppDelegate.current?.tabs
            DeliveryMethodMutationAlert(
                parent: root,
                style: self.style,
                sdk: sdk,
                tabs: tabs,
                oldDeliveryMethod: oldMethod,
                newDeliveryMethod: newMethod,
                handler: handler
            ).present()
        }
    }

    /// Alert for changing the count of hormones causing a loss of data.
    func presentQuantityMutationAlert(
        oldQuantity: Int, newQuantity: Int, handler: QuantityMutationAlertActionHandling
    ) {
        if newQuantity > oldQuantity {
            handler.handleSetQuantityWithoutAlert(newQuantity: newQuantity)
            return
        }
        if let root = rootViewController {
            QuantityMutationAlert(
                parent: root,
                style: self.style,
                actionHandler: handler,
                oldQuantity: oldQuantity,
                newQuantity: newQuantity
            ).present()
        }
    }
    
    func presentPillActions() {
        if let root = rootViewController {
            PillCellActionAlert(parent: root).present()
        }
    }

    /// Alert that displays a quick tutorial and disclaimer on installation.
    func presentDisclaimerAlert() {
        if let root = rootViewController {
            DisclaimerAlert(parent: root, style: style).present()
        }
    }

    /// Alert that gives the user the option to add a new site they typed out in the UI.
    func presentNewSiteAlert(handler: NewSiteAlertActionHandling) {
        if let root = rootViewController {
            NewSiteAlert(parent: root, style: style, handler: handler).present()
        }
    }
    
    func presentGenericAlert() {
        if let root = rootViewController {
            PDGenericAlert(parent: root, style: style).present()
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(
    _ input: [String: Any]
) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	Dictionary(uniqueKeysWithValues: input.map {
        key, value in
        (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)
    })
}
