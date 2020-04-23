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


class CoreDataStackWrapper: PDCoreDataWrapping {

	private lazy var log = PDLog<CoreDataStackWrapper>()

	func save(saverName: String) {
		CoreDataStack.save(saverName: saverName)
	}

	func getManagedObjects(entity: PDEntity) -> [Any]? {
		CoreDataStack.getManagedObjects(entity: entity)
	}

	func insert(_ entity: PDEntity) -> Any? {
		CoreDataStack.insertIntoContext(entity)
	}

	func tryDelete(_ managedObject: Any) {
		if let mo = managedObject as? NSManagedObject {
			CoreDataStack.context.delete(mo)
			return
		}
		log.error("Tried to delete non-managed type \(type(of: managedObject))")
	}

	func nuke() {
		log.warn("Nuke called - purging all data")
		CoreDataStack.nuke()
	}
}
