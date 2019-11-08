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
    
    public init(
        defaults: PDDefaultManaging,
        dataMeter: PDDataMeting,
        hormones: HormoneScheduling,
        pills: PDPillScheduling,
        sites: HormoneSiteScheduling,
        state: PDStateManaging,
        patchdata: PatchDataCalling
    ) {
        self.defaults = defaults
        self.dataMeter = dataMeter
        self.hormones = hormones
        self.pills = pills
        self.sites = sites
        self.state = state
        self.patchdata = patchdata
        super.init()
        self.broadcastHormones()
    }
    
    public convenience init(
        defaults: PDDefaultManaging,
        dataMeter: PDDataMeting,
        hormones: HormoneScheduling,
        pills: PDPillScheduling,
        sites: HormoneSiteScheduling
    ) {
        self.init(
            defaults: defaults,
            dataMeter: dataMeter,
            hormones: hormones,
            pills: pills,
            sites: sites,
            state: PDState(),
            patchdata: PatchDataCaller()
        )
    }
    
    public override convenience init() {
        let dataMeter = PDDataMeter()
        let state = PDState()
        let defaults = PDDefaults(
            stateManager: state, handler: PDDefaultsStorageHandler(meter: dataMeter)
        )
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
            sites: sites
        )
    }
    
    public var defaults: PDDefaultManaging
    public var hormones: HormoneScheduling
    public var sites: HormoneSiteScheduling
    public var pills: PDPillScheduling
    public var state: PDStateManaging

    public var isFresh: Bool {
        return hormones.isEmpty
            && sites.isDefault(deliveryMethod: deliveryMethod)
    }

    public var totalAlerts: Int {
        return totalHormonesExpired + pills.totalDue
    }

    public var totalHormonesExpired: Int {
        return hormones.totalExpired(defaults.expirationInterval)
    }
    
    public var allSiteNames: [String] {
        return Array(sites.unionWithDefaults(deliveryMethod: deliveryMethod))
    }

    public var occupiedSites: Set<SiteName> {
        return Set(hormones.all.map({(mone: Hormonal) ->
            SiteName in return mone.site?.name ?? ""
        }).filter() { $0 != "" })
    }

    // MARK: - Defaults

    public var deliveryMethod: DeliveryMethod {
        return defaults.deliveryMethod.value
    }

    public func setDeliveryMethod(to newMethod: DeliveryMethod) {
        defaults.replaceStoredDeliveryMethod(to: newMethod)
        let newIndex = PDKeyStorableHelper.defaultQuantity(for: newMethod)
        defaults.replaceStoredSiteIndex(to: newIndex, siteCount: sites.count)
        broadcastHormones()
        state.deliveryMethodChanged = true
    }

    public func setQuantity(to newQuantity: Int) {
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
            defaults.replaceStoredQuantity(to: newQuantity)
        }
    }
     
    public func setExpirationInterval(to newInterval: String) {
        let exp = PDPickerOptions.getExpirationInterval(for: newInterval)
        defaults.replaceStoredExpirationInterval(to: exp)
    }
    
    public func setTheme(to newTheme: String) {
        let theme = PDPickerOptions.getTheme(for: newTheme)
        defaults.replaceStoredTheme(to: theme)
    }
    
    @discardableResult public func setSiteIndex(to newIndex: Index) -> Index {
        return defaults.replaceStoredSiteIndex(to: newIndex, siteCount: sites.count)
    }

    // MARK: - Hormones

    public func setHormoneSite(at index: Index, with site: Bodily) {
        state.bodilyChanged = true
        hormones.setSite(at: index, with: site)
        broadcastHormones()
        patchdata.save()
        state.onlySiteChanged = true
        state.bodilyChanged = true
    }

    public func setHormoneDate(at index: Index, with date: Date) {
        hormones.setDate(at: index, with: date)
        broadcastHormones()
        patchdata.save()
        state.onlySiteChanged = false
    }

    public func setHormoneDateAndSite(for id: UUID, date: Date, site: Bodily) {
        hormones.set(for: id, date: date, site: site)
        broadcastHormones()
        patchdata.save()
        state.onlySiteChanged = false
        state.bodilyChanged = true
    }
    
    public func setHormoneDateAndSite(at index: Index, date: Date, site: Bodily) {
        hormones.set(at: index, date: date, site: site)
        broadcastHormones()
        patchdata.save()
        state.onlySiteChanged = false
        state.bodilyChanged = true
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
        sites.reorder(at: sourceIndex, to: destinationIndex)
        if sourceIndex == sites.nextIndex {
            setSiteIndex(to: destinationIndex)
        }
    }
    
    @discardableResult public func resetSitesToDefault() -> Int {
        return sites.reset(
            deliveryMethod: deliveryMethod,
            interval: defaults.expirationInterval
        )
    }

    // MARK: - Pills
    
    public func setPill(_ pill: Swallowable, with attributes: PillAttributes) {
        pills.set(for: pill, with: attributes)
        broadcastPills()
    }
    
    @discardableResult public func insetNewPill() -> Swallowable? {
        if let pill = pills.insertNew(completion: self.broadcastPills) {
            return pill
        }
        return nil
    }
    
    public func deletePill(at index: Index) {
        if let pill = pills.at(index) {
            pill.delete()
            broadcastPills()
        }
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
        pills.reset()
        let newSiteCount = resetSitesToDefault()
        defaults.reset(defaultSiteCount: newSiteCount)
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
