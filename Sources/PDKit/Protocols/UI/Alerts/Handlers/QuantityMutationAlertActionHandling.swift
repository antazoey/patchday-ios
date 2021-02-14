//
//  QuantityMutationAlertHandling.swift
//  PDKit
//
//  Created by Juliya Smith on 2/17/20.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public protocol QuantityMutationAlertActionHandling {
    func handleContinue(newQuantity: Int)
    func handleDecline(oldQuantity: Int)
    func setQuantityWithoutAlert(newQuantity: Int)
}
