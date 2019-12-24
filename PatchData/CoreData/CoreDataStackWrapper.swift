//
//  CoreDataWrapper.swift
//  PatchData
//
//  Created by Juliya Smith on 9/17/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit
import CoreData


class CoreDataStackWrapper: PDCoreDataDelegate {

    func save() {
        CoreDataStack.save()
    }

    func getManagedObjects(entity: PDEntity) -> [Any]? {
        CoreDataStack.getManagedObjects(entity: entity)
    }

    func insert(_ entity: PDEntity) -> Any? {
        CoreDataStack.insert(entity)
    }

    func nuke() {
        CoreDataStack.nuke()
    }
}
