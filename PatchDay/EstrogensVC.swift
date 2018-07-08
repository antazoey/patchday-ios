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

class EstrogensVC: UIViewController {
    
    // MARK: - Main
    
    @IBOutlet weak var scheduleStack: UIStackView!
    
    // ONE
    @IBOutlet weak var estrogenViewOne: UIView!
    @IBOutlet weak var estrogenImageViewOne: UIImageView!
    @IBOutlet private var estrogenOneButton: MFBadgeButton!
    
    // TWO
    @IBOutlet weak var estrogenViewTwo: UIView!
    @IBOutlet weak var estrogenImageViewTwo: UIImageView!
    @IBOutlet private var estrogenTwoButton: MFBadgeButton!
    
    // THREE
    @IBOutlet weak var estrogenViewThree: UIView!
    @IBOutlet weak var estrogenImageViewThree: UIImageView!
    @IBOutlet private var estrogenThreeButton: MFBadgeButton!
    
    // FOUR
    @IBOutlet weak var estrogenViewFour: UIView!
    @IBOutlet weak var estrogenImageViewFour: UIImageView!
    @IBOutlet private var estrogenFourButton: MFBadgeButton!
    
    private var estrogenButtonTapped = 0            // for navigation
    private var estrogenCount: Int = 1              // for schedule button setup
    private var setUpFromViewDidLoad: Bool = true   // from change patch
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var estrogenController = ScheduleController.estrogenController
    
    override func viewDidLayoutSubviews() {
        setTabBarBadges()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        estrogenOneButton.badgeValue = "1"
        estrogenOneButton.drawBadgeLayer()
        loadTitle()
        updateFromBackground()
        view.backgroundColor = PDColors.pdLighterCuteGray
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        // set count, display Estrogen Buttons
        estrogenCount = UserDefaultsController.getQuantityInt()
        displayEstrogenButtons()
        // alert for disclaimer and tutorial on first start up
        if !UserDefaultsController.getMentionedDisclaimer() {
            PDAlertController.alertForDisclaimerAndTutorial()
            UserDefaultsController.setMentionedDisclaimer(to: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        estrogenOneButton.setTitle("", for: .normal)
        estrogenTwoButton.setTitle("", for: .normal)
        estrogenThreeButton.setTitle("", for: .normal)
        estrogenFourButton.setTitle("", for: .normal)
    }
    
    // MARK: - IBAction

    @IBAction private func estrogenButtonTapped(_ sender: Any) {
        if let sb = storyboard, let navCon = navigationController, let sButton: UIButton = sender as? UIButton, let buttonID = sButton.restorationIdentifier, let estro_index = Int(buttonID), let detailsVC = sb.instantiateViewController(withIdentifier: "EstrogenVC_id") as? EstrogenVC {
            detailsVC.setEstrogenScheduleIndex(to: estro_index)
            navCon.pushViewController(detailsVC, animated: true)
        }
    }

    // MARK: - updating from background
    
    internal func updateFromBackground() {
        // this part is for updating the patch buttons when VC is reloaded from a notification
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    @objc internal func appWillEnterForeground() {
        displayEstrogenButtons()
    }
 
    // MARK: private display funcs
    
    // Configured title of view controller
    private func loadTitle() {
        if PDStrings.PickerData.deliveryMethods.count >= 2 {
            title = (UserDefaultsController.usingPatches()) ? PDStrings.VCTitles.patches : PDStrings.VCTitles.injections
        }
    }
    
    // Displays injection button with appropriate image and data.
    private func displayInjection(views: [UIView], firstImg: UIImageView, firstButton: MFBadgeButton) {
        scheduleStack.removeArrangedSubview(views[1])
        scheduleStack.removeArrangedSubview(views[2])
        scheduleStack.removeArrangedSubview(views[3])
        
        views[0].frame = CGRect(x: views[0].frame.origin.x, y: views[0].frame.origin.y, width: views[0].frame.width, height: views[0].frame.height * 4)
        firstImg.frame = CGRect(x: firstImg.frame.origin.x, y: firstImg.frame.origin.y, width: firstImg.frame.width, height: firstImg.frame.height * 4)
        firstButton.frame = CGRect(x: firstButton.frame.origin.x, y: firstButton.frame.origin.y, width: firstButton.frame.width, height: firstButton.frame.height * 4)
        makeEstrogenButton(estrogenButton: firstButton, on: views[0], imageView: firstImg, isBlue: true, estrogenIndex: 0)
    }
    
    // Displays patch button with approrpiate image and data.
    private func displayPatches(views: [UIView], buttons: [MFBadgeButton], imageViews: [UIImageView], isBlueDict: Dictionary<Int, Bool>) {
        scheduleStack.addArrangedSubview(views[1])
        scheduleStack.addArrangedSubview(views[2])
        scheduleStack.addArrangedSubview(views[3])
        views[0].frame = CGRect(x: views[0].frame.origin.x, y: views[0].frame.origin.y, width: views[1].frame.width, height: views[1].frame.height)
        imageViews[0].frame = CGRect(x: imageViews[0].frame.origin.x, y: imageViews[0].frame.origin.y, width: imageViews[0].frame.width, height: imageViews[1].frame.height)
        buttons[0].frame = CGRect(x:buttons[0].frame.origin.x, y: buttons[0].frame.origin.y, width: buttons[1].frame.width, height: buttons[1].frame.height)
        
        for i in 0..<estrogenCount {
            if let isB = isBlueDict[i], i < buttons.count {
                makeEstrogenButton(estrogenButton: buttons[i], on: views[i], imageView: imageViews[i], isBlue: isB, estrogenIndex: i)
            }
        }
    }
    
    // Displays the buttons representing the estrogens.
    private func displayEstrogenButtons() {
        let buttons: [MFBadgeButton] = [estrogenOneButton, estrogenTwoButton, estrogenThreeButton, estrogenFourButton]
        let views: [UIView] = [estrogenViewOne, estrogenViewTwo, estrogenViewThree, estrogenViewFour]
        let img_views: [UIImageView] = [estrogenImageViewOne, estrogenImageViewTwo, estrogenImageViewThree, estrogenImageViewFour]
        let isBlueDict: [Int: Bool] = [0: true, 1: false, 2: true, 3: false]
        if estrogenCount > 0 {
            if UserDefaultsController.usingPatches() {
                displayPatches(views: views, buttons: buttons, imageViews: img_views, isBlueDict: isBlueDict)
            }
            else {
                displayInjection(views: views, firstImg: img_views[0], firstButton: buttons[0])
            }
            disableUnusedEstrogenButtons(count: estrogenCount)
        }
        // Reset animation bools
        ScheduleController.increasedCount = false
        ScheduleController.decreasedCount = false
        ScheduleController.deliveryMethodChanged = false
        ScheduleController.animateScheduleFromChangeDelivery = false
        ScheduleController.onlySiteChanged = false
    }
    
    // Returns the font with appropriate size for estrogen button expiration date titles.
    private func determineExpirationDateFont() -> UIFont {
        // iPad
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad) {
           return UIFont.systemFont(ofSize: 26)
        }
        // Injections
        else if (!UserDefaultsController.usingPatches()) {
            return UIFont.systemFont(ofSize: 20)
        }
        return UIFont.systemFont(ofSize: 12)
    }
    
    // Animates the making of an estrogen button if there were estrogen data changes.
    private func animateEstrogenButtonChanges(_ imageView: UIImageView, button: MFBadgeButton, newImage: UIImage, newTitle: String, expirationDateFont: UIFont, at index: Index) -> Bool {
        if ScheduleController.shouldAnimate(estrogenIndex: index, newBG: newImage, estrogenController: ScheduleController.estrogenController) {
            
            
            UIView.transition(with: imageView as UIView, duration: 0.75, options: .transitionCrossDissolve, animations: {
                imageView.image = newImage
                
            }) {
                (void) in
                button.setTitle(newTitle, for: .normal);
                button.titleLabel?.font = expirationDateFont
                button.isEnabled = true
            }
            return true
        }
        return false
    }
    
    // Generates an estrogen button reflecting the user's schedule.
    private func makeEstrogenButton(estrogenButton: MFBadgeButton, on view: UIView, imageView: UIImageView, isBlue: Bool, estrogenIndex: Int) {
        
        estrogenButton.isHidden = false
        let new_img = determineEstrogenButtonImage(index: estrogenIndex, button: estrogenButton)
        let new_title = determineEstrogenButtonTitle(estrogenIndex: estrogenIndex, UserDefaultsController.getTimeIntervalString())
        let expFont: UIFont = determineExpirationDateFont()
        estrogenButton.setTitleColor(PDColors.pdDarkLines, for: .normal)
        if UserDefaultsController.usingPatches() {
            estrogenButton.contentVerticalAlignment = .bottom
            estrogenButton.type = .patches
        }
        else {
            estrogenButton.contentVerticalAlignment = .top
            estrogenButton.titleEdgeInsets = UIEdgeInsetsMake(22, 0, 0, 0)
            estrogenButton.type = .injections
        }
        
        view.backgroundColor = (isBlue) ? PDColors.pdLightBlue : view.backgroundColor
        if !animateEstrogenButtonChanges(imageView, button: estrogenButton, newImage: new_img, newTitle: new_title, expirationDateFont: expFont, at: estrogenIndex) {
            /* -- Default, startup -- */
            imageView.image = new_img
            estrogenButton.setTitle(new_title, for: .normal)
            estrogenButton.titleLabel?.font = expFont
            estrogenButton.isEnabled = true
        }
    }
    
    // Determine the start of the week title for a schedule button.
    private func determineEstrogenButtonTitle(estrogenIndex: Int, _ intervalStr: String) -> String {
        var title: String = ""
        if let estro = ScheduleController.estrogenController.getEstrogenMO(at: estrogenIndex) {
            if let date =  estro.getDate(), let expDate = PDDateHelper.expirationDate(from: date as Date, intervalStr) {
                if UserDefaultsController.usingPatches() {
                    let titleIntro = (estro.isExpired(intervalStr)) ? PDStrings.ColonedStrings.expired : PDStrings.ColonedStrings.expires
                    title += titleIntro + PDDateHelper.dayOfWeekString(date: expDate)
                }
                else {
                    title += PDStrings.ColonedStrings.last_taken + PDDateHelper.dayOfWeekString(date: date as Date)
                }
            }
            return title
        }
        return ""
    }
    
    // Disables and hides the unused esrtogen button stacks.
    private func disableUnusedEstrogenButtons(count: Int) {
        
        let buttons = [estrogenFourButton, estrogenThreeButton, estrogenTwoButton]
        let imageViews = [estrogenImageViewFour, estrogenImageViewThree, estrogenImageViewTwo]
        let views = [estrogenViewFour, estrogenViewThree, estrogenViewTwo]
        
        for i in 0..<estrogenButtonTotal-count {
            disable(unusedButton: buttons[i]!, unusedImgView: imageViews[i]!, unusedView: views[i]!, shouldAnimate: true)
        }
    }
    
    private func disable(unusedButton: UIButton, unusedImgView: UIImageView, unusedView: UIView, shouldAnimate: Bool) {

        if shouldAnimate {
            UIView.transition(with: unusedImgView as UIView, duration: 0.75, options: .transitionFlipFromRight, animations: { unusedButton.isHidden = true; unusedView.backgroundColor = self.view.backgroundColor;
                unusedImgView.image = nil
            }, completion: nil)
        }
        else {
            unusedButton.isHidden = true
            unusedView.backgroundColor = view.backgroundColor
        }
    }
    
    private func drawBadge(on button: MFBadgeButton, using estrogen: MOEstrogen, intervalStr: String) {
        button.badgeValue = "  "
        if estrogen.isExpired(intervalStr) {
            button.drawBadgeLayer()
        }
        else {
            button.badgeValue = nil
        }
    }
    
    // Returns the site-reflecting estrogen button image to the corresponding index.
    private func determineEstrogenButtonImage(index: Index, button: MFBadgeButton) -> UIImage {
        let usingPatches: Bool = UserDefaultsController.usingPatches()
        let insert_img: UIImage = (usingPatches) ? PDImages.addPatch : PDImages.addInjection
        let intervalStr: String = UserDefaultsController.getTimeIntervalString()
        
        var image: UIImage = insert_img
        if let estro = estrogenController.getEstrogenMO(at: index) {

            // Custom
            if !estro.isEmpty(), estro.isCustomLocated() {
                image = (usingPatches) ? PDImages.custom_p : PDImages.custom_i
            }
            else if !estro.isEmpty(), let site = estro.getSite(), let siteName = site.getName() {
                image = (usingPatches) ? PDImages.stringToPatchImage(imageString: siteName) : PDImages.stringToInjectionImage(imageString: siteName)
            }
            drawBadge(on: button, using: estro, intervalStr: intervalStr)
        }
        return image
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
        let estroDueCount = ScheduleController.totalEstrogenDue()
        
        if estroDueCount > 0 {
            item?.badgeValue = String(estroDueCount)
        }
        
        // Expired pills
        let pillDueCount = ScheduleController.totalPillsDue()
        if pillDueCount > 0, let vcs = self.navigationController?.tabBarController?.viewControllers, vcs.count > 1 {
            vcs[1].tabBarItem.badgeValue = String(pillDueCount)
        }
    }
    
}
