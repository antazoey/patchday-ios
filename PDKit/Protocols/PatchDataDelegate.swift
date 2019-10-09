//
//  PDScheduling.swift
//  PDKit
//
//  Created by Juliya Smith on 9/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol PatchDataDelegate {
    var defaults: PDDefaultManaging { get }
    var hormones: HormoneScheduling { get }
    var sites: HormoneSiteScheduling { get }
    var pills: PDPillScheduling { get }
    var state: PDStateManaging { get }
    var totalAlerts: Int { get }
    func getNamesOfOccupiedSites() -> Set<SiteName>
    func nuke()
    
    // Defaults
    var deliveryMethod: DeliveryMethod { get set }
    var deliveryMethodName: String { get }

    // Sites
    func insertNewSite(name: SiteName, completion: (() -> ())?)
    func insertNewSite()

    // Stateful
    func stampQuantity()
    func checkForStateChangas(forHormoneIndex index: Index) -> Bool

    // Hormones
    func setHormoneSite(at index: Index, with site: Bodily)
    func setHormoneDate(at index: Index, with date: Date)
    func setHormoneDateAndSite(for id: UUID, date: Date, site: Bodily)
    var totalHormonesExpired: Int { get }
    func broadcastHormones()
    
    // Pills
    func swallow(_ pill: Swallowable)
}
