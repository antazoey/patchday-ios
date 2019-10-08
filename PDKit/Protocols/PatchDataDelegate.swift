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
    var deliveryMethod: DeliveryMethod { get set }
    var deliveryMethodName: String { get }
    var totalAlerts: Int { get }
    var totalHormonesExpired: Int { get }
    func insertSite(name: SiteName?, completion: (() -> ())?)
    func broadcastHormones()
    func nuke()
    
    // Stateful
    func stampQuantity()
    func shouldAnimate(hormoneAt index: Index) -> Bool

    // Hormones
    func setEstrogenSite(at index: Index, with site: Bodily) 
    func setEstrogenDate(at index: Index, with date: Date)
    func setEstrogenDateAndSite(for id: UUID, date: Date, site: Bodily)
    func getCurrentSiteNamesInEstrogenSchedule() -> [SiteName]
    
    // Pills
    func swallow(_ pill: Swallowable)
}
