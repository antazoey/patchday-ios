//
//  PDStateManaging.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol PDStateManaging {
    var wereHormonalChanges: Bool { get set }
    var increasedQuantity: Bool { get set }
    var decreasedQuantity: Bool { get set }
    var bodilyChanged: Bool { get set }
    var onlySiteChanged: Bool { get set }
    var deliveryMethodChanged: Bool { get set }
    var isCerebral: Bool { get set }
    var oldQuantity: Int { get set }
    var mutatedHormoneIds: [UUID?] { get set }
    func reset()
    func hormoneDateDidChange(for id: UUID) -> Bool
    func hormonalBodilyDidChange(for id: UUID) -> Bool
    func markSiteForImageMutation(site: Bodily)
}
