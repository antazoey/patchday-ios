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
        codeBehind.loadAppTabs(source: self)
        codeBehind.reflectThemeInTabBar()
        setDelegates()
        loadTitle()
        loadBarButtons()
        updateFromBackground()
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
        return codeBehind.HormoneMaxCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let hormone = codeBehind.hormones?.at(indexPath.row),
            let cell = hormonalTable.dequeueHormoneCell() {

            cell.index = indexPath.row
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
        codeBehind.nav?.goToSettings(source: self)
    }

    func updateFromBackground() {
        codeBehind.watchHormonesForChanges(selector: #selector(hormonalTable.reloadData))
    }
    
    // MARK: - Private

    private func loadBarButtons() {
        let settingsButton = UIBarButtonItem()
        settingsButton.image = PDImages.settingsIcon
        settingsButton.target = self
        settingsButton.action = #selector(settingsTapped)
        navigationItem.rightBarButtonItems = [settingsButton]
    }
    
    private func setExpiredEstrogensBadge(_ item: UITabBarItem?) {
        item?.badgeValue = codeBehind.expiredHormoneBadgeValue
    }
    
    private func setExpiredPillsBadge() {
        app?.tabs?.reflectDuePillBadgeValue()
    }
    
    private func segueToHormoneVC(_ hormone: Hormonal) {
        app?.nav.goToHormoneDetails(hormone, source: self)
    }

    private func loadTitle() {
        title = codeBehind.mainViewControllerTitle
    }
    
    private func applyTheme() {
        if let styles = app?.styles {
            hormonesView.backgroundColor = styles.theme[.bg]
            hormonalTable.backgroundColor = styles.theme[.bg]
            hormonalTable.separatorColor = styles.theme[.border]
        }
    }
}

extension UITableView {
    
    func dequeueHormoneCell() -> HormoneCell? {
         return dequeueReusableCell(withIdentifier: "HormoneCellReuseId") as? HormoneCell
    }
}
