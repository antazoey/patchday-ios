//
//  ThemeManager.swift
//  PatchDay
//
//  Created by Juliya Smith on 4/14/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import UIKit
import PDKit

enum PDThemedAsset {
    case bg
    case border
    case button
    case evenCell
    case green
    case navbar
    case oddCell
    case purple
    case selected
    case text
    case unselected
}

typealias PDAppTheme = Dictionary<PDThemedAsset, UIColor>

class PDStylist: NSObject, PDStyling {

    let theme: PDAppTheme
    
    public init(theme: PDTheme) {
        switch theme {
        case .Light:
            self.theme = [
                .bg : UIColor.white,
                .border : PDColors.get(.LightGray),
                .button : UIColor.blue,
                .evenCell : PDColors.get(.LightBlue),
                .green : PDColors.get(.Green),
                .navbar : UIColor.white,
                .oddCell : UIColor.white,
                .purple : PDColors.get(.Purple),
                .selected : PDColors.get(.Pink),
                .text : UIColor.black,
                .unselected : UIColor.darkGray
            ]
        case .Dark:
            self.theme = [
                .bg : UIColor.black,
                .border : UIColor.white,
                .button : UIColor.white,
                .evenCell : UIColor.black,
                .green : UIColor.white,
                .navbar : UIColor.white,
                .oddCell : UIColor.black,
                .purple : PDColors.get(.Purple),
                .selected : PDColors.get(.Black),
                .text : UIColor.white,
                .unselected : UIColor.lightGray
            ]
        }
    }

    public func getCellColor(at index: Int) -> UIColor {
        let color = index % 2 == 0 ? theme[.evenCell] : theme[.oddCell]
        return color ?? UIColor()
    }
}
