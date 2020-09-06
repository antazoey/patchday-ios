//
// Created by Juliya Smith on 1/4/20.
// Copyright (c) 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class EntitiesLogger {

    private lazy var log = PDLog<MOEntities>()

    private let entity: PDEntity

    init(entity: PDEntity) {
        self.entity = entity
    }

    func logSites(_ siteMOs: [MOSite]) {
        if siteMOs.count == 0 {
            log.warn("There are no managed sites in the current context")
            return
        }
        for site in siteMOs {
            log.info("MOSite. ID=\(site.id?.uuidString ?? "nil"), Name=\(site.name ?? "nil"), Order=\(site.order)")
        }
    }

    func logPush() {
        log.info("Pushing \(self.entity.rawValue) data in preparation to be saved")
    }

    func logEntityCount(_ count: Int) {
        log.info("There are \(count) entities of type \(self.entity.rawValue) in Core Data")
    }

    func logCreate(id: String) {
        log.info("Creating new managed \(self.entity.rawValue) with ID \(id)")
    }

    func logRelateSiteToHormone(siteId: UUID, hormoneId: UUID) {
        log.info("Relating site \(siteId) to hormone \(hormoneId).")
    }

    func logSave() {
        log.info("Saving \(self.entity.rawValue)s changes")
    }

    func warnForNonExistence(id: String) {
        log.warn("No managed \(self.entity.rawValue) exists for ID \(id)")
    }

    func warnForEmptyPush() {
        log.warn("Attempted to push \(self.entity.rawValue) data without any data")
    }

    func errorOnCreation() {
        log.error("Failed creating new \(self.entity.rawValue)")
    }

    func errorOnLoad() {
        log.error("Failed to load \(self.entity.rawValue)s from Core Data")
    }

    func errorOnMissingId() {
        log.error("There exists a \(self.entity.rawValue) that is missing an ID.")
    }

    func logPillMigration() {
        log.info("Migrating pill times to comma-seperated string...")
    }
}
