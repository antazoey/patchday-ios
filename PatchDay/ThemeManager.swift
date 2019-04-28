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
import PatchData

internal class ThemeManager: NSObject {
    
    public var theme: PDDefaults.PDTheme
    internal var oddCell_c: UIColor
    internal var evenCell_c: UIColor
    internal var bg_c: UIColor
    internal var text_c: UIColor
    internal var border_c: UIColor
    internal var selected_c: UIColor
    internal var unselected_c: UIColor
    internal var button_c: UIColor
    internal var navbar_c: UIColor
    internal var green_c: UIColor
    internal var purple_c: UIColor
    
    public init(theme: PDDefaults.PDTheme) {
        self.theme = theme
        switch theme {
        case .Light:
            oddCell_c = PDColors.getColor(.LightBlue)
            evenCell_c = UIColor.white
            bg_c = UIColor.white
            text_c = UIColor.black
            border_c = PDColors.getColor(.LightGray)
            selected_c = PDColors.getColor(.Pink)
            unselected_c = UIColor.darkGray
            button_c = UIColor.blue
            navbar_c = UIColor.white
            green_c = PDColors.getColor(.Green)
            purple_c = PDColors.getColor(.Purple)
        case .Dark:
            oddCell_c = UIColor.black
            evenCell_c = UIColor.black
            bg_c = UIColor.black
            text_c = UIColor.white
            border_c = UIColor.white
            selected_c = PDColors.getColor(.Black)
            unselected_c = UIColor.lightGray
            button_c = UIColor.white
            navbar_c = PDColors.getColor(.Black)
            green_c = UIColor.green
            purple_c = UIColor.magenta
        }
    }
    
    public func getCellColor(at index: Int) -> UIColor {
        if (index % 2 != 0) {
            return evenCell_c
        } else {
            return oddCell_c
        }
    }
}
