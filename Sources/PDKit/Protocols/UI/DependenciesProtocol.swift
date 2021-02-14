//
//  DependenciesProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 5/10/20.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public protocol DependenciesProtocol {
    var sdk: PatchDataSDK? { get }
    var tabs: TabReflective? { get set }
    var notifications: NotificationScheduling? { get }
    var nav: NavigationHandling? { get }
    var alerts: AlertProducing? {get }
    var badge: PDBadgeReflective? { get }
}
