//
// Created by Juliya Smith on 12/9/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class SiteValueTypeFactory {

    static func createBarItemInitProps(
        _ reset: Selector,
        _ insert: Selector,
        _ sitesViewController: UIViewController
    ) -> BarItemInitializationProperties {
        let cellEditingState = SiteValueTypeFactory.createIsEditing(sitesViewController)
        return BarItemInitializationProperties(
            sitesViewController: sitesViewController,
            isEditing: cellEditingState,
            oppositeActionTitle: createOppositeActionTitle(cellEditingState),
            reset: reset,
            insert: insert
        )
    }

    private static func createIsEditing(_ sitesViewController: UIViewController) -> Bool {
        if let items = sitesViewController.navigationItem.rightBarButtonItems, items.count > 1 {
            return items[1].title == ActionStrings.Edit
        }
        return false
    }

    private static func createOppositeActionTitle(_ isEditing: Bool) -> String {
        isEditing ? ActionStrings.Done : ActionStrings.Edit
    }
}
