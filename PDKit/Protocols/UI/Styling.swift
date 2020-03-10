//
//  Styling.swift
//  PatchDay
//
//  Created by Juliya Smith on 9/26/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import UIKit


public protocol Styling {
    var theme: AppTheme { get }
    func getCellColor(at index: Int) -> UIColor
}
