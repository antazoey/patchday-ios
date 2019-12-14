//
//  ChangeDeliveryMethodAlert.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/16/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class DeliveryMethodMutationAlert: Alert {
    
    private var sdk: PatchDataDelegate?
    private let tabs: PDTabReflective?
    
    private let oldQuantity: Int
    private let oldDeliveryMethod: DeliveryMethod
    private let newDeliveryMethod: DeliveryMethod
    private let decline: ((Int) -> ())
    
    private var continueAction: UIAlertAction {
        return UIAlertAction(title: ActionStrings.cont, style: .destructive) {
            void in
            self.sdk?.defaults.setDeliveryMethod(to: self.newDeliveryMethod)
            self.tabs?.reflectHormone()
        }
    }
    
    private var declineAction: UIAlertAction {
        return UIAlertAction(title: ActionStrings.decline, style: .cancel) {
            void in self.decline(self.oldQuantity)
        }
    }
    
    convenience init(
        parent: UIViewController,
        style: UIAlertController.Style,
        oldDeliveryMethod: DeliveryMethod,
        newDeliveryMethod: DeliveryMethod,
        oldQuantity: Int,
        decline: @escaping ((_ oldQuantity: Int) -> ())
    ) {
        self.init(
            parent: parent,
            style: style,
            sdk: app?.sdk,
            tabs: app?.tabs,
            oldDeliveryMethod: oldDeliveryMethod,
            newDeliveryMethod: newDeliveryMethod,
            oldQuantity: oldQuantity,
            decline: decline
        )
    }
    
    init(
        parent: UIViewController,
        style: UIAlertController.Style,
        sdk: PatchDataDelegate?,
        tabs: PDTabReflective?,
        oldDeliveryMethod: DeliveryMethod,
        newDeliveryMethod: DeliveryMethod,
        oldQuantity: Int,
        decline: @escaping ((_ oldQuantity: Int) -> ())
    ) {
        self.sdk = sdk
        self.tabs = tabs
        self.oldQuantity = oldQuantity
        self.decline = decline
        let strs = AlertStrings.loseDataAlertStrings
        self.oldDeliveryMethod = oldDeliveryMethod
        self.newDeliveryMethod = newDeliveryMethod
        super.init(
            parent: parent, title: strs.title, message: strs.message, style: style
        )
    }
    
    override func present() {
        super.present(actions: [continueAction, declineAction])
    }
}
