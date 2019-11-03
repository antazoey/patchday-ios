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
    
    /// The site you applied this hormones to.
    var site: Bodily? { get set }
    
    /// The date you applied this hormone to a site.
    var date: Date { get set }
    
    /// The date that this hormone runs out of juice.
    var expiration: Date? { get }
    
    /// The string representation of the expiration date.
    var expirationString: String { get }
    
    /// Whether it is past this hormone's expiration date.
    var isExpired: Bool { get }
    
    /// Whether the hormone expires between the hours of midnight and 6 am.
    var expiresOvernight: Bool { get }
    
    /// The name of the site that you applied this hormone to.
    var siteName: String { get }
    
    /// For preserving site data in case you delete the related PDSite.
    var siteNameBackUp: String? { get set }
    
    /// If this hormone without a site and date placed.
    var isEmpty: Bool { get }
    
    /// If this hormone is without a site.
    var isCerebral: Bool { get }
    
    /// Sets the date to now.
    func stamp()
}
