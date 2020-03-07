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
    private let cancelAction: (_ oldQuantity: Int) -> ()
    private let setQuantity: (_ newQuantity: Int) -> ()
    
    init(
        cont: @escaping (_ newQuantity: Int) -> (),
        cancel: @escaping (_ oldQuantity: Int) -> (),
        setQuantity: @escaping (_ newQuantity: Int) -> ()
    ) {
        self.continueAction = cont
        self.cancelAction = cancel
        self.setQuantity = setQuantity
    }
    
    func handleContinue(newQuantity: Int) {
        continueAction(newQuantity)
    }
    
    func handleCancel(oldQuantity: Int) {
        cancelAction(oldQuantity)
    }
    
    func setQuantityWithoutAlert(newQuantity: Int) {
        setQuantity(newQuantity)
    }
}
