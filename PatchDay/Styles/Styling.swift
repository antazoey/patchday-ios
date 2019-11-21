//
//  PDStyling.swift
//  PatchDay
//
//  Created by Juliya Smith on 9/26/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

protocol Styling {
    var theme: AppTheme { get }
    func getCellColor(at index: Int) -> UIColor
    func applyTheme(_ theme: PDTheme)
}
