//
// Created by Juliya Smith on 1/4/20.
// Copyright (c) 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


class EntitiesSaver {

    private let stack: PDCoreDataWrapping
    private let logger = CoreDataEntitiesLogger()

    init(_ stack: PDCoreDataWrapping) {
        self.stack = stack
    }

    func saveCreateNewEntity(_ entity: PDEntity) {
        save(entity, from: "Create new \(entity.rawValue)")
    }

    func saveFromPush(_ entity: PDEntity) {
        save(entity, from: "\(entity.rawValue) save")
    }

    func saveFromDelete(_ entity: PDEntity) {
        save(entity, from: "\(entity.rawValue) delete")
    }

    private func save(_ entity: PDEntity, from name: String) {
        logger.logSave(entity)
        stack.save(saverName: name)
    }
}
