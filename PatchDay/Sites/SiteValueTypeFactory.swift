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
        let cellEditingState = SiteValueTypeFactory.createEditingState(sitesViewController)
        return BarItemInitializationProperties(
            sitesViewController: sitesViewController,
            tableActionState: cellEditingState,
            oppositeActionTitle: createOppositeActionTitle(cellEditingState),
            reset: reset,
            insert: insert
        )
    }

    private static func createEditingState(_ sitesViewController: UIViewController) -> SiteTableActionState {
        if let items = sitesViewController.navigationItem.rightBarButtonItems {
            switch items[1].title {
            case ActionStrings.Edit: return .Editing
            case ActionStrings.Done: return .Reading
            default: break
            }
        }
        return .Unknown
    }

    private static func createOppositeActionTitle(_ cellEditingState: SiteTableActionState) -> String {
        cellEditingState == .Editing ? ActionStrings.Done : ActionStrings.Edit
    }
}
