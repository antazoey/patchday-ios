//
//  PDStateManaging.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol PDStateManaging {
    var wereEstrogenChanges: Bool { get set }
    var increasedCount: Bool { get set }
    var decreasedCount: Bool { get set }
    var siteChanged: Bool { get set }
    var onlySiteChanged: Bool { get set }
    var deliveryMethodChanged: Bool { get set }
    var isHormoneless: Bool { get set }
    var oldQuantity: Int { get set }
    var indicesOfChangedDelivery: [Int] { get set }
    func reset()
}
