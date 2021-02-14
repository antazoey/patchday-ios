//
//  HormoneTableProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 11/8/20.

import Foundation

public protocol HormonesTableProtocol {
    func getCellRowHeight(viewHeight: CGFloat) -> CGFloat
    func applyTheme()
    func reflectModel()
    func reloadData()
    var cells: [HormoneCellProtocol] { get }
}
