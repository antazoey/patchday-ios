//
//  HormonesViewModel.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


class HormonesViewModel: CodeBehindDependencies<HormonesViewModel> {

    let table: HormonesTable
    var hormones: HormoneScheduling? { sdk?.hormones }

    init(hormonesTableView: UITableView, source: HormonesViewController) {
        self.table = HormonesTable(hormonesTableView)
        super.init()
        table.applyTheme(styles?.theme)
        loadAppTabs(source: source)
        reflectThemeInTabBar()
    }
    
    var mainViewControllerTitle: String {
        guard let method = sdk?.settings.deliveryMethod.value else { return ViewTitleStrings.HormonesTitle }
        return ViewTitleStrings.getTitle(for: method)
    }
    
    var expiredHormoneBadgeValue: String? {
        guard let numExpired = hormones?.totalExpired, numExpired > 0  else { return nil }
        return "\(numExpired)"
    }

    func sortHormones() {
        hormones?.sort()
    }

    func presentDisclaimerAlertIfFirstLaunch() {
        guard isFirstLaunch else { return }
        alerts?.presentDisclaimerAlert()
        sdk?.settings.setMentionedDisclaimer(to: true)
    }

    func getCell(at row: Index) -> UITableViewCell {
        guard let hormone = hormones?.at(row) else { return UITableViewCell() }
        return table.getCell(for: hormone, at: row, viewModel: self)
    }

    func goToHormoneDetails(hormoneIndex: Index, hormonesViewController: UIViewController) {
        guard let hormone = hormones?.at(hormoneIndex) else { return }
        nav?.goToHormoneDetails(hormone, source: hormonesViewController)
    }
    
    func loadAppTabs(source: UIViewController) {
        guard let navigationController = source.navigationController else { return }
        guard let tabs = navigationController.tabBarController else { return }
        let vcs = navigationController.viewControllers
        setTabs(tabBarController: tabs, appViewControllers: vcs)
    }
    
    func watchHormonesForChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadHormoneCellData),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    func reflectThemeInTabBar() {
        guard let styles = styles else { return }
        tabs?.reflectTheme(theme: styles.theme)
    }

    private var isFirstLaunch: Bool {
        guard let sdk = sdk else { return false }
        return !sdk.settings.mentionedDisclaimer.value
    }

    private func setTabs(tabBarController: UITabBarController, appViewControllers: [UIViewController]) {
        tabs = TabReflector(tabBarController: tabBarController, viewControllers: appViewControllers, sdk: sdk)
        AppDelegate.current?.tabs = tabs
        self.tabs = tabs
    }

    @objc private func reloadHormoneCellData() { table.reloadData() }
}
