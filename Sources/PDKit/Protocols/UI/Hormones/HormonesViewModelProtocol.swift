//
//  HormonesViewModelProtocol.swift
//  PDKit
//
//  Created by Juliya Smith on 11/8/20.
//  Copyright © 2021 Juliya Smith. All rights reserved.
//

import Foundation

public protocol HormonesViewModelProtocol {
    var tabs: TabReflective? { get }
    var nav: NavigationHandling? { get }
    var table: HormonesTableProtocol! { get }
    var title: String { get }
    var expiredHormoneBadgeValue: String? { get }
    var hormones: HormoneScheduling? { get }
    func presentDisclaimerAlertIfFirstLaunch()
    func updateSiteImages()
    func handleRowTapped(
        at index: Index, _ hormonesViewController: UIViewController, reload: @escaping () -> Void
    )
    subscript(row: Index) -> HormoneCellProtocol { get }
    func goToHormoneDetails(hormoneIndex: Index, _ hormonesViewController: UIViewController)
    func loadAppTabs(source: UIViewController)
}
