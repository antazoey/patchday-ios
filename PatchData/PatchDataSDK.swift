//
//  PDSchedule.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/13/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import UIKit
import PDKit

public typealias SiteSet = [String]

public class PatchDataSDK: NSObject, PatchDataDelegate {

    override public var description: String {
        return "Main interface for controlling patch data"
    }

    public let dataMeter: PDDataMeting
    public var patchdata: PatchDataCalling
    public let swallowHandler: PDPillSwallowing
    
    public init(defaults: PDDefaultManaging,
                dataMeter: PDDataMeting,
                hormones: HormoneScheduling,
                pills: PDPillScheduling,
                sites: HormoneSiteScheduling,
                state: PDStateManaging,
                patchdata: PatchDataCalling,
                swallowHandler: PDPillSwallowing) {
        self.defaults = defaults
        self.dataMeter = dataMeter
        self.hormones = hormones
        self.pills = pills
        self.sites = sites
        self.state = state
        self.patchdata = patchdata
        self.swallowHandler = swallowHandler
        super.init()
        self.broadcastHormones()
    }
    
    public convenience init(defaults: PDDefaultManaging,
                            dataMeter: PDDataMeting,
                            hormones: HormoneScheduling,
                            pills: PDPillScheduling,
                            sites: HormoneSiteScheduling,
                            swallowHandler: PDPillSwallowing) {
        self.init(defaults: defaults,
                  dataMeter: dataMeter,
                  hormones: hormones,
                  pills: pills,
                  sites: sites,
                  state: PDState(),
                  patchdata: PatchDataCaller(),
                  swallowHandler: swallowHandler)
    }
    
    public convenience init(swallowHandler: PDPillSwallowing) {
        let dataMeter = PDDataMeter()
        let state = PDState()
        let defaults = PDDefaults(stateManager: state, meter: dataMeter)
        let isNew = !defaults.mentionedDisclaimer.value
        let pills = PDPills(isFirstInit: isNew)
        let method = defaults.deliveryMethod.value
        let interval = defaults.expirationInterval
        let hormones = PDHormones(deliveryMethod: method, interval: interval)
        let indexer = PDSiteIndexer(defaults: defaults)
        let sites = PDSites(
            deliveryMethod: method,
            globalExpirationInterval: interval,
            siteIndexRebounder: indexer
        )
        self.init(
            defaults: defaults,
            dataMeter: dataMeter,
            hormones: hormones,
            pills: pills,
            sites: sites,
            swallowHandler: swallowHandler
        )
    }
    
    public var defaults: PDDefaultManaging
    public var hormones: HormoneScheduling
    public var sites: HormoneSiteScheduling
    public var pills: PDPillScheduling
    public var state: PDStateManaging
    
    /// If the schedules are unmutated after initialization
    public var isFresh: Bool {
        return hormones.isEmpty
            && sites.isDefault(deliveryMethod: deliveryMethod)
    }

    /// The total hormones expired plus the pills due.
    public var totalAlerts: Int {
        return totalHormonesExpired + pills.totalDue
    }

    public var totalHormonesExpired: Int {
        return hormones.totalExpired(defaults.expirationInterval)
    }
    
    public var allSiteNames: [String] {
        return Array(sites.unionWithDefaults(deliveryMethod: deliveryMethod))
    }

    // MARK: - Defaults

    public var siteIndex: Index {
        get { return defaults.siteIndex.rawValue }
        set { _ = defaults.setSiteIndex(to: newValue, siteCount: sites.count) }
    }

    public var deliveryMethod: DeliveryMethod {
        get { return defaults.deliveryMethod.value }
        set {
            defaults.setDeliveryMethod(to: newValue)
            let newIndex = PDKeyStorableHelper.defaultQuantity(for: newValue)
            _ = defaults.setSiteIndex(to: newIndex, siteCount: sites.count)
            broadcastHormones()
            state.deliveryMethodChanged = true
        }
    }

    public var deliveryMethodString: String {
        return PDPickerOptions.getDeliveryMethodString(for: deliveryMethod)
    }
    
    public var quantity: Quantity {
        get { return defaults.quantity.value }
        set {
            let newQuantity = newValue.rawValue
            let endRange = PDPickerOptions.quantities.count
            if newQuantity < endRange && newQuantity > 0 {
                let oldQuantity = defaults.quantity.rawValue
                if newQuantity < oldQuantity {
                    state.decreasedQuantity = true
                    hormones.delete(after: newQuantity - 1)
                } else if newQuantity > oldQuantity {
                    state.decreasedQuantity = false
                    hormones.fillIn(
                        newQuantity: newQuantity,
                        expiration: defaults.expirationInterval,
                        deliveryMethod: deliveryMethod
                    )
                }
                defaults.setQuantity(to: newQuantity)
            }
        }
    }
    
    public func setQuantity(using quantityInt: Int) {
        if let newQuantity = Quantity(rawValue: quantityInt) {
            self.quantity = newQuantity
        }
    }
    
    public var expirationInterval: ExpirationInterval {
        return defaults.expirationInterval.value
    }
    
    public func setExpirationInterval(using expString: String) {
        let exp = PDPickerOptions.getExpirationInterval(for: expString)
        defaults.setExpirationInterval(to: exp)
    }
    
    public var theme: PDTheme {
        return defaults.theme.value
    }
    
    public func setTheme(using themeString: String) {
        let theme = PDPickerOptions.getTheme(for: themeString)
        defaults.setTheme(to: theme)
    }
    
    public func setSiteIndex(to newIndex: Index) -> Index {
        return defaults.setSiteIndex(to: newIndex, siteCount: sites.count)
    }

    // MARK: - Hormones

    public func setHormoneSite(at index: Index, with site: Bodily) {
        state.bodilyChanged = true
        hormones.setSite(at: index, with: site)
        broadcastHormones()
        patchdata.save()
    }

    public func setHormoneDate(at index: Index, with date: Date) {
        hormones.setDate(at: index, with: date)
        broadcastHormones()
        patchdata.save()
    }

    public func setHormoneDateAndSite(for id: UUID, date: Date, site: Bodily) {
        hormones.set(for: id, date: date, site: site)
        broadcastHormones()
        patchdata.save()
    }

    /// Returns set of current occupied SiteNames
    public func getNamesOfOccupiedSites() -> Set<SiteName> {
        return Set(hormones.all.map({(mone: Hormonal) -> SiteName in
            return mone.site?.name ?? ""
        }).filter() { $0 != "" })
    }
    
    public func resetHormonesToDefault() {
        let interval = defaults.expirationInterval
        hormones.reset(deliveryMethod: deliveryMethod, interval: interval)
    }

    // MARK: - Sites

    public func insertNewSite(name: SiteName, completion: (() -> ())?) {
        if var site = sites.insertNew(
            deliveryMethod: defaults.deliveryMethod.value,
            globalExpirationInterval: defaults.expirationInterval,
            completion: completion
        ) {
            site.name = name
        }
    }
    
    public func insertNewSite(name: SiteName) {
        insertNewSite(name: name, completion: nil)
    }
    
    public func insertNewSite() {
        let name = PDStrings.PlaceholderStrings.newSite
        insertNewSite(name: name, completion: nil)
    }
    
    public func swapSites(_ sourceIndex: Index, with destinationIndex: Index) {
        sites.swap(sourceIndex, with: destinationIndex)
        if sourceIndex == sites.nextIndex {
            _ = setSiteIndex(to: destinationIndex)
        }
    }
    
    public func resetSitesToDefault() {
        let interval = defaults.expirationInterval
        sites.reset(deliveryMethod: deliveryMethod, globalExpirationInterval: interval)
    }

    // MARK: - Pills

    public func swallow(_ pill: Swallowable) {
        pills.swallow(pushSharedData: broadcastPills)
        swallowHandler.handleSwallow(pill)
    }
    
    public func setPill(_ pill: Swallowable, with attributes: PillAttributes) {
        pills.set(for: pill, with: attributes)
        broadcastPills()
    }

    // MARK: - DataMeter

    private func broadcastHormones() {
        if let mone = hormones.next {
            let name = sites.suggested?.name ?? PDStrings.PlaceholderStrings.newSite
            dataMeter.broadcastRelevantHormoneData(
                oldestHormone: mone,
                nextSuggestedSite: name,
                interval: defaults.expirationInterval,
                deliveryMethod: defaults.deliveryMethod
            )
        }
    }

    private func broadcastPills() {
        if let next = pills.nextDue {
            dataMeter.broadcastRelevantPillData(nextPill: next)
        }
    }

    // MARK: - Stateful

    public func stampQuantity() {
        state.oldQuantity = defaults.quantity.value.rawValue
    }
    
    public func stateChanged(forHormoneAtIndex index: Index) -> Bool {
        if let mone = hormones.at(index) {
            return state.hormoneHasStateChanges(mone, at: index, quantity: hormones.count)
        }
        return false
    }

    // MARK: - Other public

    /// Returns array of occupied site indices.
    public func occupiedSitesIndices() -> [Index] {
        var indices: [Index] = []
        if let pdSites = sites.all.asPDSiteArray() {
            for mone in hormones.all {
                if let occupiedSite = mone.site?.asPDSite(),
                    let i = pdSites.firstIndex(of: occupiedSite) {
                    indices.append(i)
                }
            }
        }
        return indices
    }

    public func nuke() {
        PatchData.nuke()
        resetHormonesToDefault()
        pills.setAsDefault()
        resetSitesToDefault()
    }
}

extension Array where Iterator.Element == Bodily {
    func asPDSiteArray() -> [PDSite]? {
        return self as? [PDSite]
    }
}

extension Bodily {
    func asPDSite() -> PDSite? {
        return self as? PDSite
    }
}
