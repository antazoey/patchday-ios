//
//  BodilyManager.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol Bodily: PDPbjectifiable {
    var estrogens: [Hormonal] { get }
    var imageIdentifier: String { get set }
    var name: SiteName { get set }
    var order: Int { get set }
    var isOccupied: Bool { get }
    func isOccupied(byAtLeast many: Int) -> Bool
    func pushBackupSiteNameToEstrogens()
}
