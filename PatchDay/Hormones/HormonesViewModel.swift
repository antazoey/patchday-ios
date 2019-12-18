//
//  HormonesViewModel.swift
//  PatchDay
//
//  Created by Juliya Smith on 11/10/19.
//  Copyright © 2019 Juliya Smith. All rights reserved.
//

import Foundation
import PDKit


class HormonesViewModel: CodeBehindDependencies {

    let hormonesTable: HormonesTable
    var hormones: HormoneScheduling? { sdk?.hormones }

    init(hormonesTableView: UITableView, source: HormonesVC) {
        self.hormonesTable = HormonesTable(hormonesTableView)
        super.init()
        hormonesTable.applyTheme(styles?.theme)
        loadAppTabs(source: source)
        reflectThemeInTabBar()
    }
    
    var mainViewControllerTitle: String {
        if let method = sdk?.defaults.deliveryMethod.value {
            return VCTitleStrings.getTitle(for: method)
        }
        return VCTitleStrings.hormonesTitle
    }
    
    var expiredHormoneBadgeValue: String? {
        if let numExpired = hormones?.totalExpired, numExpired > 0 {
            return "\(numExpired)"
        }
        return nil
    }

    func presentDisclaimerAlert() {
        if isFirstLaunch {
            alerts?.presentDisclaimerAlert()
            sdk?.defaults.setMentionedDisclaimer(to: true)
        }
    }

    func getCell(at row: Index) -> UITableViewCell {
        if let hormone = hormones?.at(row),
           let cell = hormonesTable.dequeueCell() {
            return cell.configure(viewModel: self, hormone: hormone, hormoneIndex: row)
        }
        return UITableViewCell()
    }

    func goToHormoneDetails(hormoneIndex: Index, hormonesViewController: UIViewController) {
        if let hormone = hormones?.at(hormoneIndex) {
            nav?.goToHormoneDetails(hormone, source: hormonesViewController)
        }
    }
    
    func loadAppTabs(source: UIViewController) {
        if let tabs = source.navigationController?.tabBarController,
            let vcs = source.navigationController?.viewControllers {
            
            setTabs(tabBarController: tabs, appViewControllers: vcs)
        }
    }
    
    func watchHormonesForChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hormonesTable.reloadData),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    func reflectThemeInTabBar() {
        if let theme = styles?.theme {
            tabs?.reflectTheme(theme: theme)
        }
    }

    func getCellRowHeight(viewHeight: CGFloat) -> CGFloat {
        viewHeight * 0.24
    }

    private var isFirstLaunch: Bool {
        !(sdk?.defaults.mentionedDisclaimer.value ?? false)
    }

    private func setTabs(tabBarController: UITabBarController, appViewControllers: [UIViewController]) {
        tabs = TabReflector(tabBarController: tabBarController, viewControllers: appViewControllers, sdk: sdk)
        AppDelegate.current?.tabs = tabs
        self.tabs = tabs
    }
}
