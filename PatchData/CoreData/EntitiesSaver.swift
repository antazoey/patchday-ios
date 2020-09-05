//
// Created by Juliya Smith on 1/4/20.
// Copyright (c) 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

class EntitiesSaver {

    private let stack: PDCoreDataWrapping
    private let entity: PDEntity
    private var logger: EntitiesLogger

    init(_ stack: PDCoreDataWrapping, _ entity: PDEntity) {
        self.stack = stack
        self.entity = entity
        self.logger = EntitiesLogger(entity: entity)
    }

    func saveCreateNewEntity() {
        save(from: "Create new \(self.entity.rawValue)")
    }

    func saveFromPush() {
        save(from: "\(self.entity.rawValue) save")
    }

    func saveFromDelete() {
        save(from: "\(self.entity.rawValue) delete")
    }

    func saveFromMigration() {
        save(from: "\(self.entity.rawValue) migrations")
    }

    private func save(from name: String) {
        logger.logSave()
        stack.save(saverName: name)
    }
}
