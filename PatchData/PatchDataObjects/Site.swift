//
//  Site.swift
//  PatchData
//
//  Created by Juliya Smith on 9/3/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


public class Site: PDObject, Bodily, Comparable {

    private let expirationInterval: ExpirationIntervalUD
    private let deliveryMethod: DeliveryMethod
    
    private var moSite: MOSite {
        self.mo as! MOSite
    }
    
    public init(moSite: MOSite, expirationInterval: ExpirationIntervalUD, deliveryMethod: DeliveryMethod) {
        self.expirationInterval = expirationInterval
        self.deliveryMethod = deliveryMethod
        super.init(mo: moSite)
    }

    public override func delete() {
        super.delete()
        pushBackupSiteNameToHormones()
    }
    
    public var hormones: [Hormonal] {
        var hormones: [Hormonal] = []
        if let moneSet = moSite.hormoneRelationship {
            for mone in moneSet {
                let pdEstro = Hormone(
                    hormone: mone as! MOHormone,
                    interval: expirationInterval,
                    deliveryMethod: deliveryMethod
                )
                hormones.append(pdEstro)
            }
        }
        return hormones
    }
    
    public var imageId: String {
        get { moSite.imageIdentifier ?? "" }
        set { moSite.imageIdentifier = newValue }
    }
    
    public var name: SiteName {
        get { moSite.name ?? "" }
        set { moSite.name = newValue }
    }
    
    public var order: Int {
        get { return Int(moSite.order) }
        set {
            if newValue >= 0 {
                moSite.order = Int16(newValue)
            }
        }
    }
    
    public var isOccupied: Bool { return isOccupied() }

    public func isOccupied(byAtLeast many: Int = 1) -> Bool {
        if let r = moSite.hormoneRelationship {
            return r.count >= many
        }
        return false
    }
    
    public func reset() {
        moSite.order = Int16(-1)
        moSite.name = nil
        moSite.imageIdentifier = nil
        moSite.hormoneRelationship = nil
    }
    
    public func isEqualTo(_ otherSite: Bodily) -> Bool {
        name == otherSite.name && order == otherSite.order
    }
    
    /* Note: In MOSites, we want negative orders and nil orders
     to be at the end of a sort, then negative orders are > positive orders
     and I know that sounds weird, but we are kind of backwards here at PatchDay Inc.
     */
    
    public static func < (lhs: Site, rhs: Site) -> Bool {
        switch(lhs.order, rhs.order) {
        // both not set
        case (nil, nil) : return false
        case (let neg1, let neg2) where neg1 < 0 && neg2 < 0 : return false
        case (nil, let neg) where neg < 0 : return false
        case (let neg, nil) where neg < 0 : return false
            
        // left field not set
        case (nil, _) : return false
        case (let neg, _) where neg < 0 : return false
            
        // right field not set
        case (_, nil) : return true
        case (_, let neg) where neg < 0 : return true
            
        // both fields sets
        default : return lhs.order < rhs.order
        }
    }
    
    public static func > (lhs: Site, rhs: Site) -> Bool {
        switch(lhs.order, rhs.order) {
        // both not set
        case (nil, nil) : return false
        case (let neg1, let neg2) where neg1 < 0 && neg2 < 0 : return false
        case (nil, let neg) where neg < 0 : return false
        case (let neg, nil) where neg < 0 : return false
            
        // left field not set
        case (nil, _) : return true
        case (let neg, _) where neg < 0 : return true
            
        // right field not set
        case (_, nil) : return false
        case (_, let neg) where neg < 0 : return false
            
        // both fields sets
        default : return lhs.order > rhs.order
        }
    }
    
    public static func == (lhs: Site, rhs: Site) -> Bool {
        switch(lhs.order, rhs.order) {
        // both not set
        case (nil, nil) : return true
        case (let neg1, let neg2) where neg1 < 0 && neg2 < 0 : return true
        case (nil, let neg) where neg < 0 : return true
        case (let neg, nil) where neg < 0 : return true
            
        // left field not set
        case (nil, _) : return false
        case (let neg, _) where neg < 0 : return false
            
        // right field not set
        case (_, nil) : return false
        case (_, let neg) where neg < 0 : return false
            
        // both fields sets
        default : return lhs.order == rhs.order
        }
    }
    
    public static func != (lhs: Site, rhs: Site) -> Bool {
        switch(lhs.order, rhs.order) {
        // both not set
        case (nil, nil) : return false
        case (let neg1, let neg2) where neg1 < 0 && neg2 < 0 : return false
        case (nil, let neg) where neg < 0 : return false
        case (let neg, nil) where neg < 0 : return false
            
        // left field not set
        case (nil, _) : return true
        case (let neg, _) where neg < 0 : return true
            
        // right field not set
        case (_, nil) : return true
        case (_, let neg) where neg < 0 : return true
            
        // both fields sets
        default : return lhs.order != rhs.order
        }
    }

    private func pushBackupSiteNameToHormones() {
        if isOccupied, let moneData = moSite.hormoneRelationship {
            let mones = Array(moneData)
            for mone in mones {
                if let mo = mone as? MOHormone {
                    mo.siteNameBackUp = moSite.name
                }
            }
        }
    }
}
