//
//  BodilyManager.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol Bodily: PDPbjectifiable {
    
    /// The hormones in the schedule that you have applied to this site.
    var hormones: [Hormonal] { get }
    
    /// The ID associated with the image representation of this site.
    var imageId: String { get set }
    
    /// The name of the body part that this site represents.
    var name: SiteName { get set }
    
    /// The order when this site will be suggested next.
    var order: Int { get set }
    
    /// Whether any hormones in the schedule have been applied to this site.
    var isOccupied: Bool { get }
    
    /// Whether there are the specified amount of hormones here or not.
    func isOccupied(byAtLeast many: Int) -> Bool
    
    /// Whether the system considers this site to be equal to the given other site.
    func isEqualTo(_ otherSite: Bodily) -> Bool
}
