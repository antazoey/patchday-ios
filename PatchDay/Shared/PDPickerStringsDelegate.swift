//
//  PDPickerStrings.swift
//  PDKit
//
//  Created by Juliya Smith on 4/29/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit
import PatchData

public class PDPickerStringsDelegate {
    
    typealias S = PDPickerStrings
    
    public static func getPickerStrings(for key: PDDefault) -> [String] {
        switch key {
        case PDDefault.DeliveryMethod:
            return S.deliveryMethods
        case PDDefault.ExpirationInterval:
            return S.expirationIntervals
        case PDDefault.Quantity:
            return S.quantities
        case PDDefault.Theme:
            return S.themes
        default:
            return []
        }
    }
    
    public static func getDeliveryMethod(at i: Index) -> DeliveryMethod {
        if i < S.deliveryMethods.count && i >= 0 {
            let choice = S.deliveryMethods[i]
            return PDPickerStrings.getDeliveryMethod(for: choice)
        }
        return .Patches
    }
    
    public static func getTitle(for deliveryMethod: DeliveryMethod) -> String {
            switch deliveryMethod {
            case .Patches:
                return PDStrings.VCTitles.patches
            case .Injections:
                return PDStrings.VCTitles.injections
            }
    }
    
    public static let pillCounts: [String] = { return [S.quantities[0], S.quantities[1]] }()
    
    private static let comment1 = "Displayed on a button and in a picker."
    private static let comment2 = "Displayed in a picker."
    
}
