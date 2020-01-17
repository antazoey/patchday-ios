//
//  PatchDataAdapter.swift
//  PatchData
//
//  Created by Juliya Smith on 9/5/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


class CoreDataEntities {

    private static var hormoneMOs: [MOHormone] = []
    private static var siteMOs: [MOSite] = []
    private static var pillMOs: [MOPill] = []

    private var hormonesInitialized = false
    private var pillsInitialized = false
    private var sitesInitialized = false

    private let logger = CoreDataEntitiesLogger()
    private let saver: EntitiesSaver

    var coreDataStack: PDCoreDataWrapping

    init(coreDataStack: PDCoreDataWrapping) {
        self.coreDataStack = coreDataStack
        saver = EntitiesSaver(coreDataStack)
    }
    
    // MARK: Internal Getters (single)
    
    func getManagedHormone(by id: UUID) -> MOHormone? {
        if let hormone = CoreDataEntities.hormoneMOs.first(where: { h in h.id == id }) {
            return hormone
        }
        logger.warnForNonExistence(.hormone, id: id.uuidString)
        return nil
    }
    
    func getManagedPill(by id: UUID) -> MOPill? {
        if let pill = CoreDataEntities.pillMOs.first(where: { p in p.id == id }) {
            return pill
        }
        logger.warnForNonExistence(.pill, id: id.uuidString)
        return nil
    }

    func getManagedSite(by id: UUID) -> MOSite? {
        if let site = CoreDataEntities.siteMOs.first(where: { s in s.id == id }) {
            return site
        }
        logger.warnForNonExistence(.site, id: id.uuidString)
        return nil
    }
    
    // MARK: - Internal Getters (collection)
    
    func getManagedHormoneData() -> [HormoneStruct] {
        if !hormonesInitialized {
            loadStoredHormones()
        }
        
        return getCurrentMananagedHormones()
    }
    
    func getManagedPillData() -> [PillStruct] {
        if !pillsInitialized {
            loadStoredPills()
        }

        return getCurrentManagedPills()
    }
    
    func getManagedSiteData() -> [SiteStruct] {
        if !sitesInitialized {
            loadStoredSites()
        }
        
        return getCurrentManagedSites()
    }
    
    // MARK: - Internal Creators

    func createNewManagedHormone(doSave: Bool=true) -> HormoneStruct? {
        if let newHormone = createNewHormone() {
            if doSave {
                saver.saveCreateNewEntity(.hormone)
            }
            return newHormone
        }
        logger.errorOnCreation(.hormone)
        return nil
    }
    
    func createNewManagedPill(doSave: Bool=true) -> PillStruct? {
        createNewManagedPill(name: SiteStrings.newSite, doSave: doSave)
    }

    func createNewManagedPill(name: String, doSave: Bool=true) -> PillStruct? {
        if let newPill = createNewPill() {
            if doSave {
                saver.saveCreateNewEntity(.pill)
            }
            return newPill
        }
        logger.errorOnCreation(.pill)
        return nil
    }
    
    func createNewManagedSite(doSave: Bool=true) -> SiteStruct? {
        if let newSite = createNewSite() {
            if doSave {
                saver.saveCreateNewEntity(.site)
            }
            return newSite
        }
        return nil
    }
    
    // MARK: - Internal Pushers

    func pushHormoneDataToManagedContext(_ hormoneData: [HormoneStruct], doSave: Bool=true) {
        guard hormoneData.count > 0 else {
            logger.warnForEmptyPush(.hormone)
            return
        }

        logger.logPush(.hormone)
        for data in hormoneData {
            pushHormoneData(data)
        }
        if doSave {
            saver.saveFromPush(.hormone)
        }
    }
    
    func pushPillDataToManagedContext(_ pillData: [PillStruct], doSave: Bool=true) {
        guard pillData.count > 0 else {
            logger.warnForEmptyPush(.pill)
            return
        }

        logger.logPush(.pill)
        for data in pillData {
            pushPillData(data)
        }
        if doSave {
            saver.saveFromPush(.pill)
        }
    }
    
    func pushSiteDataToManagedContext(_ siteData: [SiteStruct], doSave: Bool=true) {
        guard siteData.count > 0 else {
            logger.warnForEmptyPush(.site)
            return
        }

        logger.logPush(.site)
        for data in siteData {
            pushSiteData(data)
        }
        if doSave {
            saver.saveFromPush(.site)
        }
    }
    
    // MARK: - Internal Deleters

    func deleteManagedHormoneData(_ hormoneData: [HormoneStruct], doSave: Bool=true) {
        for data in hormoneData {
            deleteHormone(data)
        }
        if doSave {
             saver.saveFromDelete(.hormone)
         }
    }

    func deleteManagedPillData(_ pillData: [PillStruct], doSave: Bool=true) {
        for data in pillData {
            deletePill(data)
        }
        if doSave {
            saver.saveFromDelete(.pill)
        }
    }
    
    func deleteManagedSiteData(_ siteData: [SiteStruct], doSave: Bool=true) {
        for data in siteData {
            deleteSite(data)
        }
        
        if doSave {
            saver.saveFromDelete(.site)
        }
    }

    // MARK: - Private Loaders

    private func loadStoredHormones() {
        if let hormones = coreDataStack.getManagedObjects(entity: .hormone) as? [MOHormone] {
            logger.logEntityCount(hormones.count, for: .hormone)
            CoreDataEntities.hormoneMOs = hormones
            fixHormoneIdsIfNeeded()
        } else {
            logger.errorOnCreation(.hormone)
        }
        hormonesInitialized = true
    }

    private func loadStoredPills() {
        if let pills = coreDataStack.getManagedObjects(entity: .pill) as? [MOPill] {
            logger.logEntityCount(pills.count, for: .pill)
            CoreDataEntities.pillMOs = pills
            fixPillIdsIfNeeded()
        } else {
            logger.errorOnLoad(.pill)
        }
        pillsInitialized = true
    }

    private func loadStoredSites() {
        if let sites = coreDataStack.getManagedObjects(entity: .site) as? [MOSite] {
            logger.logEntityCount(sites.count, for: .site)
            CoreDataEntities.siteMOs = sites
            fixSiteIdsIfNeeded()
        } else {
            logger.errorOnLoad(.site)
        }
        sitesInitialized = true
    }
    
    // MARK: - Private Getters (collection)
    
    private func getCurrentMananagedHormones() -> [HormoneStruct] {
        var hormoneStructs: [HormoneStruct] = []
        for managedHormone in CoreDataEntities.hormoneMOs {
            if let hormone = CoreDataEntityAdapter.convertToHormoneStruct(managedHormone) {
                hormoneStructs.append(hormone)
            }
        }

        return hormoneStructs
    }
    
    private func getCurrentManagedPills() -> [PillStruct] {
        var pillStructs: [PillStruct] = []
        for managedPill in CoreDataEntities.pillMOs {
            if let pill = CoreDataEntityAdapter.convertToPillStruct(managedPill) {
                pillStructs.append(pill)
            }
        }
        return pillStructs
    }
    
    private func getCurrentManagedSites() -> [SiteStruct] {
        var siteStructs: [SiteStruct] = []
        for managedSite in CoreDataEntities.siteMOs {
            if let site = CoreDataEntityAdapter.convertToSiteStruct(managedSite) {
                siteStructs.append(site)
            }
        }
        return siteStructs
    }
    
    // MARK: - Private Fixers

    private func fixHormoneIdsIfNeeded() {
        for hormone in CoreDataEntities.hormoneMOs {
            if hormone.id == nil {
                hormone.id = UUID()
            }
        }
    }

    private func fixPillIdsIfNeeded() {
        for pill in CoreDataEntities.pillMOs {
            if pill.id == nil {
                pill.id = UUID()
            }
        }
    }

    private func fixSiteIdsIfNeeded() {
        for site in CoreDataEntities.siteMOs {
            if site.id == nil {
                site.id = UUID()
            }
        }
    }
    
    // MARK: - Private Creators
    
    func createNewHormone() -> HormoneStruct? {
        if var newManagedHormone = coreDataStack.insert(.hormone) as? MOHormone {
            initHormone(&newManagedHormone)
            return CoreDataEntityAdapter.convertToHormoneStruct(newManagedHormone)
        }
        return nil
    }
    
    func createNewPill() -> PillStruct? {
        if var newManagedPill = coreDataStack.insert(.pill) as? MOPill {
            initPill(&newManagedPill)
            return CoreDataEntityAdapter.convertToPillStruct(newManagedPill)
        }
        return nil
    }
    
    func createNewSite() -> SiteStruct? {
        if var newManagedSite = coreDataStack.insert(.site) as? MOSite {
            initSite(&newManagedSite)
            return CoreDataEntityAdapter.convertToSiteStruct(newManagedSite)
        }
        return nil
    }
    
    // MARK: - Private Initializers
    
    private func initHormone(_ managedHormone: inout MOHormone) {
        let id = UUID()
        logger.logCreate(.hormone, id: id.uuidString)
        managedHormone.id = id
        CoreDataEntities.hormoneMOs.append(managedHormone)
    }
    
    private func initPill(_ managedPill: inout MOPill) {
        let id = UUID()
        logger.logCreate(.pill, id: id.uuidString)
        managedPill.id = id
        CoreDataEntities.pillMOs.append(managedPill)
    }
    
    private func initSite(_ managedSite: inout MOSite) {
        let id = UUID()
        logger.logCreate(.site, id: id.uuidString)
        managedSite.id = id
        CoreDataEntities.siteMOs.append(managedSite)
    }
    
    // MARK: - Private Pushers

    private func pushBackupSiteNameToHormones(deletedSite: MOSite) {
        if let hormoneSet = deletedSite.hormoneRelationship,
           let hormones = Array(hormoneSet) as? [MOHormone] {
            for hormone in hormones {
                hormone.siteNameBackUp = deletedSite.name
            }
        }
        saver.saveFromPush(.hormone)
    }
    
    private func pushHormoneData(_ hormoneData: HormoneStruct) {
        if var managedHormone = getManagedHormone(by: hormoneData.id) {
            applyHormoneDataToManagedHormone(hormoneData, &managedHormone)
        }
    }
    
    private func pushPillData(_ pillData: PillStruct) {
        if var managedPill = getManagedPill(by: pillData.id) {
            CoreDataEntityAdapter.applyPillData(pillData, to: &managedPill)
        }
    }
    
    private func pushSiteData(_ siteData: SiteStruct) {
        if var managedSite = getManagedSite(by: siteData.id) {
            applySiteDataToManagedSite(siteData, &managedSite)
        }
    }

    // MARK: - Private Appliers
    
    private func applySiteDataToManagedSite(_ siteData: SiteStruct, _ managedSite: inout MOSite) {
        CoreDataEntityAdapter.applySiteData(siteData, to: &managedSite)
        if let hormoneIds = siteData.hormoneRelationshipIds {
            relateHormonesToSite(hormoneIds: hormoneIds, managedSite)
        }
    }
    
    private func applyHormoneDataToManagedHormone(_ hormoneData: HormoneStruct, _ managedHormone: inout MOHormone) {
        CoreDataEntityAdapter.applyHormoneData(hormoneData, to: &managedHormone)
        if let siteId = hormoneData.siteRelationshipId {
            relateSiteToHormone(siteId: siteId, managedHormone)
        }
    }
    
    // MARK: - Private Relators
    
    private func relateSiteToHormone(siteId: UUID, _ managedHormone: MOHormone) {
        guard let hormoneId = managedHormone.id else {
            logger.errorOnMissingId(.hormone)
            return
        }
        
        if let managedSite = getManagedSite(by: siteId), managedSite.id != siteId {
            logger.logRelateSiteToHormone(siteId: siteId, hormoneId: hormoneId)
            managedHormone.addToSiteRelationship(managedSite)
        }
    }
    
    private func relateHormonesToSite(hormoneIds: [UUID], _ managedSite: MOSite) {
        for hormoneId in hormoneIds {
            relateHormoneToSite(hormoneId: hormoneId, managedSite)
        }
    }
    
    private func relateHormoneToSite(hormoneId: UUID, _ managedSite: MOSite) {
        if let managedHormone = getManagedHormone(by: hormoneId) {
            if let relationship = managedSite.hormoneRelationship {
                if relationship.contains(managedHormone) {
                    return
                }
            }
            
            managedSite.addToHormoneRelationship(managedHormone)
        }
    }
    
    // MARK: - Private Deleters
    
    private func deleteHormone(_ hormoneData: HormoneStruct) {
        if var managedHormone = getManagedHormone(by: hormoneData.id) {
            resetHormone(&managedHormone)
            coreDataStack.tryDelete(managedHormone)
        }
    }
    
    private func deletePill(_ pillData: PillStruct) {
        if var managedPill = getManagedPill(by: pillData.id) {
            resetPill(&managedPill)
            coreDataStack.tryDelete(managedPill)
        }
    }
    
    private func deleteSite(_ siteData: SiteStruct) {
        if var managedSite = getManagedSite(by: siteData.id) {
            resetSite(&managedSite)
            pushBackupSiteNameToHormones(deletedSite: managedSite)
            coreDataStack.tryDelete(managedSite)
        }
    }
    
    // MARK: - Private Resetters
    
    private func resetHormone(_ managedHormone: inout MOHormone) {
        managedHormone.id = nil
        managedHormone.date = nil
        managedHormone.siteNameBackUp = nil
        managedHormone.siteRelationship = nil
    }
    
    private func resetPill(_ managedPill: inout MOPill) {
        managedPill.time1 = nil
        managedPill.time2 = nil
        managedPill.id = nil
        managedPill.lastTaken = nil
        managedPill.timesTakenToday = -1
        managedPill.notify = false
        managedPill.timesaday = -1
    }
    
    private func resetSite(_ managedSite: inout MOSite) {
        managedSite.name = nil
        managedSite.id = nil
        managedSite.imageIdentifier = nil
        managedSite.order = -1
    }
}
