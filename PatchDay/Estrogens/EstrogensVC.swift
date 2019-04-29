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
import PatchData

let estrogenButtonTotal = PDStrings.PickerData.counts.count

class EstrogensVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet var estrogensView: UIView!
    @IBOutlet weak var estrogenTable: UITableView!
    
    // MARK: - Main
    
    private var estrogenButtonTapped = 0            // for navigation
    private var setUpFromViewDidLoad: Bool = true   // from change patch
    
    override func viewDidLoad() {
        super.viewDidLoad()
        estrogenTable.dataSource = self
        estrogenTable.delegate = self
        loadTitle()
        loadBarButtons()
        updateFromBackground()
        loadTabBarItems()
        patchData.state.reset()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 1.0, delay: 0.0,
                       options: UIView.AnimationOptions.curveEaseIn,
                       animations: {
            self.view.alpha = 1.0
        }, completion: nil)
        
        super.viewDidAppear(false)
        applyTheme()
        // Alert for disclaimer and tutorial on first start up
        if appDelegate.isFirstLaunch() {
            PDAlertController.alertForDisclaimerAndTutorial()
            patchData.defaults.set(&patchData.defaults.mentionedDisclaimer, to: true)
        }
        let deliv = patchData.defaults.deliveryMethod.value
        switch deliv {
        case .Patches:
            title = PDStrings.VCTitles.patches
        case .Injections:
            title = PDStrings.VCTitles.injections
        }
        estrogenTable.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setTabBarBadges()
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
        if indexPath.row < patchData.defaults.quantity.value.rawValue {
            segueToEstrogenVC(index: indexPath.row)
        }
    }
    
    // MARK: - Actions
    
    @objc internal func editTapped() {
        let sb = UIStoryboard(name: "SettingsAndSites", bundle: nil)
        let key = "SettingsVC_id"
        if let navCon = navigationController,
            let settingsVC = sb.instantiateViewController(withIdentifier: key) as? SettingsVC {
            navCon.pushViewController(settingsVC, animated: true)
        }
    }
    
    // MARK: - Private
    /// Updates the estrogen buttons when VC is reloaded from a notification.
    internal func updateFromBackground() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    @objc internal func appWillEnterForeground() {
        estrogenTable.reloadData()
    }
    
    private func loadBarButtons() {
        let settingsButton = UIBarButtonItem()
        settingsButton.image = #imageLiteral(resourceName: "Settings Icon")
        settingsButton.target = self
        settingsButton.action = #selector(editTapped)
        navigationItem.rightBarButtonItems = [settingsButton]
    }
    
    public func setTabBarBadges() {
        // Estrogen icon
        let item = self.navigationController?.tabBarItem
        switch patchData.defaults.deliveryMethod.value {
        case .Patches :
            item?.image = #imageLiteral(resourceName: "Patch Icon")
            item?.selectedImage = #imageLiteral(resourceName: "Patch Icon")
        case .Injections :
            item?.image = #imageLiteral(resourceName: "Injection Icon")
            item?.selectedImage = #imageLiteral(resourceName: "Injection Icon")
        }
        setExpiredEstrogensBadge(item)
        setExpiredPillsBadge()
    }
    
    private func setExpiredEstrogensBadge(_ item: UITabBarItem?) {
        let interval = patchData.defaults.expirationInterval
        let estroDueCount = patchData.estrogenSchedule.totalDue(interval)
        if estroDueCount > 0 {
            item?.badgeValue = String(estroDueCount)
        }
    }
    
    private func setExpiredPillsBadge() {
        let pillDueCount = patchData.pillSchedule.totalDue()
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
        if PDStrings.PickerData.deliveryMethods.count >= 2 {
            switch patchData.defaults.deliveryMethod.value {
            case .Patches:
                title = PDStrings.VCTitles.patches
            case .Injections:
                title = PDStrings.VCTitles.injections
            }            
        }
    }
    
    private func loadTabBarItems() {
        navigationController?.tabBarController?.tabBar.unselectedItemTintColor =
            appDelegate.themeManager.unselected_c
        navigationController?.tabBarController?.tabBar.tintColor =
            appDelegate.themeManager.purple_c
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
        let bgColor = appDelegate.themeManager.bg_c
        let borderColor = appDelegate.themeManager.border_c
        estrogensView.backgroundColor = bgColor
        estrogenTable.backgroundColor = bgColor
        estrogenTable.separatorColor = borderColor
    }
}
