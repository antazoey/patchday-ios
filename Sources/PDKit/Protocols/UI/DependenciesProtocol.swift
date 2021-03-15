//
//  DependenciesProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 5/10/20.

import Foundation

public protocol DependenciesProtocol {
    var sdk: PatchDataSDK? { get }
    var tabs: TabReflective? { get set }
    var notifications: NotificationScheduling? { get }
    var nav: NavigationHandling? { get }
    var alerts: AlertProducing? {get }
    var badge: PDBadgeReflective? { get }
    var widget: PDWidgetProtocol? { get }
}
