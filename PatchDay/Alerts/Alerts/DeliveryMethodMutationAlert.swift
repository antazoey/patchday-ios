//
//  DeliveryMethodMutationAlert.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/16/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class DeliveryMethodMutationAlert: Alert {
    
    private var sdk: PatchDataSDK?
    private let tabs: TabReflective?
    
    private let oldQuantity: Int
    private let oldDeliveryMethod: DeliveryMethod
    private let newDeliveryMethod: DeliveryMethod
    private let decline: ((Int) -> ())
    
    private var continueAction: UIAlertAction {
        UIAlertAction(title: ActionStrings.Continue, style: .destructive) {
            void in
            self.sdk?.defaults.setDeliveryMethod(to: self.newDeliveryMethod)
            self.tabs?.reflectHormoneCharacteristics()
        }
    }
    
    private var declineAction: UIAlertAction {
        UIAlertAction(title: ActionStrings.Decline, style: .cancel) {
            void in self.decline(self.oldQuantity)
        }
    }
    
    init(
        parent: UIViewController,
        style: UIAlertController.Style,
        sdk: PatchDataSDK?,
        tabs: TabReflective?,
        oldDeliveryMethod: DeliveryMethod,
        newDeliveryMethod: DeliveryMethod,
        oldQuantity: Int,
        decline: @escaping ((_ oldQuantity: Int) -> ())
    ) {
        self.sdk = sdk
        self.tabs = tabs
        self.oldQuantity = oldQuantity
        self.decline = decline
        let strings = AlertStrings.loseDataAlertStrings
        self.oldDeliveryMethod = oldDeliveryMethod
        self.newDeliveryMethod = newDeliveryMethod
        super.init(
            parent: parent, title: strings.title, message: strings.message, style: style
        )
    }
    
    override func present() {
        super.present(actions: [continueAction, declineAction])
    }
}
