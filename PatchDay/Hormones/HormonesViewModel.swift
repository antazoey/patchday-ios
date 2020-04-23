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

    private let style: UIUserInterfaceStyle
    let table: HormonesTable
    var hormones: HormoneScheduling? { sdk?.hormones }

    private var histories: [SiteImageHistory] = [
        SiteImageHistory(0),
        SiteImageHistory(1),
        SiteImageHistory(2),
        SiteImageHistory(3)
    ]

    init(hormonesTableView: UITableView, source: HormonesViewController) {
        self.style = source.getStyle()
        self.table = HormonesTable(hormonesTableView)
        super.init()
        loadAppTabs(source: source)
        initTable(style: style)
    }
    
    var mainViewControllerTitle: String {
        guard let method = sdk?.settings.deliveryMethod.value else {
            return ViewTitleStrings.HormonesTitle
        }
        return ViewTitleStrings.getTitle(for: method)
    }
    
    var expiredHormoneBadgeValue: String? {
        guard let numExpired = hormones?.totalExpired, numExpired > 0 else { return nil }
        return "\(numExpired)"
    }
    
    func updateSiteImages() {
        var i = 0
        table.reflectModel(self.sdk, style)
        do {
            try table.cells.forEach() {
                cell in
                let history = histories[i]
                history.push(getSiteImage(at: i))
                try cell.reflectSiteImage(history)
                i += 1
            }
        } catch {
            let log = PDLog<HormonesViewModel>()
            log.error("Unable to update site image at row \(i)")
        }
    }
    
    private func getSiteImage(at row: Index) -> UIImage? {
        guard let sdk = sdk else { return nil }
        let quantity = sdk.settings.quantity.rawValue
        guard row < quantity && row >= 0 else { return nil }
        let method = sdk.settings.deliveryMethod.value
        let hormone = sdk.hormones[row]

        let siteImageDeterminationParams = SiteImageDeterminationParameters(
            hormone: hormone, deliveryMethod: method
        )
        return SiteImages[siteImageDeterminationParams]
    }

    func sortHormones() {
        hormones?.sort()
    }

    func presentDisclaimerAlertIfFirstLaunch() {
        guard isFirstLaunch else { return }
        alerts?.presentDisclaimerAlert()
        sdk?.settings.setMentionedDisclaimer(to: true)
    }

    subscript(row: Index) -> UITableViewCell {
        table.cells.tryGet(at: row) ?? HormoneCell()
    }

    func goToHormoneDetails(hormoneIndex: Index, hormonesViewController: UIViewController) {
        guard let hormone = hormones?[hormoneIndex] else { return }
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

    private func initTable(style: UIUserInterfaceStyle) {
        reflectTableModel()
        updateSiteImages()
    }
    
    private func reflectTableModel(){
        table.reflectModel(sdk, style)
    }

    private var isFirstLaunch: Bool {
        guard let sdk = sdk else { return false }
        return !sdk.settings.mentionedDisclaimer.value
    }

    private func setTabs(tabBarController: UITabBarController, appViewControllers: [UIViewController]) {
        tabs = TabReflector(
            tabBarController: tabBarController, viewControllers: appViewControllers, sdk: sdk
        )
        AppDelegate.current?.tabs = tabs
        self.tabs = tabs
    }

    @objc private func reloadHormoneCellData() { table.reloadData() }
}
