//
//  CoreDataStack.swift
//  PatchData
//
//  Created by Juliya Smith on 12/21/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData
import PDKit

class CoreDataStack: NSObject {

    private static var container: NSPersistentContainer?
    private static var log = PDLog<CoreDataStack>()

    static let persistentContainerKey = "patchData"
    static let testContainerKey = "patchDataTest" // For experimental purposes

    static let hormoneProps = ["date", "id", "siteNameBackUp"]
    static let siteProps = ["order", "name", "imageIdentifier"]
    static let pillProps = [
        "id",
        "name",
        "timesaday",
        "time1",
        "time2",
        "notify",
        "timesTakenToday",
        "lastTaken",
        "expirationInterval",
        "times"
    ]

    // MARK: - Public

    override public var description: String {
        "Implements the Core Data stack."
    }

    // MARK: - Internal

    static var persistentContainer: NSPersistentContainer = {
        if container == nil {
            container = NSPersistentContainer(name: persistentContainerKey)
        }
        let container = CoreDataStack.container!
        container.loadPersistentStores(completionHandler: {
            (_, error) in
            if let error = error as NSError? {
	            fatalError()
            }
        })
        return container
    }()

    static var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    static func save(saverName: String) {
        if context.hasChanges {
            do {
	            try context.save()
            } catch {
	            self.log.error("Failed saving core data")
	            return
            }
        } else {
            log.info("\(saverName) - save was called without changes")
        }
    }

    /// Insert a Core Data entity into the view context
    static func insertIntoContext(_ entity: PDEntity) -> NSManagedObject? {
        NSEntityDescription.insertNewObject(forEntityName: entity.rawValue, into: context)
    }

    static func getManagedObjects(entity: PDEntity) -> [NSManagedObject] {
        let keys = getEntityKey(for: entity)
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: keys.name)
        fetchRequest.propertiesToFetch = keys.props
        do {
            return try context.fetch(fetchRequest)
        } catch {
            log.error("Data fetch request failed for entity \(entity.rawValue)")
        }
        return []
    }

    /// Deletes all the managed objects in the context
    static func nuke() {
        PDEntity.allCases.forEach { e in
            let managedObjects = getManagedObjects(entity: e)
            for obj: NSManagedObject in managedObjects {
	            context.delete(obj)
            }
        }
        save(saverName: "Nuke function")
    }

    // MARK: - Private

    private static func getEntityKey(for entity: PDEntity) -> EntityKey {
        var props: [String]
        switch entity {
            case .hormone: props = hormoneProps
            case .pill: props = pillProps
            case .site: props = siteProps
        }
        return EntityKey(type: entity, name: entity.rawValue, props: props)
    }
}

extension NSManagedObject {
    public func name() -> String? {
        objectID.entity.name
    }
}
