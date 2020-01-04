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


public class CoreDataStack: NSObject {

    private static var container: NSPersistentContainer?
    private static let log = PDLog<CoreDataStack>()

    static let persistentContainerKey = "patchData"
    static let testContainerKey = "patchDataTest"  // For experimental purposes
    static let hormoneEntityName = "Hormone"
    static let hormoneProps = ["date", "id", "siteNameBackUp"]
    static let siteEntityName = "Site"
    static let siteProps = ["order", "name"]
    static let pillEntityName = "Pill"
    static let pillProps = ["name", "timesaday", "time1", "time2", "notify", "timesTakenToday", "lastTaken"]
    
    // MARK: - Public
    
    override public var description: String {
        "Implements the Core Data stack"
    }

    // MARK: - Internal

    static var persistentContainer: NSPersistentContainer {
        if let container = container {
            return container
        } else {
            let newContainer = getPersistentContainer(for: persistentContainerKey)
            container = newContainer
            return newContainer
        }
    }

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
        PDEntity.allCases.forEach {e in
            let managedObjects = getManagedObjects(entity: e)
            for obj: NSManagedObject in managedObjects {
                context.delete(obj)
            }
        }
        save(saverName: "Nuke function")
    }
    
    // MARK: - Private
    
    private static func getPersistentContainer(for name: String) -> NSPersistentContainer {
        let container = NSPersistentContainer(name: name)
        container.loadPersistentStores(completionHandler: {
            (storeDescription, error) in
            self.log.info("Loaded persistent store '\(name)' of type \(storeDescription.type)")
            if let error = error as NSError? {
                self.log.error(error)
                fatalError()
            }
        })
        return container
    }
    
    private static func getEntityKey(for entity: PDEntity) -> EntityKey {
        var n: String
        var props: [String]
        switch entity {
        case .hormone:
            n = hormoneEntityName
            props = hormoneProps
        case .pill:
            n = pillEntityName
            props = pillProps
        case .site:
            n = siteEntityName
            props = siteProps
        }
        return EntityKey(type: entity, name: n, props: props)
    }
}

extension NSManagedObject {
    public func name() -> String? {
        objectID.entity.name
    }
}
