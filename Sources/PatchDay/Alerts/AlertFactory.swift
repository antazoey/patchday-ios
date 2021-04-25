//
//  AlertFactory.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/14/20.

import Foundation
import PDKit

class AlertFactory: AlertProducing {

    var sdk: PatchDataSDK
    var tabs: TabReflective?

    init(sdk: PatchDataSDK, tabs: TabReflective?) {
        self.sdk = sdk
        self.tabs = tabs
    }

    func createDeliveryMethodMutationAlert(
        newDeliveryMethod: DeliveryMethod,
        handlers: DeliveryMethodMutationAlertActionHandling
    ) -> PDAlerting {
        let originalMethod = sdk.settings.deliveryMethod.value
        let originalQuantity = sdk.settings.quantity.rawValue
        return DeliveryMethodMutationAlert(
            sdk: self.sdk,
            tabs: self.tabs,
            originalDeliveryMethod: originalMethod,
            originalQuantity: originalQuantity,
            newDeliveryMethod: newDeliveryMethod,
            handlers: handlers
        )
    }

    func createQuantityMutationAlert(
        handlers: QuantityMutationAlertActionHandling, oldQuantity: Int, newQuantity: Int
    ) -> PDAlerting {
        QuantityMutationAlert(
            style: PDAlert.style,
            actionHandler: handlers,
            oldQuantity: oldQuantity,
            newQuantity: newQuantity
        )
    }

    func createHormoneActions(
        _ currentSite: SiteName,
        _ suggestSiteName: SiteName?,
        _ change: @escaping () -> Void,
        _ nav: @escaping () -> Void
    ) -> PDAlerting {
        HormoneCellActionAlert(
            currentSite: currentSite, nextSite: suggestSiteName, changeHormone: change, nav: nav
        )
    }

    func createPillActions(
        _ pill: Swallowable, _ handlers: PillCellActionHandling
    ) -> PDAlerting {
        PillCellActionAlert(pill: pill, handlers: handlers)
    }

    func createNewSiteAlert(_ handlers: NewSiteAlertActionHandling) -> PDAlerting {
        NewSiteAlert(style: PDAlert.style, handlers: handlers)
    }

    func createUnsavedAlert(
        _ parent: UIViewController,
        saveAndContinueHandler: @escaping () -> Void,
        discardHandler: @escaping () -> Void
    ) -> PDAlerting {
        UnsavedChangesAlert(
            parent: parent,
            saveAndContinueHandler: saveAndContinueHandler,
            discardHandler: discardHandler
        )
    }

    func createDisclaimerAlert() -> PDAlerting {
        DisclaimerAlert(style: .alert)
    }

    func createGenericAlert() -> PDAlerting {
        PDGenericAlert(style: PDAlert.style)
    }
}
