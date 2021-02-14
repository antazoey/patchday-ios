//
//  AlertCreating.swift
//  PDKit
//
//  Created by Juliya Smith on 6/14/20.
//  
//

import Foundation

public protocol AlertProducing {

    var tabs: TabReflective? {get set}

    func createDeliveryMethodMutationAlert(
        newDeliveryMethod: DeliveryMethod,
        handlers: DeliveryMethodMutationAlertActionHandling
    ) -> PDAlerting

    func createQuantityMutationAlert(
        handlers: QuantityMutationAlertActionHandling, oldQuantity: Int, newQuantity: Int
    ) -> PDAlerting

    func createHormoneActions(
        _ currentSite: SiteName,
        _ suggestSiteName: SiteName?,
        _ change: @escaping () -> Void,
        _ nav: @escaping () -> Void
    ) -> PDAlerting

    func createPillActions(_ pill: Swallowable, _ handlers: PillCellActionHandling) -> PDAlerting

    func createNewSiteAlert(_ handlers: NewSiteAlertActionHandling) -> PDAlerting

    func createUnsavedAlert(
        _ parent: UIViewController,
        saveAndContinueHandler: @escaping () -> Void,
        discardHandler: @escaping () -> Void
    ) -> PDAlerting

    func createDisclaimerAlert() -> PDAlerting

    func createGenericAlert() -> PDAlerting
}
