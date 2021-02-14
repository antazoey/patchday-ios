//
//  MOEntityList.swift
//  PatchData
//
//  Created by Juliya Smith on 9/2/20.

import Foundation

class MOEntityList {

    let entityType: PDEntity
    let coreDataStack: PDCoreDataWrapping
    let logger: EntitiesLogger
    var initialized = false
    let saver: EntitiesSaver

    init(
        _ coreDataStack: PDCoreDataWrapping,
        _ entityType: PDEntity
    ) {
        self.coreDataStack = coreDataStack
        self.entityType = entityType
        self.saver = EntitiesSaver(coreDataStack, entityType)
        self.logger = EntitiesLogger(entity: entityType)
    }
}
