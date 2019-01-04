//
//  PatchData.swift
//  PatchData
//
//  Created by Juliya Smith on 12/21/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import Foundation
import CoreData
import PDKit

public class PatchData: NSObject {
    
    internal enum PDEntity: String {
        case estrogen = "Estrogen"
        case pill = "Pill"
        case site = "Site"
    }
    
    internal struct EntityKey {
        public var type: PDEntity = .estrogen
        public var name: String = ""
        public var props: [String] = []
    }

    // Core Data stack
    internal static var persistentContainer: NSPersistentContainer = {
        let conkey = PDStrings.CoreDataKeys.persistantContainer_key
        let container = NSPersistentContainer(name: conkey)
        container.loadPersistentStores(completionHandler: {
            (storeDescription, error) in
            if let error = error as NSError? {
                PatchDataAlert.alertForPersistentStoreLoadError(error: error)
            }
        })
        return container
    }()
    
    /// Saves the all changed data in the persistentContainer.
    internal static func save() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                PatchDataAlert.alertForCoreDataError()
            }
        }
    }
    
    /// Insert a Core Data entity into the view context
    internal static func insert(_ entity: String) -> NSManagedObject? {
        return NSEntityDescription.insertNewObject(forEntityName: entity,
                                                   into: getContext());
    }
    
    /// Get the current view context
    internal static func getContext() -> NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    internal static func loadMOs(for entity: PDEntity) -> [NSManagedObject]? {
        let keys = PatchData.entityKey(for: entity)
        typealias MOFetch = NSFetchRequest<NSManagedObject>
        let fetchRequest = MOFetch(entityName: keys.name)
        fetchRequest.propertiesToFetch = keys.props
        do {
            // Load user data if it exists
            let context = PatchData.getContext()
            let mos = try context.fetch(fetchRequest)
            if mos.count > 0 {
                return mos
            }
        } catch {
            print("Data Fetch Request Failed")
        }
        return nil
    }
    
    private static func entityKey(for entity: PDEntity) -> EntityKey {
        typealias data = PDStrings.CoreDataKeys
        var n: String
        var props: [String]
        switch entity {
        case .estrogen:
            n = data.estrogenEntityName
            props = data.estrogenProps
        case .pill:
            n = data.pillEntityName
            props = data.pillProps
        case .site:
            n = data.siteEntityName
            props = data.siteProps
        }
        return EntityKey(type: entity, name: n, props: props)
    }
}

extension NSManagedObject {
    public func name() -> String? {
        return objectID.entity.name
    }
}
