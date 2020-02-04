//
//  QuantityMutationAlert.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/20/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class QuantityMutationAlert: Alert {
    
    private let oldQuantity: Int
    private let newQuantity: Int
    private let handler: QuantityMutationActionHandler
    
    private var continueAction: UIAlertAction {
        let contStr = ActionStrings.Continue
        return UIAlertAction(title: contStr, style: .destructive) {
            void in self.handler.cont(self.newQuantity)
        }
    }
    
    private var cancelAction: UIAlertAction {
        let title = ActionStrings.Decline
        return UIAlertAction(title: title, style: .cancel) {
            void in self.handler.cancel(self.oldQuantity)
        }
    }
    
    init(parent: UIViewController,
         style: UIAlertController.Style,
         actionHandler: QuantityMutationActionHandler,
         oldQuantity: Int,
         newQuantity: Int) {
        self.handler = actionHandler
        self.oldQuantity = oldQuantity
        self.newQuantity = newQuantity
        let strs = AlertStrings.loseDataAlertStrings
        super.init(parent: parent, title: strs.title, message: strs.message, style: style)
    }
    
    override func present() {
        super.present(actions: [continueAction, cancelAction])
    }
}
