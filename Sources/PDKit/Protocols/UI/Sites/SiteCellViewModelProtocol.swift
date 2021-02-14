//
//  SiteCellViewModelProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 11/8/20.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public protocol SiteCellViewModelProtocol {
    var siteNameText: String { get }
    var orderText: String { get }
    func getVisibilityBools(cellIsInEditMode: Bool) -> (showNext: Bool, showOrder: Bool)
}
