//
//  HormonesViewModel.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/10/19.
//  
//

import Foundation
import PDKit

class HormonesViewModel: CodeBehindDependencies<HormonesViewModel>, HormonesViewModelProtocol {

    private let siteImageHistory: SiteImageHistorical
    private let style: UIUserInterfaceStyle
    private let now: NowProtocol
    var table: HormonesTableProtocol! = nil
    var hormones: HormoneScheduling? { sdk?.hormones }

    init(
        siteImageHistory: SiteImageHistorical,
        hormonesTableView: UITableView,
        style: UIUserInterfaceStyle
    ) {
        self.siteImageHistory = siteImageHistory
        self.style = style
        self.now = PDNow()
        super.init()
        self.table = HormonesTable(hormonesTableView, self.sdk, style)
        finishInit()
    }

    init(
        siteImageHistory: SiteImageHistorical,
        style: UIUserInterfaceStyle,
        table: HormonesTableProtocol,
        dependencies: DependenciesProtocol,
        now: NowProtocol
    ) {
        self.siteImageHistory = siteImageHistory
        self.style = style
        self.table = table
        self.now = now
        super.init(
            sdk: dependencies.sdk,
            tabs: dependencies.tabs,
            notifications: dependencies.notifications,
            alerts: dependencies.alerts,
            nav: dependencies.nav,
            badge: dependencies.badge
        )
        finishInit()
    }

    var title: String {
        guard let method = sdk?.settings.deliveryMethod.value else {
            return PDTitleStrings.HormonesTitle
        }
        return PDTitleStrings.Hormones[method]
    }

    var expiredHormoneBadgeValue: String? {
        guard let count = hormones?.totalExpired, count > 0 else { return nil }
        return "\(count)"
    }

    func updateSiteImages() {
        var i = 0
        table.reflectModel()
        do {
            try table.cells.forEach {
                cell in
                let recorder = siteImageHistory[i]
                let siteImage = getSiteImage(at: i)
                recorder.push(siteImage)
                try cell.reflectSiteImage(recorder)
                i += 1
            }
        } catch {
            let log = PDLog<HormonesViewModel>()
            log.error("Unable to update site image at row \(i)")
        }
    }

    func handleRowTapped(
        at index: Index, _ hormonesViewController: UIViewController, reload: @escaping () -> Void
    ) {
        sdk?.sites.reloadContext()
        guard let sdk = sdk else { return }
        guard let alerts = self.alerts else { return }
        guard let hormone = sdk.hormones[index] else { return }
        let nextSite = sdk.sites.suggested
        let changeHormone = {
            let command = sdk.commandFactory.createChangeHormoneCommand(hormone, now: self.now)
            command.execute()
            reload()
            self.tabs?.reflectHormones()
        }
        alerts.createHormoneActions(
            hormone.siteName,
            nextSite?.name,
            changeHormone, {
                self.goToHormoneDetails(hormoneIndex: index, hormonesViewController)
            }
        ).present()
    }

    func presentDisclaimerAlertIfFirstLaunch() {
        guard isFirstLaunch else { return }
        alerts?.createDisclaimerAlert().present()
        sdk?.settings.setMentionedDisclaimer(to: true)
    }

    subscript(row: Index) -> HormoneCellProtocol {
        if let cell = table.cells.tryGet(at: row) {
            return cell
        }
        return HormoneCell()
    }

    func goToHormoneDetails(hormoneIndex: Index, _ hormonesViewController: UIViewController) {
        nav?.goToHormoneDetails(hormoneIndex, source: hormonesViewController)
    }

    func loadAppTabs(source: UIViewController) {
        guard let navigationController = source.navigationController else { return }
        guard let tabs = navigationController.tabBarController else { return }
        guard let vcs = tabs.viewControllers else { return }
        setTabDependencies(tabBarController: tabs, appViewControllers: vcs)
    }

    private func getSiteImage(at row: Index) -> UIImage? {
        guard let sdk = sdk else { return nil }
        let quantity = sdk.settings.quantity.rawValue
        guard row < quantity && row >= 0 else { return nil }
        let hormone = sdk.hormones[row]
        let siteImageDeterminationParams = SiteImageDeterminationParameters(hormone: hormone)
        return SiteImages[siteImageDeterminationParams]
    }

    private func finishInit() {
        sdk?.hormones.reloadContext()
        initTable(style: style)
        tabs?.reflect()
        table.reloadData()
    }

    private func initTable(style: UIUserInterfaceStyle) {
        updateSiteImages()  // Animating images has to happen after `cell.configure()`
    }

    private var isFirstLaunch: Bool {
        guard let sdk = sdk else { return false }
        return !sdk.settings.mentionedDisclaimer.value
    }

    private func setTabDependencies(
        tabBarController: UITabBarController, appViewControllers: [UIViewController]
    ) {
        guard self.alerts == nil else { return }
        tabs = TabReflector(
            tabBarController: tabBarController, viewControllers: appViewControllers, sdk: sdk
        )
        AppDelegate.current?.tabs = tabs
        self.tabs = tabs
        guard let sdk = sdk else { return }
        let alerts = AlertFactory(sdk: sdk, tabs: self.tabs)
        AppDelegate.current?.alerts = alerts
        self.alerts = alerts
    }
}
