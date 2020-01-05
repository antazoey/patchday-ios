//
// Created by Juliya Smith on 1/4/20.
// Copyright (c) 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


class EntitiesSaver {

    private let stack: PDCoreDataDelegate
    private let logger = CoreDataEntitiesLogger()

    init(_ stack: PDCoreDataDelegate) {
        self.stack = stack
    }

    func saveCreateNewEntity(_ entity: PDEntity, id: String) {
        stack.save(saverName: "Create new \(entity.rawValue)")
        logger.logSave(entity, id: id)
    }

    func saveFromPush(_ entity: PDEntity) {
        stack.save(saverName: "\(entity.rawValue) save")
    }

    func saveFromDelete(_ entity: PDEntity) {
        stack.save(saverName: "\(entity.rawValue) delete")
    }
}
