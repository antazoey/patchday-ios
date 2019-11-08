//
//  ViewController.swift
//  PatchDay
//
//  Created by Juliya Smith on 1/8/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import Foundation
import PDKit


class HormonesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var hormonesView: UIView!
    @IBOutlet weak var hormonalTable: UITableView!
    
    let sdk: PatchDataDelegate? = app.sdk
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTabs()
        setDelegates()
        loadTitle()
        loadBarButtons()
        updateFromBackground()
        loadTabBarItems()
        sdk?.state.reset()
    }
    
    private func loadTabs() {
        if let tabs = self.navigationController?.tabBarController, let vcs = self.navigationController?.viewControllers {
            app?.setTabs(tc: tabs, vcs: vcs)
        }
    }
    
    private func setDelegates() {
        hormonalTable.dataSource = self
        hormonalTable.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(
            withDuration: 1.0, delay: 0.0,
            options: UIView.AnimationOptions.curveEaseIn,
            animations: { self.view.alpha = 1.0 },
            completion: nil
        )
        applyTheme()
        presentDisclaimerAlert()
        let method = sdk?.defaults.deliveryMethod.value
        title = PDVCTitleStrings.getTitle(for: method)
        hormonalTable.reloadData()
        super.viewDidAppear(false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let tabs = app?.tabs {
            tabs.reflectHormone()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.height * 0.24
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Have to return 4 so that we can animate all the cells
        // (We animte cells when they removed)
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let hormoneIndex = indexPath.row
        let id = "HormoneCellReuseId"
        if let hormone = sdk?.hormones.at(hormoneIndex),
            let cell = hormonalTable.dequeueReusableCell(withIdentifier: id) as? HormoneCell {

            cell.index = hormoneIndex
            cell.load(sdk: sdk, hormone: hormone)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let q = sdk?.defaults.quantity.rawValue, indexPath.row < q {
            segueToEstrogenVC(index: indexPath.row)
        }
    }
    
    // MARK: - Actions
    
    @objc func settingsTapped() {
        let sb = UIStoryboard(name: "SettingsAndSites", bundle: nil)
        let key = "SettingsVC_id"
        if let n = navigationController,
            let settingsVC = sb.instantiateViewController(withIdentifier: key) as? SettingsVC {
            n.pushViewController(settingsVC, animated: true)
        }
    }
    
    // MARK: - Private
    /// Updates the hormone buttons when VC is reloaded from a notification.
    func updateFromBackground() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc func appWillEnterForeground() {
        hormonalTable.reloadData()
    }
    
    private func loadBarButtons() {
        let settingsButton = UIBarButtonItem()
        settingsButton.image = PDImages.settingsIcon
        settingsButton.target = self
        settingsButton.action = #selector(settingsTapped)
        navigationItem.rightBarButtonItems = [settingsButton]
    }
    
    private func setExpiredEstrogensBadge(_ item: UITabBarItem?) {
        let expiredHormoneCount = sdk.totalHormonesExpired
        if expiredHormoneCount > 0 {
            item?.badgeValue = String(expiredHormoneCount)
        }
    }
    
    private func setExpiredPillsBadge() {
        let pillDueCount = sdk.pills.totalDue
        if pillDueCount > 0,
            let vcs = self.navigationController?.tabBarController?.viewControllers,
            vcs.count > 1 {
            vcs[1].tabBarItem.badgeValue = String(pillDueCount)
        }
    }
    
    private func segueToHormoneVC(index: Int) {
        let id = "HormoneDetailVC_id"
        if let sb = storyboard, let navCon = navigationController,
            let hormoneVC = sb.instantiateViewController(withIdentifier: id) as? HormoneDetailVC {
            hormoneVC.hormoneIndex = index
            navCon.pushViewController(hormoneVC, animated: true)
        }
    }
    
    /// Configures title of view controller.
    private func loadTitle() {
        title = PDVCTitleStrings.getTitle(for: sdk.deliveryMethod)
    }
    
    private func loadTabBarItems() {
        if let styles = app?.styles {
            let tabBar = navigationController?.tabBarController?.tabBar
            tabBar?.unselectedItemTintColor = styles.theme[.unselected]
            tabBar?.tintColor = styles.theme[.purple]
        }

        let size: CGFloat = AppDelegate.isPad ? 25 : 9
        if let vcs = navigationController?.tabBarController?.viewControllers {
            for i in 0..<vcs.count {
                let font = UIFont.systemFont(ofSize: size)
                let fontKey = [NSAttributedString.Key.font: font]
                vcs[i].tabBarItem.setTitleTextAttributes(fontKey, for: .normal)
            }
        }
    }
    
    private func applyTheme() {
        if let styles = app?.styles {
            hormonesView.backgroundColor = styles.theme[.bg]
            hormonalTable.backgroundColor = styles.theme[.bg]
            hormonalTable.separatorColor = styles.theme[.border]
        }
    }
    
    private func presentDisclaimerAlert() {
        if let app = app, app.isFirstLaunch() {
            app.alerts.presentDisclaimerAlert()
            sdk.defaults.replaceStoredMentionedDisclaimer(to: true)
        }
    }
}
