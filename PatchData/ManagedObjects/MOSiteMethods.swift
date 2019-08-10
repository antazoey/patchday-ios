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

extension MOSite: Bodily {

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
    
    /// Set the siteBackUpName in every estrogen.
    public func loadBackupSiteName() {
        if isOccupied(),
            let estroSet = estrogenRelationship {
            for estro in Array(estroSet) {
                let e = estro as! MOEstrogen
                if let n = name {
                    e.setSiteBackup(to: n)
                }
            }
        }
    }
    
    public func string() -> String {
        let n = (name != nil) ? name! : PDStrings.PlaceholderStrings.new_site
        return "\(order + 1). \(n)"
    }
    
    public func decrement() {
        if order > 0 {
            order -= 1
        }
    }
    
    /// Returns if the the MOSite is occupied by more than one MOEstrogen.
    public func isOccupied(byAtLeast many: Int = 1) -> Bool {
        if let r = estrogenRelationship {
            return r.count >= many
        }
        return false
    }
    
    public func reset() {
        order = Int16(-1)
        name = nil
        imageIdentifier = nil
        estrogenRelationship = nil
    }
}
