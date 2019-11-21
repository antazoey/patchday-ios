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
    
    let codeBehind = HormonesCodeBehind()
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTabs()
        setDelegates()
        loadTitle()
        loadBarButtons()
        updateFromBackground()
        loadTabBarItems()
    }
    
    private func loadTabs() {
        if let tabs = self.navigationController?.tabBarController,
            let vcs = self.navigationController?.viewControllers {
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
        codeBehind.presentDisclaimerAlert()
        loadTitle()
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
        // Have to return 4 so that we can animate all the cells after deletions
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let hormoneIndex = indexPath.row
        if let hormone = codeBehind.hormones?.at(hormoneIndex),
            let cell = hormonalTable.dequeueHormoneCell() {

            cell.index = hormoneIndex
            cell.load(hormone: hormone)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let mone = codeBehind.hormones?.at(indexPath.row) {
            segueToHormoneVC(mone)
        }
    }
    
    // MARK: - Actions
    
    @objc func settingsTapped() {
        codeBehind.na
        let sb = UIStoryboard.createSettingsStoryboard()
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
        if let numExpired = model.sdk?.totalHormonesExpired, numExpired > 0 {
            item?.badgeValue = "\(numExpired)";
        }
    }
    
    private func setExpiredPillsBadge() {
        app?.tabs?.reflectDuePillBadgeValue()
    }
    
    private func segueToHormoneVC(_ hormone: Hormonal) {
        app?.nav.goToHormoneDetails(hormone, source: self)
    }
    
    /// Configures title of view controller.
    private func loadTitle() {
        if let method = model.sdk?.deliveryMethod {
            title = VCTitleStrings.getTitle(for: method)
        }
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
}
