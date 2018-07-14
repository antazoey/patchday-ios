//
//  ViewController.swift
//  PatchDay
//
//  Created by Juliya Smith on 1/8/17.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import PDKit

let estrogenButtonTotal = PDStrings.PickerData.counts.count

class EstrogensVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var estrogenTable: UITableView!
    
    // MARK: - Main
    
    private var estrogenButtonTapped = 0            // for navigation
    private var setUpFromViewDidLoad: Bool = true   // from change patch
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var estrogenController = ScheduleController.estrogenController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        estrogenTable.dataSource = self
        estrogenTable.delegate = self
        loadTitle()
        loadBarButtons()
        updateFromBackground()
        
        // Reset animation bools
        ScheduleController.increasedCount = false
        ScheduleController.decreasedCount = false
        ScheduleController.deliveryMethodChanged = false
        ScheduleController.animateScheduleFromChangeDelivery = false
        ScheduleController.onlySiteChanged = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        // alert for disclaimer and tutorial on first start up
        if !UserDefaultsController.mentionedDisclaimer() {
            PDAlertController.alertForDisclaimerAndTutorial()
            UserDefaultsController.setMentionedDisclaimer(to: true)
        }
        
        estrogenTable.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        setTabBarBadges()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let h = view.frame.height
        let cell_h = (UserDefaultsController.usingPatches()) ? h * 0.24 : h * 0.75
        return cell_h
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserDefaultsController.getQuantityInt()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let estrogenIndex = indexPath.row
        let intervalStr = UserDefaultsController.getTimeIntervalString()
        let usingPatches = UserDefaultsController.usingPatches()
        let estroCount = UserDefaultsController.getQuantityInt()
        let estro = ScheduleController.estrogenController.getEstrogenMO(at: indexPath.row, estrogenCount: estroCount)
        let isExpired = estro.isExpired(intervalStr)
        let bg = UIView()
        let estroCell = estrogenTable.dequeueReusableCell(withIdentifier: "estrogenCellReuseID") as! EstrogenTableViewCell
        bg.backgroundColor = PDColors.pdPink
        let img = determineEstrogenCellImage(index: estrogenIndex)
        let title = determineEstrogenCellTitle(estrogenIndex: estrogenIndex, intervalStr)
        
        animateEstrogenButtonChanges(cell: estroCell, newImage: img, newTitle: title, at: estrogenIndex)
        estroCell.selectedBackgroundView = bg
        estroCell.backgroundColor = (indexPath.row % 2 == 0) ? PDColors.pdLightBlue : UIColor.white
        estroCell.dateLabel.textColor = isExpired ? UIColor.red : PDColors.pdDarkLines
        estroCell.badgeButton.restorationIdentifier = String(indexPath.row)
        estroCell.badgeButton.type = (usingPatches) ? .patches : .injections
        estroCell.badgeButton.badgeValue = isExpired ? "!" : nil
        
        return estroCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        segueToEstrogenVC(index: indexPath.row)
    }
    
    // MARK: - Actions
    
    @objc internal func editTapped() {
        let sb = UIStoryboard(name: "Settings", bundle: nil)
        if let navCon = navigationController, let settingsVC = sb.instantiateViewController(withIdentifier: "SettingsVC_id") as? SettingsVC {
            navCon.pushViewController(settingsVC, animated: true)
        }
    }
    
    // MARK: - Private
    
    /// Returns the site-reflecting estrogen button image to the corresponding index.
    private func determineEstrogenCellImage(index: Index) -> UIImage {
        let usingPatches: Bool = UserDefaultsController.usingPatches()
        let estrogenCount: Int = UserDefaultsController.getQuantityInt()
        // Default:  new / add image
        let insert_img: UIImage = (usingPatches) ? PDImages.addPatch : PDImages.addInjection
        var image: UIImage = insert_img
        let estro = estrogenController.getEstrogenMO(at: index, estrogenCount: estrogenCount)

        if !estro.isEmpty() {
            // Check if Site relationship siteName is a general site.
            if let site = estro.getSite(), let siteName = site.getImageIdentifer() {
                image = (usingPatches) ? PDImages.stringToPatchImage(imageString: siteName) : PDImages.stringToInjectionImage(imageString: siteName)
            }
            // Check of the siteNameBackUp is a general site.
            else if let siteName = estro.getSiteNameBackUp() {
                image = (usingPatches) ? PDImages.stringToPatchImage(imageString: siteName) : PDImages.stringToInjectionImage(imageString: siteName)
            }
            // Custom
            else {
                image = (usingPatches) ? PDImages.custom_p : PDImages.custom_i
            }
        }
        return image
    }
    
    /// Determines the start of the week title for a schedule button.
    private func determineEstrogenCellTitle(estrogenIndex: Int, _ intervalStr: String) -> String {
        var title: String = ""
        let estrogenCount = UserDefaultsController.getQuantityInt()
        let estro = ScheduleController.estrogenController.getEstrogenMO(at: estrogenIndex, estrogenCount: estrogenCount)
        if let date =  estro.getDate(), let expDate = PDDateHelper.expirationDate(from: date as Date, intervalStr) {
            if UserDefaultsController.usingPatches() {
                let titleIntro = (estro.isExpired(intervalStr)) ? PDStrings.ColonedStrings.expired : PDStrings.ColonedStrings.expires
                title += titleIntro + PDDateHelper.dayOfWeekString(date: expDate)
            }
            else {
                title += PDStrings.ColonedStrings.last_injected + PDDateHelper.dayOfWeekString(date: date as Date)
            }
        }
        return title
    }
    
    /// Animates the making of an estrogen button if there were estrogen data changes.
    private func animateEstrogenButtonChanges(cell: EstrogenTableViewCell, newImage: UIImage, newTitle: String, at index: Index){
        if ScheduleController.shouldAnimate(estrogenIndex: index, newBG: newImage, estrogenController: ScheduleController.estrogenController, estrogenCount: UserDefaultsController.getQuantityInt()) {
            
            UIView.transition(with: cell.stateImage as UIView, duration: 0.75, options: .transitionCrossDissolve, animations: {
                cell.stateImage.image = newImage
                
            }) {
                (void) in
                cell.dateLabel.text = newTitle
            }
        }
        else {
            cell.stateImage.image = newImage
            cell.dateLabel.text = newTitle
        }
    }

    // MARK: - updating from background
    
    /// Updates the estrogen buttons when VC is reloaded from a notification.
    internal func updateFromBackground() {
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    @objc internal func appWillEnterForeground() {
        //displayEstrogenButtons()
    }
    
    private func loadBarButtons() {
        let settingsButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped))
        navigationItem.rightBarButtonItems = [settingsButton]
    }
    
    private func setTabBarBadges() {
        
        // Estrogen icon
        let item = self.navigationController?.tabBarItem
        if UserDefaultsController.usingPatches() {
            item?.image = #imageLiteral(resourceName: "Patch Icon")
            item?.selectedImage = #imageLiteral(resourceName: "Patch Icon")
        }
        else {
            item?.image = #imageLiteral(resourceName: "Injection Icon")
            item?.selectedImage = #imageLiteral(resourceName: "Injection Icon")
        }
        
        // Expired estrogens
        let estroDueCount = ScheduleController.totalEstrogenDue(intervalStr: UserDefaultsController.getTimeIntervalString())
        
        if estroDueCount > 0 {
            item?.badgeValue = String(estroDueCount)
        }
        
        // Expired pills
        let pillDueCount = ScheduleController.totalPillsDue()
        if pillDueCount > 0, let vcs = self.navigationController?.tabBarController?.viewControllers, vcs.count > 1 {
            vcs[1].tabBarItem.badgeValue = String(pillDueCount)
        }
    }
    
    private func segueToEstrogenVC(index: Int) {
        if let sb = storyboard, let navCon = navigationController, let detailsVC = sb.instantiateViewController(withIdentifier: "EstrogenVC_id") as? EstrogenVC {
            detailsVC.setEstrogenScheduleIndex(to: index)
            navCon.pushViewController(detailsVC, animated: true)
        }
    }
    
    /// Configures title of view controller.
    private func loadTitle() {
        if PDStrings.PickerData.deliveryMethods.count >= 2 {
            title = (UserDefaultsController.usingPatches()) ? PDStrings.VCTitles.patches : PDStrings.VCTitles.injections
        }
    }
}
