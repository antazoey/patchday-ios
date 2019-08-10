//
//  EstrogenManaged.swift
//  PDKit
//
//  Created by Juliya Smith on 8/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation

public protocol TimeReleased: Comparable {
    var id: UUID? { get set }
    var date: NSDate? { get set }
    var siteNameBackUp: String? { get set }
    var site: Bodily? { get set }
}
