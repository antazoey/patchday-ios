//
//  HormoneCellViewModelProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 11/8/20.

import Foundation

public protocol HormoneCellViewModelProtocol {
    var cellIndex: Index { get }
    var hormone: Hormonal? { get }
    var showHormone: Bool { get }
    var moonIcon: UIIcon? { get }
    var badgeId: String { get }
    var backgroundColor: UIColor { get }
    var badgeType: PDBadgeButtonType { get }
    var badgeValue: String? { get }
    var dateString: String? { get }
    var dateFont: UIFont { get }
    var dateLabelColor: UIColor { get }
    init(cellIndex: Index, sdk: PatchDataSDK, isPad: Bool)
}
