//
// Created by Juliya Smith on 1/5/20.
// Copyright (c) 2021 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit

extension UINavigationController {

    func goToHormoneDetails(_ index: Index, _ source: UIViewController) {
        if let viewController = HormoneDetailViewController.create(source, index) {
            pushViewController(viewController, animated: true)
        } else {
            errorOnViewControllerCreationFailure(name: "Hormone Details")
        }
    }

    func goToPillDetails(_ index: Index, _ source: UIViewController) {
        if let viewController = PillDetailViewController.createPillDetailVC(source, index) {
            pushViewController(viewController, animated: true)
        } else {
            errorOnViewControllerCreationFailure(name: "Pill Details")
        }
    }

    func goToSiteDetails(
        _ index: Index, _ source: UIViewController, params: SiteImageDeterminationParameters
    ) {
        if let viewController = SiteDetailViewController.createSiteDetailVC(
            source, index, params: params
        ) {
            pushViewController(viewController, animated: true)
        } else {
            errorOnViewControllerCreationFailure(name: "Site Details")
        }
    }

    func goToSettings() {
        pushViewController(SettingsViewController.create(), animated: true)
    }

    private func errorOnViewControllerCreationFailure(name: String) {
        let log = PDLog<Navigation>()
        log.error("Could not create \(name) View Controller")
    }
}

extension UIStoryboard {

    static func createSettingsStoryboard() -> UIStoryboard {
        UIStoryboard(name: "SettingsAndSites", bundle: Bundle(for: Navigation.self))
    }
}
