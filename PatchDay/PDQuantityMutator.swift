//
//  PatchDataHelper.swift
//  PatchDay
//
//  Created by Juliya Smith on 10/20/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class PDQuantityMutator: PDQuantityMutating {
    
    var sdk: PatchDataDelegate
    let alerts: PDAlertDispatching
    let tabs: PDTabReflective
    let cancel: (Int) -> ()
    
    init(sdk: PatchDataDelegate,
         alerts: PDAlertDispatching,
         tabs: PDTabReflective,
         cancel: @escaping (Int) -> ()) {
        self.sdk = sdk
        self.alerts = alerts
        self.tabs = tabs
        self.cancel = cancel
    }
    
    func setQuantity(to newQuantity: Int) {
        let oldQuantity = sdk.quantity.rawValue
        if newQuantity < oldQuantity {
            alerts.presentQuantityMutationAlert(
                oldQuantity: oldQuantity,
                newQuantity: newQuantity,
                setter: sdk.setQuantity(using:),
                reset: makeResetClosure(oldQuantity: oldQuantity),
                cancel: self.cancel)
        } else {
            sdk.setQuantity(using: newQuantity)
            cancel(oldQuantity)
        }
    }
    
    private func makeResetClosure(oldQuantity: Int) -> ((Int) -> ()) {
        let reset: (Int) -> () = {
            newQuantity in
            app.tabs?.reflectExpirationCountAsBadgeValue()
            app.notifications.cancelExpiredHormoneNotifications(
                from: newQuantity,to: oldQuantity
            )
        }
        return reset
    }
}
