//
//  TextFieldHelper.swift
//  PDKit
//
//  Created by Juliya Smith on 3/15/21.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public class TextFieldHelper {

    /// Determines if the updated text is okay to be set by not exceeding the max size.
    /// Returns a boolean indicating if it can be set as well as the updated text after replacement.
    public static func canSet(
        currentString: String,
        replacementString: String,
        range: NSRange,
        max: Int = SanitationConstants.MaxResourceNameCharacters
    ) -> (canReplace: Bool, updatedText: String) {
        let newString = (currentString as NSString).replacingCharacters(
            in: range, with: replacementString
        )
        let canSet = newString.count <= max

        if canSet, let textRange = Range(range, in: currentString) {
            let newString = currentString.replacingCharacters(
                in: textRange, with: replacementString
            )
            return (true, newString)
        }
        return (false, currentString)
    }
}
