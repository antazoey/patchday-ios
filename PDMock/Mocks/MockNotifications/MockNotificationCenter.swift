//
//  MockNotificationCenter.swift
//  PDMock
//
//  Created by Juliya Smith on 4/26/20.
//  Copyright © 2020 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

public class MockNotificationCenter: NSObject, NotificationCenterDelegate {

    public override init() {}

	public var setHormoneChangeUpdateViewsHookCallArgs: [() -> Void] = []
	public func setHormoneChangeUpdateViewsHook(hook: @escaping () -> Void) {
		setHormoneChangeUpdateViewsHookCallArgs.append(hook)
	}

    public var removeNotificationsCallArgs: [[String]] = []
    public var removeNotificationsCallCount: Int {
        removeNotificationsCallArgs.count
    }

    public func removeNotifications(with ids: [String]) {
        removeNotificationsCallArgs.append(ids)
    }

    public func resetMock() {
        removeNotificationsCallArgs = []
    }
}
