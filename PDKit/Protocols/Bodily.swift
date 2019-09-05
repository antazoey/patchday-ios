//
//  BodilyManager.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol Bodily {
    var estrogenRelationship: [Hormonal] { get }
    var imageIdentifier: String { get set }
    var name: String { get set }
    var order: Int { get set }
    func isOccupied(byAtLeast many: Int) -> Bool
    func reset()
    func pushBackupSiteNameToEstrogens()
}
