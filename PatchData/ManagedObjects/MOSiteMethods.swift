//
//  MOSiteMethods.swift
//  PDKit
//
//  Created by Juliya Smith on 7/13/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//
//

import Foundation
import CoreData
import PDKit

extension MOSite {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MOSite> {
        return NSFetchRequest<MOSite>(entityName: "Site")
    }

    @NSManaged public var estrogenRelationship: NSSet?
    @NSManaged internal var imageIdentifier: String?
    @NSManaged internal var name: String?
    @NSManaged internal var order: Int16
}

// MARK: Generated accessors for estrogenRelationship
extension MOSite {

    @objc(addEstrogenRelationshipObject:)
    @NSManaged public func addToEstrogenRelationship(_ value: MOEstrogen)

    @objc(removeEstrogenRelationshipObject:)
    @NSManaged public func removeFromEstrogenRelationship(_ value: MOEstrogen)

    @objc(addEstrogenRelationship:)
    @NSManaged public func addToEstrogenRelationship(_ values: NSSet)

    @objc(removeEstrogenRelationship:)
    @NSManaged public func removeFromEstrogenRelationship(_ values: NSSet)

    public func isOccupied() -> Bool {
        if let r = estrogenRelationship {
            return r.count > 0
        }
        return false
    }
    
    /// Returns if the the MOSite is occupied by more than one MOEstrogen.
    public func isOccupiedByMany() -> Bool {
        if let r = estrogenRelationship {
            return r.count > 1
        }
        return false
    }

    public func setOrder(to order: Int16) {
        self.order = order
    }

    public func setImageIdentifier(to imgID: String) {
        self.imageIdentifier = imgID
    }

    public func setName(to name: SiteName) {
        self.name = name as String
    }

    public func getOrder() -> Int16 {
        return order
    }

    public func getName() -> SiteName? {
        return name as SiteName?
    }

    public func getImageIdentifer() -> SiteName? {
        return imageIdentifier as SiteName?
    }

    public func toString() -> String {
        let n = (name != nil) ? name! : PDStrings.PlaceholderStrings.new_site
        return "\(order + 1). \(n)"
    }

    public func decrement() {
        if order > 0 {
            order -= 1
        }
    }

    public func reset() {
        order = Int16(-1)
        name = nil
        imageIdentifier = nil
        estrogenRelationship = nil
    }
}
