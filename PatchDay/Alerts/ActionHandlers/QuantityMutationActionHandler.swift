//
//  ChangeQuantityAlertHandler.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/17/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

class QuantityMutationActionHandler {

    var cont: (_ newQuantity: Int) -> ()
    var cancel: (_ oldQuantity: Int) -> ()
    
    init(cont: @escaping (_ newQuantity: Int) -> (), cancel: @escaping (_ oldQuantity: Int) -> ()) {
        self.cont = cont
        self.cancel = cancel
    }
}
