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
    
    @NSManaged public var estrogenRelationship: NSSet?
    @NSManaged public var imageIdentifier: String?
    @NSManaged public var name: String?
    @NSManaged public var order: Int16
    
    @objc(addEstrogenRelationshipObject:)
    @NSManaged public func addToEstrogenRelationship(_ value: MOEstrogen)
    
    @objc(removeEstrogenRelationshipObject:)
    @NSManaged public func removeFromEstrogenRelationship(_ value: MOEstrogen)
    
    @objc(addEstrogenRelationship:)
    @NSManaged public func addToEstrogenRelationship(_ values: NSSet)
    
    @objc(removeEstrogenRelationship:)
    @NSManaged public func removeFromEstrogenRelationship(_ values: NSSet)
}
