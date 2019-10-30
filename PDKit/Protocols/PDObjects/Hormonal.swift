//
//  EstrogenManaged.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol Hormonal: PDPbjectifiable {
    var id: UUID { get set }
    
    /// The related site placed on / in.
    var site: Bodily? { get set }
    
    /// When placed
    var date: Date { get set }
    
    /// When to re-dose
    var expiration: Date? { get }
    
    /// The string representation of when to re-dose.
    var expirationString: String { get }
    
    /// If it is past time to re-dose.
    var isExpired: Bool { get }
    
    /// The name of the site placed on / in.
    var siteName: String { get }
    
    /// For preserving site data in case you delete the related PDSite.
    var siteNameBackUp: String? { get set }
    
    /// If is unscheduled and unplaced.
    var isEmpty: Bool { get }
    
    /// If unplaced.
    var isCerebral: Bool { get }
    
    /// Set date placed to now.
    func stamp()
}
