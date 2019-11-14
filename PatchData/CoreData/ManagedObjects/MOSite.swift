//
//  MOSite.swift
//  PDkit
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
    
    @NSManaged public var hormoneRelationship: NSSet?
    @NSManaged public var imageIdentifier: String?
    @NSManaged public var name: String?
    @NSManaged public var order: Int16
    
    @objc(addHormoneRelationshipObject:)
    @NSManaged public func addToHormoneRelationship(_ value: MOHormone)
    
    @objc(removeHormoneRelationshipObject:)
    @NSManaged public func removeFromHormoneRelationship(_ value: MOHormone)
    
    @objc(addHormoneRelationship:)
    @NSManaged public func addToHormoneRelationship(_ values: NSSet)
    
    @objc(removeHormoneRelationship:)
    @NSManaged public func removeFromHormoneRelationship(_ values: NSSet)
}
