//
//  QuantityMutationAlertActionHandler.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/17/19.

import Foundation
import PDKit

class QuantityMutationAlertActionHandler: QuantityMutationAlertActionHandling {

    private let continueAction: (_ newQuantity: Int) -> Void
    private let declineAction: (_ oldQuantity: Int) -> Void
    private let setQuantity: (_ newQuantity: Int) -> Void

    init(
        cont: @escaping (_ newQuantity: Int) -> Void,
        decline: @escaping (_ oldQuantity: Int) -> Void,
        setQuantity: @escaping (_ newQuantity: Int) -> Void
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
