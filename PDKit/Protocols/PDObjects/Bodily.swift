//
//  BodilyManager.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol Bodily: PDObjectified {
    var id: UUID { get }
    
    /// The hormones in the schedule that you have applied to this site.
    var hormoneIds: [UUID] { get }

    /// The number of hormones on this site.
    var hormoneCount: Int { get }
    
    /// The ID associated with the image representation of this site.
    var imageId: String { get set }
    
    /// The name of the body part that this site represents.
    var name: SiteName { get set }
    
    /// The order when this site will be suggested next.
    var order: Int { get set }
}
