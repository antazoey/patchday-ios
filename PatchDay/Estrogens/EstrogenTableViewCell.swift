//
//  EstrogenTableViewCell.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/11/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit
import PatchData

class EstrogenTableViewCell: UITableViewCell {
    
    @IBOutlet weak var stateImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var badgeButton: MFBadgeButton!
    
    public func configure(at index: Index) {
        if index < Defaults.getQuantity() {
            let interval = Defaults.getTimeInterval()
            let usingPatches = Defaults.usingPatches()
            if let estro = Schedule.estrogenSchedule.getEstrogen(at: index) {
                let isExpired = estro.isExpired(interval)
                let img = determineImage(index: index)
                let title = determineTitle(estrogenIndex: index, interval)
                selectedBackgroundView = UIView()
                selectedBackgroundView?.backgroundColor = PDColors.pdPink
                backgroundColor = (index % 2 == 0) ? PDColors.pdLightBlue : UIColor.white
                dateLabel.textColor = isExpired ? UIColor.red : UIColor.black
                dateLabel.font = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone) ? UIFont.systemFont(ofSize: 15) : UIFont.systemFont(ofSize: 38)
                badgeButton.restorationIdentifier = String(index)
                badgeButton.type = usingPatches ? .patches : .injections
                badgeButton.badgeValue = isExpired ? "!" : nil
                animateEstrogenButtonChanges(at: index, newImage: img, newTitle: title)
                selectionStyle = .default
                stateImage.isHidden = false
            }
        } else if index < 4 {
            // Animate changes that occured in Settings
            animateEstrogenButtonChanges(at: index)
            backgroundColor = UIColor.white
            selectionStyle = .none
        } else {
            reset()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    /// Returns the site-reflecting estrogen button image to the corresponding index.
    private func determineImage(index: Index) -> UIImage {
        let usingPatches: Bool = Defaults.usingPatches()
        // Default:  new / add image
        let insert_img: UIImage = (usingPatches) ? PDImages.addPatch : PDImages.addInjection
        var image: UIImage = insert_img
        if let estro = Schedule.estrogenSchedule.getEstrogen(at: index),
            !estro.isEmpty() {
            if let site = estro.getSite(), let siteName = site.getImageIdentifer() {
                // Check if Site relationship siteName is a general site.
                image = (usingPatches) ? PDImages.siteNameToPatchImage(siteName) : PDImages.siteNameToInjectionImage(siteName)
            } else if let siteName = estro.getSiteNameBackUp() {
                // Check of the siteNameBackUp is a general site.
                image = (usingPatches) ? PDImages.siteNameToPatchImage(siteName) : PDImages.siteNameToInjectionImage(siteName)
            } else {
                image = (usingPatches) ? PDImages.custom_p : PDImages.custom_i
            }
        }
        return image
    }
    
    /// Determines the start of the week title for a schedule button.
    private func determineTitle(estrogenIndex: Int, _ interval: String) -> String {
        var title: String = ""
        typealias Strings = PDStrings.ColonedStrings
        if let estro = Schedule.estrogenSchedule.getEstrogen(at: estrogenIndex),
            let date =  estro.getDate() as Date?,
            let expDate = estro.expirationDate(interval: interval) {
            if Defaults.usingPatches() {
                let titleIntro = (estro.isExpired(interval)) ?
                    Strings.expired :
                    Strings.expires
                title += titleIntro + PDDateHelper.dayOfWeekString(date: expDate)
            } else {
                let day = PDDateHelper.dayOfWeekString(date: date)
                title += Strings.last_injected + day
            }
        }
        return title
    }
    
    /// Animates the making of an estrogen button if there were estrogen data changes.
    private func animateEstrogenButtonChanges(at index: Index,
                                              newImage: UIImage?=nil,
                                              newTitle: String?=nil) {
        var isNew = false
        let schedule = Schedule.estrogenSchedule
        let estrogenOptional = schedule.getEstrogen(at: index)
        if let img = newImage, PDImages.isAdd(img) {
            isNew = PDImages.isAdd(img)
        }
        Schedule.state.isNew = isNew
        if shouldAnimate(estrogenOptional, at: index) {
            UIView.transition(with: stateImage as UIView,
                              duration: 0.75,
                              options: .transitionCrossDissolve, animations: {
                self.stateImage.image = newImage
                self.stateImage.isHidden = true
            }) { void in self.dateLabel.text = newTitle }
        } else {
            stateImage.image = newImage
            dateLabel.text = newTitle
        }
    }
    
    private func shouldAnimate(_ estro: MOEstrogen?, at index: Index) -> Bool {
        var isAffectedFromChange: Bool = false
        var isSiteChange: Bool = false
        var isGone: Bool = false
        let changes = Schedule.state
        if index < Defaults.getQuantity() {
            if let hasDateAndItMatters = estro?.hasDate() {
                // Was affected non-empty estrogens from change.
                isAffectedFromChange = changes.wereEstrogenChanges && !changes.isNew && !changes.onlySiteChanged
                    && index <= changes.indexOfChangedDelivery
                    && hasDateAndItMatters
            }
            // Newly changed site and none else (date didn't change).
            isSiteChange = changes.siteChanged && index == changes.indexOfChangedDelivery
        }
        // Is exiting the schedule.
        isGone = changes.decreasedCount && index >= Defaults.getQuantity()
        return (isAffectedFromChange || isSiteChange || changes.isNew || isGone)
    }
        
    private func reset() {
        selectedBackgroundView = nil
        dateLabel.text = nil
        badgeButton.titleLabel?.text = nil
        stateImage.image = nil
        backgroundColor = UIColor.white
        selectionStyle = .none
    }
}
