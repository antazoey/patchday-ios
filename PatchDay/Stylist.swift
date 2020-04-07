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


class Stylist: NSObject, Styling {

    var theme: AppTheme
    
    init(theme: PDTheme) {
        self.theme = AppTheme(theme)
    }

    func getCellColor(at index: Int) -> UIColor {
        index % 2 == 0 ? theme[.evenCell] : theme[.oddCell]
    }
    
    func reset(theme: PDTheme) {
        self.theme = AppTheme(theme)
    }
}
