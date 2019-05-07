//
//  PDPickerStrings.swift
//  PDKit
//
//  Created by Juliya Smith on 4/29/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public class PDPickerStrings {
    
    public static let deliveryMethods: [String] = {
        let comment = "Displayed on a button and in a picker."
        return [NSLocalizedString("Patches", tableName: nil, comment: comment),
                NSLocalizedString("Injections", tableName: nil, comment: comment)]
    }()
    
    public static let expirationIntervals: [String] = {
        let comment1 = "Displayed on a button and in a picker."
        let comment2 = "Displayed in a picker."
        return [NSLocalizedString("Twice a week", tableName: nil, comment: comment1),
                NSLocalizedString("Once a week", tableName: nil, comment: comment2),
                NSLocalizedString("Once every two weeks", comment: comment1)]
    }()
    
    public static let quantities: [String] = {
        let comment = "Displayed in a picker."
        return [NSLocalizedString("1", comment: comment),
                NSLocalizedString("2", comment: comment),
                NSLocalizedString("3", comment: comment),
                NSLocalizedString("4", comment: comment)]
    }()
    
    public static let themes: [String] = {
        let comment = "Displayed in a picker."
        return [NSLocalizedString("Light", comment: comment),
                NSLocalizedString("Dark", comment: comment)]
    }()
}
