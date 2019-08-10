//
//  ChangeDeliveryMethodAlert.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/16/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit
import PatchData

class DeliveryMethodMutationAlert: PDAlert {
    
    private let estrogenSchedule: EstrogenScheduling
    private let defaults: PDDefaultManaging
    private var state: PDStateManaging
    private let today: PDTodayAppPrepared
    private let tabs: PDTabReflective?
    
    private let oldQuantity: Int
    private let oldDeliveryMethod: DeliveryMethod
    private let newDeliveryMethod: DeliveryMethod
    private let decline: ((Int) -> ())
    
    private var continueAction: UIAlertAction {
        get {
            return UIAlertAction(title: PDActionStrings.cont, style: .destructive) {
                void in
                self.estrogenSchedule.reset() {
                    var q: Quantity
                    switch self.newDeliveryMethod {
                    case .Patches:
                        q = Quantity.Three
                    case .Injections:
                        q = Quantity.One
                    }
                    self.defaults.setQuantity(to: q.rawValue)
                    self.defaults.setDeliveryMethod(to: self.newDeliveryMethod, shouldReset: true)
                }
                self.defaults.setSiteIndex(to: 0)
                self.state.deliveryMethodChanged = true
                self.tabs?.reflectEstrogen()
                self.today.setEstrogenDataForToday()
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
    
    convenience init(parent: UIViewController,
         style: UIAlertController.Style,
         oldDeliveryMethod: DeliveryMethod,
         newDeliveryMethod: DeliveryMethod,
         oldQuantity: Int,
         decline: @escaping ((_ oldQuantity: Int) -> ())) {
        self.init(parent: parent,
                  style: style,
                  estrogenSchedule: patchData.sdk.estrogenSchedule,
                  defaults: patchData.sdk.defaults,
                  state: patchData.sdk.state,
                  today: patchData.sdk.schedule,
                  tabs: app.tabs,
                  oldDeliveryMethod: oldDeliveryMethod,
                  newDeliveryMethod: newDeliveryMethod,
                  oldQuantity: oldQuantity,
                  decline: decline)
    }
    
    init(parent: UIViewController,
         style: UIAlertController.Style,
         estrogenSchedule: EstrogenScheduling,
         defaults: PDDefaultManaging,
         state: PDStateManaging,
         today: PDTodayAppPrepared,
         tabs: PDTabReflective?,
         oldDeliveryMethod: DeliveryMethod,
         newDeliveryMethod: DeliveryMethod,
         oldQuantity: Int,
         decline: @escaping ((_ oldQuantity: Int) -> ())) {
        self.estrogenSchedule = estrogenSchedule
        self.defaults = defaults
        self.state = state
        self.today = today
        self.tabs = tabs
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
