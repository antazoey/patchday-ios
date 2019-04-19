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

internal class ThemeManager: NSObject {
    
    public var theme: PDTheme
    internal var oddCell_c: UIColor
    internal var evenCell_c: UIColor
    internal var bg_c: UIColor
    internal var text_c: UIColor
    internal var border_c: UIColor
    internal var selected_c: UIColor
    internal var button_c: UIColor
    internal var navbar_c: UIColor
    internal var green_c: UIColor
    internal var purple_c: UIColor
        
    public convenience init(themeStr: String) {
        let theme = ThemeManager.getTheme(from: themeStr)
        self.init(theme: theme)
    }
    
    public init(theme: PDTheme) {
        self.theme = theme
        switch theme {
        case .Dark:
            oddCell_c = UIColor.black
            evenCell_c = UIColor.black
            bg_c = UIColor.black
            text_c = UIColor.white
            border_c = UIColor.white
            selected_c = PDColors.getColor(.Black)
            button_c = UIColor.white
            navbar_c = PDColors.getColor(.Black)
            green_c = UIColor.green
            purple_c = UIColor.magenta
        default:
            oddCell_c = PDColors.getColor(.LightBlue)
            evenCell_c = UIColor.white
            bg_c = UIColor.white
            text_c = UIColor.black
            border_c = PDColors.getColor(.LightGray)
            selected_c = PDColors.getColor(.Pink)
            button_c = UIColor.blue
            navbar_c = UIColor.white
            green_c = PDColors.getColor(.Green)
            purple_c = PDColors.getColor(.Purple)
        }
    }
    
    public func getCellColor(at index: Int) -> UIColor {
        if (index % 2 != 0) {
            return evenCell_c
        } else {
            return oddCell_c
        }
    }
    

    private static func getTheme(from key: String) -> PDTheme {
        switch key {
        case PDStrings.PickerData.themes[1] :
            return .Dark
        default : // light
            return .Light
        }
    }
}
