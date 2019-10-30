//
//  BodilyManager.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol Bodily: PDPbjectifiable {
    
    /// The hormones you currently have here.
    var hormones: [Hormonal] { get }
    
    /// The ID associated with the image representation.
    var imageId: String { get set }
    
    /// The name of the body part.
    var name: SiteName { get set }
    
    /// The order when suggested next.
    var order: Int { get set }
    
    /// Whether there are hormones here or not.
    var isOccupied: Bool { get }
    
    /// Whether there are the specified amount of hormones here or not.
    func isOccupied(byAtLeast many: Int) -> Bool
}
