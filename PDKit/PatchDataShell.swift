////
////  PDPickerStrings.swift
////  PDKit
////
////  Created by Juliya Smith on 4/29/19.
////  Copyright © 2019 Juliya Smith. All rights reserved.
////
//
//import Foundation
//import PDKit
//
//
//public class PatchDataShell {
//
//    public func setDeliveryMethodIfSafe(to method: DeliveryMethod) -> Bool {
//        if sdk.estrogenSchedule.isEmpty() &&
//            sdk.siteSchedule.isDefault(deliveryMethod: method) {
//
//            sdk.defaults.setDeliveryMethod(to: method)
//            return true
//        }
//        return false
//    }
//
//    public func setThemeIfSafe(toMethodAt i: Index) -> String {
//        if i < S.themes.count && i >= 0 {
//            let choice = PDPickerStrings.themes[i]
//            let theme = PDPickerStrings.getTheme(for: choice)
//            sdk.defaults.setTheme(to: theme)
//            return choice
//        }
//        return ""
//    }
//
//    public func setExpirationIntervalIfSafe(at i: Index) -> (didSet: Bool, chosenIntervalRaw: String) {
//        if i < S.expirationIntervals.count && i >= 0 {
//            let choice = S.expirationIntervals[i]
//            if let interval = ExpirationIntervalUD.makeExpirationInterval(from: choice) {
//
//                sdk.defaults.setExpirationInterval(to: interval)
//                return (true, choice)
//            }
//        }
//        return (false, "")
//    }
//
//    public func setQuantity(to q: Int,
//                            oldQuantityRaw: Int,
//                            reset: @escaping ((Int) -> ()),
//                            cancel: @escaping ((Int) -> ())) {
//        if q < S.quantities.count && q >= 0, let newQuantityRaw = Int(S.quantities[q]) {
//            sdk.state.oldQuantity = oldQuantityRaw
//
//            // Decreasing - will result in deletions if user agrees
//            if newQuantityRaw < oldQuantityRaw {
//                sdk.state.decreasedQuantity = true
//                app.alerts.presentQuantityMutationAlert(oldQuantity: oldQuantityRaw,
//                                                        newQuantity: newQuantityRaw,
//                                                        simpleSetQuantity: sdk.defaults.setQuantity(to:),
//                                                        reset: reset,
//                                                        cancel: cancel)
//            } else {
//                sdk.defaults.setQuantity(to: newQuantityRaw)
//                reset(newQuantityRaw)
//            }
//        }
//    }
//
//    public let pillCounts: [String] = { return [S.quantities[0], S.quantities[1]] }()
//
//}
