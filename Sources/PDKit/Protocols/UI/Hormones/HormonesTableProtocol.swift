//
//  HormoneTableProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 11/8/20.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public protocol HormonesTableProtocol {
    func getCellRowHeight(viewHeight: CGFloat) -> CGFloat
    func applyTheme()
    func reflectModel()
    func reloadData()
    var cells: [HormoneCellProtocol] { get }
}
