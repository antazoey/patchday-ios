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


let estrogenButtonTotal = PDPickerStrings.quantities.count

class EstrogensVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var estrogensView: UIView!
    @IBOutlet weak var estrogenTable: UITableView!
    
    let defaults = patchData.sdk.defaults
    let state = patchData.sdk.state
    let estrogenSchedule = patchData.sdk.estrogenSchedule
    let pillSchedule = patchData.sdk.pillSchedule
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Have to set nav controllers during first view init
        app.setTabs(tc: self.navigationController!.tabBarController!,
                            vcs: self.navigationController!.viewControllers)
        estrogenTable.dataSource = self
        estrogenTable.delegate = self
        loadTitle()
        loadBarButtons()
        updateFromBackground()
        loadTabBarItems()
        state.reset()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 1.0, delay: 0.0,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: {
            self.view.alpha = 1.0
        }, completion: nil)
        
        applyTheme()
        presentDisclaimerAlert()
        let deliv = defaults.deliveryMethod.value
        title = PDViewControllerTitleStrings.getTitle(for: deliv)
        estrogenTable.reloadData()
        super.viewDidAppear(false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        app.tabs?.reflectEstrogen()
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
        let estrogenIndex = indexPath.row
        let id = "estrogenCellReuseId"
        typealias Cell = EstrogenCell
        let estroCell = estrogenTable.dequeueReusableCell(withIdentifier: id) as! Cell
        estroCell.index = estrogenIndex
        estroCell.load()
        return estroCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < defaults.quantity.value.rawValue {
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
    /// Updates the estrogen buttons when VC is reloaded from a notification.
    func updateFromBackground() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    @objc func appWillEnterForeground() {
        estrogenTable.reloadData()
    }
    
    private func loadBarButtons() {
        let settingsButton = UIBarButtonItem()
        settingsButton.image = #imageLiteral(resourceName: "Settings Icon")
        settingsButton.target = self
        settingsButton.action = #selector(settingsTapped)
        navigationItem.rightBarButtonItems = [settingsButton]
    }
    
    private func setExpiredEstrogensBadge(_ item: UITabBarItem?) {
        let interval = defaults.expirationInterval
        let estroDueCount = estrogenSchedule.totalDue(interval)
        if estroDueCount > 0 {
            item?.badgeValue = String(estroDueCount)
        }
    }
    
    private func setExpiredPillsBadge() {
        let pillDueCount = pillSchedule.totalDue()
        if pillDueCount > 0,
            let vcs = self.navigationController?.tabBarController?.viewControllers,
            vcs.count > 1 {
            vcs[1].tabBarItem.badgeValue = String(pillDueCount)
        }
    }
    
    private func segueToEstrogenVC(index: Int) {
        let id = "EstrogenVC_id"
        if let sb = storyboard, let navCon = navigationController,
            let estroVC = sb.instantiateViewController(withIdentifier: id) as? EstrogenVC {
            estroVC.setEstrogenScheduleIndex(to: index)
            navCon.pushViewController(estroVC, animated: true)
        }
    }
    
    /// Configures title of view controller.
    private func loadTitle() {
        title = PDViewControllerTitleStrings.getTitle(for: defaults.deliveryMethod.value)
    }
    
    private func loadTabBarItems() {
        navigationController?.tabBarController?.tabBar.unselectedItemTintColor =
            app.theme.unselectedColor
        navigationController?.tabBarController?.tabBar.tintColor =
            app.theme.purpleColor
        let size: CGFloat = (UI_USER_INTERFACE_IDIOM() ==
            UIUserInterfaceIdiom.phone) ? 9 : 25
        if let vcs = navigationController?.tabBarController?.viewControllers {
            for i in 0..<vcs.count {
                let font = UIFont.systemFont(ofSize: size)
                let fontKey = [NSAttributedString.Key.font: font]
                vcs[i].tabBarItem.setTitleTextAttributes(fontKey, for: .normal)
            }
        }
    }
    
    private func applyTheme() {
        estrogensView.backgroundColor = app.theme.bgColor
        estrogenTable.backgroundColor = app.theme.bgColor
        estrogenTable.separatorColor = app.theme.borderColor
    }
    
    private func presentDisclaimerAlert() {
        if app.isFirstLaunch() {
            app.alerts.presentDisclaimerAlert()
            defaults.setMentionedDisclaimer(to: true)
        }
    }
}
