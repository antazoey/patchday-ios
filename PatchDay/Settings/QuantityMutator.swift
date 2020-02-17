//
//  PatchDataHelper.swift
//  PatchDay
//
//  Created by Juliya Smith on 10/20/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class QuantityMutator: QuantityMutating {
    
    var sdk: PatchDataSDK?
    let alerts: AlertDispatching?
    let tabs: TabReflective?
    let notifications: NotificationScheduling?
    let cancel: (_ originalQuantity: Int) -> ()
    
    init(sdk: PatchDataSDK?,
         alerts: AlertDispatching?,
         tabs: TabReflective?,
         notifications: NotificationScheduling?,
         cancel: @escaping (_ originalQunatity: Int) -> ()) {
        self.sdk = sdk
        self.alerts = alerts
        self.tabs = tabs
        self.notifications = notifications
        self.cancel = cancel
    }
    
    func setQuantity(to newQuantity: Int) {
        if let sdk = sdk {
            let oldQuantity = sdk.defaults.quantity.rawValue
            if newQuantity < oldQuantity {
                let continueAction: (_ newQuantity: Int) -> () = {
                    (newQuantity) in
                    sdk.hormones.delete(after: newQuantity)
                    sdk.defaults.setQuantity(to: newQuantity)
                    self.makeResetClosure(oldQuantity: oldQuantity)(oldQuantity)
                }
                let handler = QuantityMutationAlertActionHandler(
                    cont: continueAction,
                    cancel: self.cancel,
                    setQuantity: sdk.defaults.setQuantity)
                
                alerts?.presentQuantityMutationAlert(
                    oldQuantity: oldQuantity,
                    newQuantity: newQuantity,
                    handler: handler
                )
            } else {
                sdk.defaults.setQuantity(to: newQuantity)
                cancel(oldQuantity)
            }
        }
    }
    
    private func makeResetClosure(oldQuantity: Int) -> ((Int) -> ()) {
        let reset: (Int) -> () = {
            newQuantity in
            self.tabs?.reflectHormoneCharacteristics()
            self.notifications?.cancelRangeOfExpiredHormoneNotifications(
                from: newQuantity,to: oldQuantity
            )
        }
        return reset
    }
}
