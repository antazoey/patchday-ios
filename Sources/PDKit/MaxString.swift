//
//  MaxString.swift
//  PDKit
//
//  Created by Juliya Smith on 3/15/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public class MaxString {
    public static func canSet(
        currentString: String,
        replacementString: String,
        range: NSRange,
        max: Int = SanitationConstants.MaxResourceNameCharacters
    ) -> Bool {
        let currentString = currentString as NSString
        let newString = currentString.replacingCharacters(
            in: range, with: replacementString
        ) as NSString
        return newString.length <= max
    }
}
