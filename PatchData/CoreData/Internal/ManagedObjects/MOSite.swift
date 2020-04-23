//
//  MOSite.swift
//  PatchData
//
//  Created by Juliya Smith on 6/14/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//
//

import Foundation
import CoreData
import PDKit


@objc(MOSite)
public class MOSite: NSManagedObject {

	@NSManaged var id: UUID?
	@NSManaged var hormoneRelationship: NSSet?
	@NSManaged var imageIdentifier: String?
	@NSManaged var name: String?
	@NSManaged var order: Int16

	@objc(addHormoneRelationshipObject:)
	@NSManaged func addToHormoneRelationship(_ value: MOHormone)

	@objc(removeHormoneRelationshipObject:)
	@NSManaged func removeFromHormoneRelationship(_ value: MOHormone)

	@objc(addHormoneRelationship:)
	@NSManaged func addToHormoneRelationship(_ values: NSSet)

	@objc(removeHormoneRelationship:)
	@NSManaged func removeFromHormoneRelationship(_ values: NSSet)
}
