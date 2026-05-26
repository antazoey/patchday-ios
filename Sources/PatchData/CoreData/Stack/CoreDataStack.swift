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
        description.url = resolvedStoreURL()
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
    ///
    /// Safety guarantees:
    ///   - If migration fails for any reason, the flag is NOT set and the
    ///     container will fall back to loading the sandbox store
    ///     (`resolvedStoreURL()`), so the user's data remains accessible.
    ///   - The sandbox files are NOT deleted after a successful migration —
    ///     they remain as a permanent fallback in case the App Group store
    ///     ever becomes inaccessible (e.g., revoked entitlements).
    ///   - The destination store is verified by re-opening it before the
    ///     flag is set.
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
            // Fresh install — nothing to migrate.
            defaults.set(true, forKey: PDLocalSettingsKey.didMigrateStoreToAppGroup.rawValue)
            return
        }
        if oldURL.path == newURL.path {
            // App Group container isn't available (mis-provisioned build).
            // `appGroupStoreURL()` already fell back to the sandbox path.
            // No migration needed — keep using the sandbox store in place.
            defaults.set(true, forKey: PDLocalSettingsKey.didMigrateStoreToAppGroup.rawValue)
            return
        }
        if fm.fileExists(atPath: newURL.path) {
            // App-group store already populated by a prior partial run —
            // trust it and don't overwrite. Flag flip records this.
            defaults.set(true, forKey: PDLocalSettingsKey.didMigrateStoreToAppGroup.rawValue)
            return
        }

        do {
            let parentDir = newURL.deletingLastPathComponent()
            if !fm.fileExists(atPath: parentDir.path) {
                try fm.createDirectory(at: parentDir, withIntermediateDirectories: true)
            }

            guard let model = NSManagedObjectModel.mergedModel(
                from: [Bundle(for: CoreDataStack.self)]
            ) else {
                log.error("Store migration aborted: couldn't load merged managed object model.")
                return
            }
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
            let store = try coordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: oldURL,
                options: nil
            )
            let beforeCounts = countEntities(in: coordinator, model: model)
            _ = try coordinator.migratePersistentStore(
                store,
                to: newURL,
                options: nil,
                withType: NSSQLiteStoreType
            )

            // Verify the migrated store opens and has matching record counts.
            let verifyCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
            _ = try verifyCoordinator.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: newURL,
                options: nil
            )
            let afterCounts = countEntities(in: verifyCoordinator, model: model)
            guard afterCounts == beforeCounts else {
                log.error(
                    "Store migration verification failed: before=\(beforeCounts) after=\(afterCounts)"
                )
                // Remove the bad destination so retry next launch starts clean.
                try? fm.removeItem(at: newURL)
                return
            }

            defaults.set(true, forKey: PDLocalSettingsKey.didMigrateStoreToAppGroup.rawValue)
            log.info(
                "Migrated Core Data store to App Group container. counts=\(afterCounts). " +
                "Sandbox store retained at \(oldURL.path) as backup."
            )
        } catch {
            log.error("Store-to-App-Group migration failed", error)
            // Don't set the flag, don't touch sandbox — we'll retry next
            // launch. resolvedStoreURL() will return the sandbox URL in the
            // meantime so the user keeps using their existing data.
        }
    }

    /// Returns the store URL the container should load. Falls back to the
    /// sandbox URL if the App Group migration has not been confirmed —
    /// otherwise a partial / failed migration would make the user's data
    /// look gone (the container would create a fresh empty store at the
    /// App Group path).
    static func resolvedStoreURL() -> URL {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: PDLocalSettingsKey.didMigrateStoreToAppGroup.rawValue) {
            return appGroupStoreURL()
        }
        if let sandbox = sandboxStoreURL(),
            FileManager.default.fileExists(atPath: sandbox.path) {
            return sandbox
        }
        return appGroupStoreURL()
    }

    private static func countEntities(
        in coordinator: NSPersistentStoreCoordinator,
        model: NSManagedObjectModel
    ) -> [String: Int] {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        var counts: [String: Int] = [:]
        for entity in model.entities {
            guard let name = entity.name else { continue }
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: name)
            counts[name] = (try? context.count(for: request)) ?? -1
        }
        return counts
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
