//
//  QuantityMutationAlertActionHandler.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/17/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


class QuantityMutationAlertActionHandler: QuantityMutationAlertActionHandling {

    private let continueAction: (_ newQuantity: Int) -> ()
    private let declineAction: (_ oldQuantity: Int) -> ()
    private let setQuantity: (_ newQuantity: Int) -> ()
    
    init(
        cont: @escaping (_ newQuantity: Int) -> (),
        decline: @escaping (_ oldQuantity: Int) -> (),
        setQuantity: @escaping (_ newQuantity: Int) -> ()
    ) {
        self.continueAction = cont
        self.declineAction = decline
        self.setQuantity = setQuantity
    }
    
    func handleContinue(newQuantity: Int) {
        continueAction(newQuantity)
    }
    
    func handleDecline(oldQuantity: Int) {
        declineAction(oldQuantity)
    }
    
    func setQuantityWithoutAlert(newQuantity: Int) {
        setQuantity(newQuantity)
    }
}
