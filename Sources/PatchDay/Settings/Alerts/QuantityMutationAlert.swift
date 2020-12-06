//
//  QuantityMutationAlert.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/20/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class QuantityMutationAlert: PDAlert {

    private let oldQuantity: Int
    private let newQuantity: Int
    private let handler: QuantityMutationAlertActionHandling

    private var continueAction: UIAlertAction {
        let contStr = ActionStrings.Continue
        return UIAlertAction(title: contStr, style: .destructive) {
            _ in self.handler.handleContinue(newQuantity: self.newQuantity)
        }
    }

    private var declineAction: UIAlertAction {
        let title = ActionStrings.Decline
        return UIAlertAction(title: title, style: .cancel) {
            _ in self.handler.handleDecline(oldQuantity: self.oldQuantity)
        }
    }

    init(
        style: UIAlertController.Style,
        actionHandler: QuantityMutationAlertActionHandling,
        oldQuantity: Int,
        newQuantity: Int) {
        self.handler = actionHandler
        self.oldQuantity = oldQuantity
        self.newQuantity = newQuantity
        let strings = AlertStrings.loseDataAlertStrings
        super.init(title: strings.title, message: strings.message, style: style)
    }

    override func present() {
        super.present(actions: [continueAction, declineAction])
    }
}
