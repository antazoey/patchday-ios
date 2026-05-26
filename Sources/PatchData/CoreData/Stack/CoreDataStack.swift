//
//  CoreDataStack.swift
//  PatchData
//
//  Created by Juliya Smith on 12/21/18.
//

import Foundation
import CoreData
import PDKit

class CoreDataStack: NSObject {

    private static var log = PDLog<CoreDataStack>()

    static let persistentContainerKey = "patchData"
    static let cloudKitContainerIdentifier = "iCloud.Yingthi.PatchDay"

    static let hormoneProps = ["date", "id", "siteNameBackUp", "xDays"]
    static let siteProps = ["order", "name", "imageIdentifier"]
    static let pillProps = [
        "id",
        "name",
        "timesaday",
        "time1",
        "time2",
        "times",
        "notify",
        "timesTakenToday",
        "lastTaken",
        "expirationInterval",
        "xDays",
        "timesTakenTodayList"
    ]

    struct EntityKey {
        public var type: PDEntity
        public var name: String
        public var props: [String]
    }

    override public var description: String {
        "Implements the Core Data stack."
    }

    /// Last store-load error. UI can surface this.
    static private(set) var loadError: Error?

    /// Read once at launch. Toggling at runtime requires a relaunch.
    private static let isCloudSyncEnabledAtLaunch: Bool =
        UserDefaults.standard.bool(forKey: PDLocalSettingsKey.iCloudSyncEnabled.rawValue)

    // MARK: - Container

    static var persistentContainer: NSPersistentCloudKitContainer = {
        migrateStoreToAppGroupIfNeeded()
        let container = NSPersistentCloudKitContainer(name: persistentContainerKey)
        let description = container.persistentStoreDescriptions.first!
        description.url = appGroupStoreURL()
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        // History tracking is required for NSPersistentCloudKitContainer and
        // also enables observing remote-change notifications. Leave it on
        // even when sync is off so toggling doesn't require a fresh store.
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(
            true as NSNumber,
            forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey
        )

        if isCloudSyncEnabledAtLaunch {
            description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
                containerIdentifier: cloudKitContainerIdentifier
            )
        } else {
            description.cloudKitContainerOptions = nil
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                CoreDataStack.loadError = error
                log.error(
                    "Core Data store failed to load: \(error.localizedDescription) — \(error.userInfo)"
                )
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()

    static var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    // MARK: - Save / fetch / nuke (unchanged)

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

    static func nuke() {
        PDEntity.allCases.forEach { e in
            let managedObjects = getManagedObjects(entity: e)
            for obj: NSManagedObject in managedObjects {
                context.delete(obj)
            }
        }
        save(saverName: "Nuke function")
    }

    // MARK: - Store relocation to App Group

    /// One-shot migration: SQLite store living in the app sandbox needs to
    /// move to the App Group container so the path is the same regardless of
    /// whether iCloud is on, and a future widget Core Data integration can
    /// share it. Idempotent — guarded by `didMigrateStoreToAppGroup`.
    static func migrateStoreToAppGroupIfNeeded() {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: PDLocalSettingsKey.didMigrateStoreToAppGroup.rawValue) {
            return
        }

        guard let oldURL = sandboxStoreURL() else {
            defaults.set(true, forKey: PDLocalSettingsKey.didMigrateStoreToAppGroup.rawValue)
            return
        }
        let newURL = appGroupStoreURL()

        let fm = FileManager.default
        guard fm.fileExists(atPath: oldURL.path) else {
            // Nothing to migrate (fresh install).
            defaults.set(true, forKey: PDLocalSettingsKey.didMigrateStoreToAppGroup.rawValue)
            return
        }
        if fm.fileExists(atPath: newURL.path) {
            // App-group store already populated — don't overwrite it.
            defaults.set(true, forKey: PDLocalSettingsKey.didMigrateStoreToAppGroup.rawValue)
            return
        }

        do {
            // Ensure the destination directory exists.
            let parentDir = newURL.deletingLastPathComponent()
            if !fm.fileExists(atPath: parentDir.path) {
                try fm.createDirectory(at: parentDir, withIntermediateDirectories: true)
            }

            // Use the coordinator's migrate API so WAL / SHM sidecars are moved.
            let model = NSManagedObjectModel.mergedModel(from: [Bundle(for: CoreDataStack.self)])!
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
            let store = try coordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: oldURL,
                options: nil
            )
            _ = try coordinator.migratePersistentStore(
                store,
                to: newURL,
                options: nil,
                withType: NSSQLiteStoreType
            )
            // Remove the legacy files explicitly (the coordinator may leave them).
            let legacyFiles = [
                oldURL.path,
                oldURL.path + "-wal",
                oldURL.path + "-shm"
            ]
            for path in legacyFiles where fm.fileExists(atPath: path) {
                try? fm.removeItem(atPath: path)
            }
            defaults.set(true, forKey: PDLocalSettingsKey.didMigrateStoreToAppGroup.rawValue)
            log.info("Migrated Core Data store from sandbox to App Group container.")
        } catch {
            log.error("Store-to-App-Group migration failed", error)
            // Don't set the flag — we'll try again next launch.
        }
    }

    static func appGroupStoreURL() -> URL {
        guard let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: PDSharedDataGroupName
        ) else {
            // Fallback to sandbox if the App Group isn't accessible
            // (mis-provisioned build); never crash.
            return NSPersistentContainer.defaultDirectoryURL()
                .appendingPathComponent("\(persistentContainerKey).sqlite")
        }
        return groupURL.appendingPathComponent("\(persistentContainerKey).sqlite")
    }

    private static func sandboxStoreURL() -> URL? {
        NSPersistentContainer.defaultDirectoryURL()
            .appendingPathComponent("\(persistentContainerKey).sqlite")
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
