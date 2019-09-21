//
//  PDScheduling.swift
//  PDKit
//
//  Created by Juliya Smith on 9/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol PatchDataDelegate {
    var defaults: PDDefaultManaging { get }
    var estrogens: EstrogenScheduling { get }
    var sites: EstrogenSiteScheduling { get }
    var pills: PDPillScheduling { get }
    var state: PDStateManaging { get }
    var deliveryMethod: DeliveryMethod { get set }
    var totalDue: Int { get }
}
