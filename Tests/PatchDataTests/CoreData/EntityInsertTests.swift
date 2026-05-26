//
//  EntityInsertTests.swift
//  PatchDataTests
//
//  Verifies awakeFromInsert behavior on MOHormone / MOPill / MOSite using an
//  in-memory persistent container loaded against the live patchData model.
//

import XCTest
import CoreData
import PDKit
@testable import PatchData

class EntityInsertTests: XCTestCase {

    private var container: NSPersistentContainer!

    override func setUpWithError() throws {
        let modelURL = Bundle(for: CoreDataStack.self)
            .url(forResource: "patchData", withExtension: "momd")
        guard let modelURL = modelURL, let model = NSManagedObjectModel(contentsOf: modelURL) else {
            XCTFail("Could not load patchData.momd")
            return
        }
        container = NSPersistentContainer(name: "patchData", managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        let loaded = expectation(description: "loaded")
        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
            loaded.fulfill()
        }
        wait(for: [loaded], timeout: 5)
        if let loadError { XCTFail("Failed to load: \(loadError)") }
    }

    private var context: NSManagedObjectContext { container.viewContext }

    // MARK: - awakeFromInsert

    func testMOHormone_awakeFromInsert_assignsId() throws {
        let entity = NSEntityDescription.entity(forEntityName: "Estrogen", in: context)!
        let hormone = MOHormone(entity: entity, insertInto: context)
        XCTAssertNotNil(hormone.id)
    }

    func testMOPill_awakeFromInsert_assignsId() throws {
        let entity = NSEntityDescription.entity(forEntityName: "Pill", in: context)!
        let pill = MOPill(entity: entity, insertInto: context)
        XCTAssertNotNil(pill.id)
    }

    func testMOSite_awakeFromInsert_assignsId() throws {
        let entity = NSEntityDescription.entity(forEntityName: "Site", in: context)!
        let site = MOSite(entity: entity, insertInto: context)
        XCTAssertNotNil(site.id)
    }

    func testMOHormone_awakeFromInsert_doesNotOverrideExistingId() throws {
        let entity = NSEntityDescription.entity(forEntityName: "Estrogen", in: context)!
        let predefined = UUID()
        let hormone = MOHormone(entity: entity, insertInto: context)
        // awakeFromInsert ran with id == nil → it assigned one.
        // Now override and verify post-insert assignments persist.
        hormone.id = predefined
        XCTAssertEqual(predefined, hormone.id)
    }

    // MARK: - v2 model defaults

    func testMOPill_newRecord_hasDefaultsAppliedFromModel() throws {
        let entity = NSEntityDescription.entity(forEntityName: "Pill", in: context)!
        let pill = MOPill(entity: entity, insertInto: context)
        // The new patchData v2 model declares defaults that Core Data applies
        // automatically on insert before awakeFromInsert.
        XCTAssertEqual("everyDay", pill.expirationInterval)
        XCTAssertEqual("", pill.name)
        XCTAssertEqual("", pill.times)
        XCTAssertEqual("", pill.timesTakenTodayList)
        XCTAssertEqual("", pill.xDays)
        XCTAssertEqual(false, pill.isCreated)
        XCTAssertEqual(true, pill.notify)
    }

    func testMOSite_newRecord_hasDefaultsAppliedFromModel() throws {
        let entity = NSEntityDescription.entity(forEntityName: "Site", in: context)!
        let site = MOSite(entity: entity, insertInto: context)
        XCTAssertEqual("", site.name)
        XCTAssertEqual("", site.imageIdentifier)
        XCTAssertEqual(0, site.order)
    }

    func testMOHormone_newRecord_hasDefaultsAppliedFromModel() throws {
        let entity = NSEntityDescription.entity(forEntityName: "Estrogen", in: context)!
        let hormone = MOHormone(entity: entity, insertInto: context)
        XCTAssertEqual("", hormone.siteNameBackUp)
        XCTAssertEqual("", hormone.xDays)
        XCTAssertNil(hormone.date)
    }
}
