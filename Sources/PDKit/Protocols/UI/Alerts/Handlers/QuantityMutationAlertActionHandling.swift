//
//  QuantityMutationAlertHandling.swift
//  PDKit
//
//  Created by Juliya Smith on 2/17/20.

import Foundation

public protocol QuantityMutationAlertActionHandling {
    func handleContinue(newQuantity: Int)
    func handleDecline(oldQuantity: Int)
    func setQuantityWithoutAlert(newQuantity: Int)
}
