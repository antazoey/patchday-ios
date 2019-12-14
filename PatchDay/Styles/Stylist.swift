//
//  Stylist.swift
//  PatchDay
//
//  Created by Juliya Smith on 4/14/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import UIKit
import PDKit


enum ThemedAsset {
    case bg
    case border
    case button
    case evenCell
    case green
    case navBar
    case oddCell
    case purple
    case selected
    case text
    case unselected
}

typealias AppTheme = Dictionary<ThemedAsset, UIColor>

class Stylist: NSObject, Styling {

    var theme: AppTheme
    
    init(theme: PDTheme) {
        self.theme = Stylist.createAppTheme(theme)
    }

    func getCellColor(at index: Int) -> UIColor {
        let color = index % 2 == 0 ? theme[.evenCell] : theme[.oddCell]
        return color ?? UIColor()
    }
    
    static func createAppTheme(_ theme: PDTheme) -> AppTheme {
        switch theme {
        case .Light:
            return [
                .bg : UIColor.white,
                .border : PDColors.get(.LightGray),
                .button : UIColor.blue,
                .evenCell : PDColors.get(.LightBlue),
                .green : PDColors.get(.Green),
                .navBar : UIColor.white,
                .oddCell : UIColor.white,
                .purple : PDColors.get(.Purple),
                .selected : PDColors.get(.Pink),
                .text : UIColor.black,
                .unselected : UIColor.darkGray
            ]
        case .Dark:
            return [
                .bg : UIColor.black,
                .border : UIColor.white,
                .button : UIColor.white,
                .evenCell : UIColor.black,
                .green : UIColor.white,
                .navBar : UIColor.white,
                .oddCell : UIColor.black,
                .purple : PDColors.get(.Purple),
                .selected : PDColors.get(.Black),
                .text : UIColor.white,
                .unselected : UIColor.lightGray
            ]
        }
    }
}
