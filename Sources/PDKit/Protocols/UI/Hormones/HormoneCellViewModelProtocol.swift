//
//  HormoneCellViewModelProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 11/8/20.

import Foundation

public protocol HormoneCellViewModelProtocol {
    var cellIndex: Index { get }
    var hormone: Hormonal? { get }
    var shouldShowHormone: Bool { get }
    /// Delivery method of the schedule — used to pick the right empty-slot
    /// placeholder when a slot's hormone record isn't present yet (e.g. while
    /// an iCloud import is still in flight) so the cell never renders blank.
    var deliveryMethod: DeliveryMethod { get }
    var moonIcon: UIIcon? { get }
    var cellId: String { get }
    var backgroundColor: UIColor { get }
    var badgeType: PDBadgeButtonType { get }
    var badgeValue: String? { get }
    var dateString: String? { get }
    var dateFont: UIFont { get }
    var dateLabelColor: UIColor { get }
    init(cellIndex: Index, sdk: PatchDataSDK, isPad: Bool)
}
