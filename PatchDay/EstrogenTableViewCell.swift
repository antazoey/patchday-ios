//
//  EstrogenTableViewCell.swift
//  PatchDay
//
//  Created by Juliya Smith on 7/11/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

class EstrogenTableViewCell: UITableViewCell {
    
    @IBOutlet weak var stateImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var badgeButton: MFBadgeButton!
    
    public func configure(at index: Index) {
        if index < UserDefaultsController.getQuantityInt() {
            let intervalStr = UserDefaultsController.getTimeIntervalString()
            let usingPatches = UserDefaultsController.usingPatches()
            let estro = ScheduleController.estrogenController.getEstrogen(at: index)
            let isExpired = estro.isExpired(intervalStr)
            let img = determineImage(index: index)
            let title = determineTitle(estrogenIndex: index, intervalStr)
            
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
            // In the case there were changes from Settings
        else if index < 4 {
            animateEstrogenButtonChanges(at: index)
            
            backgroundColor = UIColor.white
             /*
            selectedBackgroundView = UIView()
            selectedBackgroundView?.backgroundColor = UIColor.white
 */
            selectionStyle = .none
        }
        else {
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
        let usingPatches: Bool = UserDefaultsController.usingPatches()
        // Default:  new / add image
        let insert_img: UIImage = (usingPatches) ? PDImages.addPatch : PDImages.addInjection
        var image: UIImage = insert_img
        let estro = ScheduleController.estrogenController.getEstrogen(at: index)
        
        if !estro.isEmpty() {
            // Check if Site relationship siteName is a general site.
            if let site = estro.getSite(), let siteName = site.getImageIdentifer() {
                image = (usingPatches) ? PDImages.siteNameToPatchImage(siteName) : PDImages.siteNameToInjectionImage(siteName)
            }
                // Check of the siteNameBackUp is a general site.
            else if let siteName = estro.getSiteNameBackUp() {
                image = (usingPatches) ? PDImages.siteNameToPatchImage(siteName) : PDImages.siteNameToInjectionImage(siteName)
            }
                // Custom
            else {
                image = (usingPatches) ? PDImages.custom_p : PDImages.custom_i
            }
        }
        return image
    }
    
    /// Determines the start of the week title for a schedule button.
    private func determineTitle(estrogenIndex: Int, _ intervalStr: String) -> String {
        var title: String = ""
        let estro = ScheduleController.estrogenController.getEstrogen(at: estrogenIndex)
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
    private func animateEstrogenButtonChanges(at index: Index, newImage: UIImage?=nil, newTitle: String?=nil){
        if ScheduleController.shouldAnimate(estrogenIndex: index, isOld: (newImage != PDImages.addPatch), estrogenController: ScheduleController.estrogenController, estrogenCount: UserDefaultsController.getQuantityInt()) {
            
            UIView.transition(with: stateImage as UIView, duration: 0.75, options: .transitionCrossDissolve, animations: {
                self.stateImage.image = newImage
                self.stateImage.isHidden = true
                
            }) {
                (void) in
                self.dateLabel.text = newTitle
            }
        }
        else {
            stateImage.image = newImage
            dateLabel.text = newTitle
        }
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
