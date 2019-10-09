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
    var date: Date { get set }
    var expiration: Date? { get }
    var expirationString: String { get }
    var siteName: String { get }
    var siteNameBackUp: String? { get set }
    var isExpired: Bool { get }
    var isEmpty: Bool { get }
    var isCerebral: Bool { get }
    var site: Bodily? { get set }
    func stamp()
}
