//
//  SiteCellViewModelProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 11/8/20.

import Foundation

public protocol SiteCellViewModelProtocol {
    var siteNameText: String { get }
    var orderText: String { get }
    func getVisibilityBools(
        cellIsInEditMode: Bool) -> (hideNext: Bool, hideOrder: Bool, hideArrow: Bool
    )
}
