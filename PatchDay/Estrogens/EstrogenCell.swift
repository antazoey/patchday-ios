//
//  EstrogenCell.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/11/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class EstrogenCell: UITableViewCell {
    
    @IBOutlet weak var stateImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var badgeButton: MFBadgeButton!

    private var sdk: PatchDataDelegate = app.sdk
    
    public var index = -1
    
    public func load() {
        let theme = app.theme.current
        backgroundColor = app.theme.bgColor
        let q = sdk.defaults.quantity.value.rawValue
        setThemeColors(at: index)
        switch (index) {
        case 0..<q :
            let interval = sdk.defaults.expirationInterval
            let deliv = sdk.defaults.deliveryMethod
            if let estro = sdk.estrogens.at(index) {
                let isExpired = estro.isExpired
                let img = getImage(at: index)
                let title = getTitle(at: index, interval)
                configureDate(when: isExpired)
                configureBadge(at: index, when: isExpired, deliveryMethod: deliv.value)
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
    private func getImage(at index: Index) -> UIImage {
        let theme = sdk.defaults.theme.value
        let method = sdk.defaults.deliveryMethod
        var image = PDImages.newSiteImage(theme: theme, deliveryMethod: method)
        if let estro = sdk.estrogens.at(index),
            !estro.isEmpty {
            if let site = estro.site {
                let siteName = site.imageIdentifier
                image = PDImages.siteNameToImage(siteName, theme: theme, deliveryMethod: method)
            } else {
                image = PDImages.custom(theme: theme, deliveryMethod: method)
            }
        }
        return image
    }
    
    /// Determines the start of the week title for a schedule button.
    private func getTitle(at index: Int, _ interval: ExpirationIntervalUD) -> String {
        var title: String = ""
        typealias Strings = PDStrings.ColonedStrings
        if let estro = sdk.estrogens.at(index), let exp = estro.expiration {
            switch sdk.deliveryMethod {
            case .Patches:
                let intro = estro.isExpired ? Strings.expired : Strings.expires
                title += intro + PDDateHelper.dayOfWeekString(date: exp)
            case .Injections:
                let day = PDDateHelper.dayOfWeekString(date: estro.date)
                title += Strings.lastInjected + day
            }
        }
        return title
    }
    
    /// Animates the making of an estrogen button if there were estrogen data changes.
    private func animateEstrogenButtonChanges(at index: Index,
                                              theme: PDTheme,
                                              newImage: UIImage?=nil,
                                              newTitle: String?=nil) {
        let estro = sdk.estrogens.at(index)
        sdk.state.isHormoneless = PDImages.representsSiteless(<#T##img: UIImage##UIImage#>)
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
        self.dateLabel.textColor = app.theme.textColor
        self.dateLabel.text = title
    }
    
    private func shouldAnimate(_ estro: Hormonal?, at index: Index) -> Bool {
        let q = sdk.defaults.quantity.rawValue
        var sortFromEstrogenDateChange: Bool = false
        var isSiteChange: Bool = false
        var isGone: Bool = false
        if index < q {
            if let _ = estro?.date {
                // An estrogen date changed and they are flipping
                sortFromEstrogenDateChange =
                    state.wereEstrogenChanges
                    && !state.isNew
                    && !state.onlySiteChanged
                    && index <= state.indicesOfChangedDelivery[0]
            }
            // Newly changed site and none else (date didn't change).
            isSiteChange =
                state.siteChanged
                && state.indicesOfChangedDelivery.contains(index)
        }
        // Is exiting the schedule.
        let decreased = state.decreasedCount
        let isGreaterThanNewCount = index >= q
        isGone = decreased && isGreaterThanNewCount
        return (
            sortFromEstrogenDateChange
            || isSiteChange
            || state.isNew
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
        selectedBackgroundView?.backgroundColor = app.theme.selectedColor
        backgroundColor = app.theme.getCellColor(at: index)
    }

    private func configureDate(when isExpired: Bool) {
        dateLabel.textColor = isExpired ? UIColor.red : UIColor.black
        dateLabel.font = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone) ?
            UIFont.systemFont(ofSize: 15) :
            UIFont.systemFont(ofSize: 38)
    }

    private func configureBadge(at index: Int, when isExpired: Bool, deliveryMethod: DeliveryMethod) {
        badgeButton.restorationIdentifier = String(index)
        switch deliveryMethod {
        case .Patches:
            badgeButton.type = .patches
        case .Injections:
            badgeButton.type = .injections
        }
        badgeButton.badgeValue = isExpired ? "!" : nil
    }
}
