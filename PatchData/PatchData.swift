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

    // Core Data stack
    internal static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: PDStrings.CoreDataKeys.persistantContainer_key)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                PatchDataAlert.alertForPersistentStoreLoadError(error: error)
            }
        })
        return container
    }()
    
    /// Saves the all changed data in the persistentContainer.
    public static func save() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                PatchDataAlert.alertForCoreDataError()
            }
        }
    }
    
    public static func getContext() -> NSManagedObjectContext {
        return persistentContainer.viewContext
    }
}
