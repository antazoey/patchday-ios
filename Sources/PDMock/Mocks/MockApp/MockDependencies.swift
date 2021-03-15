//
//  MockDependencies.swift
//  PDMock
//
//  Created by Juliya Smith on 5/10/20.

import Foundation
import PDKit

public class MockDependencies: DependenciesProtocol {

    public init() {}

    public var sdk: PatchDataSDK? = MockSDK()
    public var tabs: TabReflective? = MockTabs()
    public var notifications: NotificationScheduling? = MockNotifications()
    public var alerts: AlertProducing? = MockAlertFactory()
    public var nav: NavigationHandling? = MockNav()
    public var badge: PDBadgeReflective? = MockBadge()
    public var widget: PDWidgetProtocol? = MockWidget()
}
