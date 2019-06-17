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

internal class PDThemeManager: NSObject {
    
    public var current: PDTheme

    internal var oddCellColor: UIColor
    internal var evenCellColor: UIColor
    internal var bgColor: UIColor
    internal var textColor: UIColor
    internal var borderColor: UIColor
    internal var selectedColor: UIColor
    internal var unselectedColor: UIColor
    internal var buttonColor: UIColor
    internal var navbarColor: UIColor
    internal var greenColor: UIColor
    internal var purpleColor: UIColor
    
    public init(theme: PDTheme) {
        current = theme
        switch theme {
        case .Light:
            oddCellColor = PDColors.getColor(.LightBlue)
            evenCellColor = UIColor.white
            bgColor = UIColor.white
            textColor = UIColor.black
            borderColor = PDColors.getColor(.LightGray)
            selectedColor = PDColors.getColor(.Pink)
            unselectedColor = UIColor.darkGray
            buttonColor = UIColor.blue
            navbarColor = UIColor.white
            greenColor = PDColors.getColor(.Green)
            purpleColor = PDColors.getColor(.Purple)
        case .Dark:
            oddCellColor = UIColor.black
            evenCellColor = UIColor.black
            bgColor = UIColor.black
            textColor = UIColor.white
            borderColor = UIColor.white
            selectedColor = PDColors.getColor(.Black)
            unselectedColor = UIColor.lightGray
            buttonColor = UIColor.white
            navbarColor = PDColors.getColor(.Black)
            greenColor = UIColor.green
            purpleColor = UIColor.magenta
        }
    }
    
    public func getCellColor(at index: Int) -> UIColor {
        return index % 2 == 0 ? evenCellColor : oddCellColor
    }
}
