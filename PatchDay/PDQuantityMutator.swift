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
    let notifications: PDNotificationScheduling
    let cancel: (Int) -> ()
    
    init(sdk: PatchDataDelegate,
         alerts: PDAlertDispatching,
         tabs: PDTabReflective,
         notifications: PDNotificationScheduling,
         cancel: @escaping (Int) -> ()) {
        self.sdk = sdk
        self.alerts = alerts
        self.tabs = tabs
        self.notifications = notifications
        self.cancel = cancel
    }
    
    func setQuantity(to newQuantity: Int) {
        let oldQuantity = sdk.defaults.quantity.rawValue
        if newQuantity < oldQuantity {
            alerts.presentQuantityMutationAlert(
                oldQuantity: oldQuantity,
                newQuantity: newQuantity,
                setter: sdk.setQuantity(to:),
                reset: makeResetClosure(oldQuantity: oldQuantity),
                cancel: self.cancel)
        } else {
            sdk.setQuantity(to: newQuantity)
            cancel(oldQuantity)
        }
    }
    
    private func makeResetClosure(oldQuantity: Int) -> ((Int) -> ()) {
        let reset: (Int) -> () = {
            newQuantity in
            self.tabs.reflectExpiredHormoneBadgeValue()
            self.notifications.cancelExpiredHormoneNotifications(
                from: newQuantity,to: oldQuantity
            )
        }
        return reset
    }
}
