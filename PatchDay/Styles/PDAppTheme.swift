//
//  PDAppTheme.swift
//  PatchDay
//
//  Created by Juliya Smith on 9/26/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

enum PDThemedAsset {
    case oddCell
    case evenCell
    case bg
    case text
    case border
    case selected
    case button
    case navbar
    case green
    case purple
}

typealias PDAppTheme = Dictionary<PDThemedAsset, UIColor>

extension PDAppTheme {
    public func getCellColor(at index: Int) -> UIColor {
        return index % 2 == 0 ? evenCellColor : oddCellColor
    }
}
