//
//  PDSite.swift
//  PatchData
//
//  Created by Juliya Smith on 9/3/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class PDSite: Bodily, Comparable {
    
    private let site: MOSite
    
    public init(site: MOSite, globalExpirationInterval: ExpirationInterval, de) {
        self.site = site
    }
    
    public var estrogen: [Hormonal] {
        get {
            if let estroSet = site.estrogenRelationship {
                for estro in estroSet {
                    let pdestro = PDEstrogen(estrogen: estro, interval: , deliveryMethod: <#T##DeliveryMethod#>)
                }
            }
        }
    }
    
    /// Set the siteBackUpName in every estrogen.
    public func loadBackupSiteName() {
        if isOccupied(), let estroSet = site.estrogenRelationship {
            for estro in Array(estroSet) {
                let e = estro as! MOEstrogen
                if let n = site.name {
                    e.siteNameBackUp = n
                }
            }
        }
    }
    
    public func string() -> String {
        let n = site.name ?? PDStrings.PlaceholderStrings.new_site
        return "\(site.order + 1). \(n)"
    }
    
    public func decrement() {
        if site.order > 0 {
            site.order -= 1
        }
    }
    
    /// Returns if the the MOSite is occupied by more than one MOEstrogen.
    public func isOccupied(byAtLeast many: Int = 1) -> Bool {
        if let r = site.estrogenRelationship {
            return r.count >= many
        }
        return false
    }
    
    public func reset() {
        site.order = Int16(-1)
        site.name = nil
        site.imageIdentifier = nil
        site.estrogenRelationship = nil
    }
    
    /* Note: In MOSites, we want negative orders and nil orders
     to be at the end of a sort, then negative orders are > positive orders
     and I know that sounds weird, but we are kind of backwards here at PatchDay Inc.
     */
    
    public static func < (lhs: PDSite, rhs: PDSite) -> Bool {
        switch(lhs.siorder, rhs.order) {
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
    
    public static func > (lhs: PDSite, rhs: PDSite) -> Bool {
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
    
    public static func == (lhs: MOSite, rhs: MOSite) -> Bool {
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
    
    public static func != (lhs: MOSite, rhs: MOSite) -> Bool {
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
}
