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
    
    @IBOutlet weak var estrogenTable: UITableView!
    
    // MARK: - Main
    
    private var estrogenButtonTapped = 0            // for navigation
    private var setUpFromViewDidLoad: Bool = true   // from change patch
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        estrogenTable.dataSource = self
        estrogenTable.delegate = self
        loadTitle()
        loadBarButtons()
        updateFromBackground()
        loadTabBarItems()
        State.reset()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        // Alert for disclaimer and tutorial on first start up
        if appDelegate.isFirstLaunch() {
            PDAlertController.alertForDisclaimerAndTutorial()
            Defaults.setMentionedDisclaimer(to: true)
        }
        title = Defaults.usingPatches() ?
            PDStrings.VCTitles.patches :
            PDStrings.VCTitles.injections
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
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let estrogenIndex = indexPath.row
        let id = "estrogenCellReuseId"
        let estroCell = estrogenTable.dequeueReusableCell(withIdentifier: id) as! EstrogenTableViewCell
        estroCell.configure(at: estrogenIndex)
        return estroCell
            
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < Defaults.getQuantity() {
            segueToEstrogenVC(index: indexPath.row)
        }
    }
    
    // MARK: - Actions
    
    @objc internal func editTapped() {
        let sb = UIStoryboard(name: "Settings", bundle: nil)
        if let navCon = navigationController,
            let settingsVC = sb.instantiateViewController(withIdentifier: "SettingsVC_id") as? SettingsVC {
            navCon.pushViewController(settingsVC, animated: true)
        }
    }
    
    // MARK: - Private

    // MARK: - updating from background
    
    /// Updates the estrogen buttons when VC is reloaded from a notification.
    internal func updateFromBackground() {
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
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
        if Defaults.usingPatches() {
            item?.image = #imageLiteral(resourceName: "Patch Icon")
            item?.selectedImage = #imageLiteral(resourceName: "Patch Icon")
        } else {
            item?.image = #imageLiteral(resourceName: "Injection Icon")
            item?.selectedImage = #imageLiteral(resourceName: "Injection Icon")
        }
        
        // Expired estrogens
        let estroDueCount = Schedule.totalDue(interval: Defaults.getTimeInterval())
        if estroDueCount > 0 {
            item?.badgeValue = String(estroDueCount)
        }
        
        // Expired pills
        let pillDueCount = PillScheduleRef.totalDue()
        if pillDueCount > 0,
            let vcs = self.navigationController?.tabBarController?.viewControllers,
            vcs.count > 1 {
            vcs[1].tabBarItem.badgeValue = String(pillDueCount)
        }
    }
    
    private func segueToEstrogenVC(index: Int) {
        if let sb = storyboard, let navCon = navigationController, let estroVC = sb.instantiateViewController(withIdentifier: "EstrogenVC_id") as? EstrogenVC {
            estroVC.setEstrogenScheduleIndex(to: index)
            navCon.pushViewController(estroVC, animated: true)
        }
    }
    
    /// Configures title of view controller.
    private func loadTitle() {
        if PDStrings.PickerData.deliveryMethods.count >= 2 {
            title = (Defaults.usingPatches()) ?
                PDStrings.VCTitles.patches :
                PDStrings.VCTitles.injections
        }
    }
    
    private func loadTabBarItems() {
        navigationController?.tabBarController?.tabBar.unselectedItemTintColor = UIColor.darkGray
        navigationController?.tabBarController?.tabBar.tintColor = UIColor.purple
        let size: CGFloat = (UI_USER_INTERFACE_IDIOM() ==
            UIUserInterfaceIdiom.phone) ? 9 : 25
        if let vcs = navigationController?.tabBarController?.viewControllers {
            for i in 0..<vcs.count {
                vcs[i].tabBarItem.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: size)], for: .normal)
            }
        }
    }
}
