//
//  PDAlertPresenting.swift
//  PatchDay
//
//  Created by Juliya Smith on 8/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

protocol AlertDispatching {
    func presentDeliveryMethodMutationAlert(newMethod: DeliveryMethod, decline: @escaping ((Int) -> ()))
    func presentQuantityMutationAlert(
        oldQuantity: Int,
        newQuantity: Int,
        setter: @escaping (_ newQuantity: Int) -> (),
        reset: @escaping (_ newQuantity: Int) -> (),
        cancel: @escaping (_ oldQuantity: Int) -> ()
    )
    func presentDisclaimerAlert()
    func presentNewSiteAlert(with name: SiteName, at index: Index, hormoneVC: HormoneDetailVC)
    func presentGenericAlert()
}
