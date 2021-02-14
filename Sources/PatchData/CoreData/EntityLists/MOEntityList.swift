//
//  MOEntityList.swift
//  PatchData
//
//  Created by Juliya Smith on 9/2/20.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

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
