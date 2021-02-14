//
//  Navigation.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/18/19.

import UIKit
import PDKit

public class Navigation: NavigationHandling {

    private lazy var log = PDLog<Navigation>()

    public func goToHormoneDetails(_ index: Index, source: UIViewController) {
        log.info("Going to Hormone Details View")
        source.navigationController?.goToHormoneDetails(index, source)
    }

    public func goToPillDetails(_ index: Index, source: UIViewController) {
        log.info("Going to Pill Details View")
        source.navigationController?.goToPillDetails(index, source)
    }

    public func goToSiteDetails(_ index: Index, source: UIViewController, params: SiteImageDeterminationParameters) {
        log.info("Going to Site Details View")
        source.navigationController?.goToSiteDetails(index, source, params: params)
    }

    public func goToSettings(source: UIViewController) {
        log.info("Going to Settings View")
        source.navigationController?.goToSettings()
    }

    public func pop(source: UIViewController) {
        guard let navCon = source.navigationController else { return }
        navCon.popViewController(animated: true)
    }
}
