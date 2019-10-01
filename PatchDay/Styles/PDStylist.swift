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

class PDStylist: NSObject, PDStyling {
    
    private var current: PDTheme
    
    var theme: PDAppTheme {
        let dict = PDAppTheme()
        
    }

//    public init(theme: PDTheme) {
//        current = theme
//        switch theme {
//        case .Light:
//            oddCellColor = UIColor.white
//            evenCellColor = PDColors.getColor(.LightBlue)
//            bgColor = UIColor.white
//            textColor = UIColor.black
//            borderColor = PDColors.getColor(.LightGray)
//            selectedColor = PDColors.getColor(.Pink)
//            unselectedColor = UIColor.darkGray
//            buttonColor = UIColor.blue
//            navbarColor = UIColor.white
//            greenColor = PDColors.getColor(.Green)
//            purpleColor = PDColors.getColor(.Purple)
//        case .Dark:
//            oddCellColor = UIColor.black
//            evenCellColor = UIColor.black
//            bgColor = UIColor.black
//            textColor = UIColor.white
//            borderColor = UIColor.white
//            selectedColor = PDColors.getColor(.Black)
//            unselectedColor = UIColor.lightGray
//            buttonColor = UIColor.white
//            navbarColor = PDColors.getColor(.Black)
//            greenColor = UIColor.green
//            purpleColor = UIColor.magenta
//        }
//    }
//
//    public func getCellColor(at index: Int) -> UIColor {
//        return index % 2 == 0 ? evenCellColor : oddCellColor
//    }
}
