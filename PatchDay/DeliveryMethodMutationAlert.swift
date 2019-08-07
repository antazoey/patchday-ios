//
//  ChangeDeliveryMethodAlert.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/16/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class DeliveryMethodMutationAlert: PDAlert {
    
    private let oldQuantity: Int
    private let oldDeliveryMethod: DeliveryMethod
    private let newDeliveryMethod: DeliveryMethod
    private let decline: ((Int) -> ())
    
    private var continueAction: UIAlertAction {
        get {
            return UIAlertAction(title: PDActionStrings.cont, style: .destructive) {
                void in
                patchData.estrogenSchedule.reset() {
                    var q: Quantity
                    switch self.newDeliveryMethod {
                    case .Patches:
                        q = Quantity.Three
                    case .Injections:
                        q = Quantity.One
                    }
                    patchData.defaults.setQuantityWithoutWarning(to: q.rawValue)
                    patchData.defaults.setDeliveryMethod(to: self.newDeliveryMethod)
                }
                patchData.defaults.setSiteIndex(to: 0)
                patchData.state.deliveryMethodChanged = true
                app.tabs?.reflectEstrogen(deliveryMethod: self.newDeliveryMethod)
                patchData.schedule.setEstrogenDataForToday()
            }
        }
    }
    
    private var declineAction: UIAlertAction {
        get {
            return UIAlertAction(title: PDActionStrings.decline, style: .cancel) {
                void in self.decline(self.oldQuantity)
            }
        }
    }
    
    init(parent: UIViewController,
         style: UIAlertController.Style,
         oldDeliveryMethod: DeliveryMethod,
         newDeliveryMethod: DeliveryMethod,
         oldQuantity: Int,
         decline: @escaping ((_ oldQuantity: Int) -> ())) {
        self.oldQuantity = oldQuantity
        self.decline = decline
        let strs = PDAlertStrings.loseDataAlertStrings
        self.oldDeliveryMethod = oldDeliveryMethod
        self.newDeliveryMethod = newDeliveryMethod
        super.init(parent: parent, title: strs.title, message: strs.message, style: style)
    }
    
    override func present() {
        super.present(actions: [continueAction, declineAction])
    }
}
