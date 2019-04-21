//
//  EstrogenCell.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/11/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit
import PatchData

class EstrogenCell: UITableViewCell {
    
    @IBOutlet weak var stateImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var badgeButton: MFBadgeButton!
    
    public var index = -1
    
    public func load() {
        let theme = appDelegate.themeManager.theme
        backgroundColor = appDelegate.themeManager.bg_c
        let q = Defaults.quantity
        setThemeColors(at: index)
        switch (index) {
        case 0..<q :
            let interval = Defaults.timeInterval
            let usingPatches = Defaults.usingPatches()
            if let estro = Schedule.estrogenSchedule.getEstrogen(at: index) {
                let isExpired = estro.isExpired(interval)
                let img = determineImage(index: index, theme: theme)
                let title = determineTitle(estrogenIndex: index, interval)
                configureDate(when: isExpired)
                configureBadge(at: index, when: isExpired, and: usingPatches)
                self.setDateLabel(title)
                animateEstrogenButtonChanges(at: index, theme: theme, newImage: img, newTitle: title)
                selectionStyle = .default
                stateImage.isHidden = false
            }
        case q...3 :
            animateEstrogenButtonChanges(at: index, theme: theme)
            fallthrough
        default : reset()
        }
    }
    
    /// Returns the site-reflecting estrogen button image to the corresponding index.
    private func determineImage(index: Index, theme: PDTheme) -> UIImage {
        let usingPatches: Bool = Defaults.usingPatches()
        var image = PDImages.newSiteImage(theme: theme, usingPatches: usingPatches)
        if let estro = Schedule.estrogenSchedule.getEstrogen(at: index),
            !estro.isEmpty() {
            if let site = estro.getSite(), let siteName = site.getImageIdentifer() {
                // Check if Site relationship siteName is a general site.
                image = usingPatches ?
                    PDImages.siteNameToPatchImage(siteName, theme: theme) :
                    PDImages.siteNameToInjectionImage(siteName)
            } else {
                image = usingPatches ?
                    PDImages.custom_p :
                    PDImages.custom_i
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
                                              theme: PDTheme,
                                              newImage: UIImage?=nil,
                                              newTitle: String?=nil) {
        let schedule = Schedule.estrogenSchedule
        let estrogenOptional = schedule.getEstrogen(at: index)
        var isNew = false
        if let img = newImage {
            isNew =  PDImages.isSiteless(img)
        }
        Schedule.state.isNew = isNew
        let isAnimating = shouldAnimate(estrogenOptional, at: index)
        if isAnimating {
            UIView.transition(with: stateImage as UIView,
                              duration: 0.75,
                              options: .transitionCrossDissolve, animations: {
                self.stateImage.image = newImage
            }, completion: nil)
        } else {
            stateImage.image = newImage
        }
    }
    
    private func setDateLabel(_ title: String?) {
        self.dateLabel.textColor = appDelegate.themeManager.text_c
        self.dateLabel.text = title
    }
    
    private func shouldAnimate(_ estro: MOEstrogen?, at index: Index) -> Bool {
        let changes = Schedule.state
        let q = Defaults.quantity
        var sortFromEstrogenDateChange: Bool = false
        var isSiteChange: Bool = false
        var isGone: Bool = false
        if index < q {
            if let _ = estro?.hasDate() {
                // An estrogen date changed and they are flipping
                sortFromEstrogenDateChange =
                    changes.wereEstrogenChanges
                    && !changes.isNew
                    && !changes.onlySiteChanged
                    && index <= changes.indicesOfChangedDelivery[0]
            }
            // Newly changed site and none else (date didn't change).
            isSiteChange =
                changes.siteChanged
                && changes.indicesOfChangedDelivery.contains(index)
        }
        // Is exiting the schedule.
        let decreased = changes.decreasedCount
        let isGreaterThanNewCount = index >= q
        isGone = decreased && isGreaterThanNewCount
        return (
            sortFromEstrogenDateChange
            || isSiteChange
            || changes.isNew
            || isGone
        )
    }

    private func reset() {
        selectedBackgroundView = nil
        dateLabel.text = nil
        badgeButton.titleLabel?.text = nil
        stateImage.image = nil
        selectionStyle = .none
        badgeButton.badgeValue = nil
    }

    private func setThemeColors(at index: Int) {
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = appDelegate.themeManager.selected_c
        backgroundColor = appDelegate.themeManager.getCellColor(at: index)
    }

    private func configureDate(when isExpired: Bool) {
        dateLabel.textColor = isExpired ? UIColor.red : UIColor.black
        dateLabel.font = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone) ?
            UIFont.systemFont(ofSize: 15) :
            UIFont.systemFont(ofSize: 38)
    }

    private func configureBadge(at index: Int, when isExpired: Bool, and usingPatches: Bool) {
        badgeButton.restorationIdentifier = String(index)
        badgeButton.type = usingPatches ? .patches : .injections
        badgeButton.badgeValue = isExpired ? "!" : nil
    }
}
