//
//  DependenciesProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 5/10/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation

public protocol DependenciesProtocol {
	var sdk: PatchDataSDK? { get }
	var tabs: TabReflective? { get set }
	var notifications: NotificationScheduling? { get }
	var alerts: AlertDispatching? { get }
	var nav: NavigationHandling? { get }
	var badge: PDBadgeDelegate? { get }
}
