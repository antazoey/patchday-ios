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

class ScheduleVC: UIViewController {
    
    // MARK: - Main
    
    @IBOutlet weak var pillNav: UIBarButtonItem!
    @IBOutlet weak var scheduleStack: UIStackView!
    
    // ONE
    @IBOutlet weak var estrogenViewOne: UIView!
    @IBOutlet weak var estrogenImageViewOne: UIImageView!
    @IBOutlet private var estrogenOneButton: UIButton!
    
    // TWO
    @IBOutlet weak var estrogenViewTwo: UIView!
    @IBOutlet weak var estrogenImageViewTwo: UIImageView!
    @IBOutlet private var estrogenTwoButton: UIButton!
    
    // THREE
    @IBOutlet weak var estrogenViewThree: UIView!
    @IBOutlet weak var estrogenImageViewThree: UIImageView!
    @IBOutlet private var estrogenThreeButton: UIButton!
    
    // FOUR
    @IBOutlet weak var estrogenViewFour: UIView!
    @IBOutlet weak var estrogenImageViewFour: UIImageView!
    @IBOutlet private var estrogenFourButton: UIButton!
    
    private var estrogenButtonTapped = 0            // for navigation
    private var estrogenCount: Int = 1              // for schedule button setup
    private var setUpFromViewDidLoad: Bool = true   // from change patch
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.blue
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
        pillNavSetUp()
    }
    
    // MARK: - IBAction

    @IBAction private func estrogenButtonTapped(_ sender: Any) {
        if let sb = storyboard, let navCon = navigationController, let sButton: UIButton = sender as? UIButton, let buttonID = sButton.restorationIdentifier, let estro_index = Int(buttonID), let detailsVC: DetailsVC = sb.instantiateViewController(withIdentifier: "DetailsVC_id") as? DetailsVC {
            detailsVC.setEstrogenScheduleIndex(to: estro_index)
            navCon.pushViewController(detailsVC, animated: true)
        }
    }
    
    @IBAction func pillsTapped(_ sender: Any) {
        if let sb = storyboard, let navCon = navigationController {
            let pillsVC = sb.instantiateViewController(withIdentifier: "PillsVC_id")
            navCon.pushViewController(pillsVC, animated: true)
        }
    }
    
    @IBAction func settingsTapped(_ sender: Any) {
        let sb = UIStoryboard(name: "Settings", bundle: nil)
        if let navCon = navigationController {
            let settingsVC = sb.instantiateViewController(withIdentifier: "SettingsVC_id")
            DispatchQueue.main.async {
                navCon.pushViewController(settingsVC, animated: true)
            }
        }
        
    }

    // MARK: - updating from background
    
    internal func updateFromBackground() {
        // this part is for updating the patch buttons when VC is reloaded from a notification
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    @objc internal func appWillEnterForeground() {
        displayEstrogenButtons()
        pillNavSetUp()
    }
 
    // MARK: private display funcs
    
    private func pillNavSetUp() {
        // set up pill button
        if !PillDataController.includingPG() && !PillDataController.includingTB() {
            pillNav.isEnabled = false
            pillNav.title = ""
        }
        else {
            pillNav.isEnabled = true
            if PillDataController.containsDue() {
                pillNav.title = PDStrings.titleStrings.pills + "❗️"
                return
            }
            pillNav.title = PDStrings.titleStrings.pills
        }
    }
    
    // called by viewDidLoad()
    private func displayEstrogenButtons() {
        let buttons: [UIButton] = [estrogenOneButton, estrogenTwoButton, estrogenThreeButton, estrogenFourButton]
        let views: [UIView] = [estrogenViewOne, estrogenViewTwo, estrogenViewThree, estrogenViewFour]
        let img_views: [UIImageView] = [estrogenImageViewOne, estrogenImageViewTwo, estrogenImageViewThree, estrogenImageViewFour]
        let colorDict: [Int: Bool] = [0: true, 1: false, 2: true, 3: false]
        // give data and images to patches in schedule
        if estrogenCount > 0 {
            
            // injection
            if UserDefaultsController.getDeliveryMethod() == PDStrings.pickerData.deliveryMethods[1] {
                scheduleStack.removeArrangedSubview(views[1])
                scheduleStack.removeArrangedSubview(views[2])
                scheduleStack.removeArrangedSubview(views[3])
                
                views[0].frame = CGRect(x: views[0].frame.origin.x, y: views[0].frame.origin.y, width: views[0].frame.width, height: views[0].frame.height * 4)
                img_views[0].frame = CGRect(x: img_views[0].frame.origin.x, y: img_views[0].frame.origin.y, width: img_views[0].frame.width, height: img_views[0].frame.height * 4)
                buttons[0].frame = CGRect(x: buttons[0].frame.origin.x, y: buttons[0].frame.origin.y, width: buttons[0].frame.width, height: buttons[0].frame.height * 4)
                makeEstrogenButton(estrogenButton: buttons[0], onView: views[0], imageView: img_views[0], isBlue: true, scheduleIndex: 0)
            }
                
            // patches
            else {
                
                scheduleStack.addArrangedSubview(views[1])
                scheduleStack.addArrangedSubview(views[2])
                scheduleStack.addArrangedSubview(views[3])
                views[0].frame = CGRect(x: views[0].frame.origin.x, y: views[0].frame.origin.y, width: views[1].frame.width, height: views[1].frame.height)
                img_views[0].frame = CGRect(x: img_views[0].frame.origin.x, y: img_views[0].frame.origin.y, width: img_views[1].frame.width, height: img_views[1].frame.height)
                buttons[0].frame = CGRect(x:buttons[0].frame.origin.x, y: buttons[0].frame.origin.y, width: buttons[1].frame.width, height: buttons[1].frame.height)
 
                for i in 0...(estrogenCount-1) {
                    if let isB = colorDict[i], i < buttons.count {
                        makeEstrogenButton(estrogenButton: buttons[i], onView: views[i], imageView: img_views[i], isBlue: isB, scheduleIndex: i)
                    }
                }
            }
            // disables unused button
            disableUnusedEstrogenButtons(count: estrogenCount)
        }
        // reset animation bools
        ScheduleController.increasedCount = false
        ScheduleController.decreasedCount = false
        ScheduleController.deliveryMethodChanged = false
        ScheduleController.animateScheduleFromChangeDelivery = false
        ScheduleController.onlySiteChanged = false
    }
    
    // Generates an estrogen button reflecting the user's schedule.
    // -- includes expiration title, site image, and animation.
    private func makeEstrogenButton(estrogenButton: UIButton, onView: UIView, imageView: UIImageView, isBlue: Bool, scheduleIndex: Int) {
        
        estrogenButton.isHidden = false
        let new_bg_img = determineEstrogenButtonImage(index: scheduleIndex)
        let new_title = determineEstrogenButtonTitle(scheduleIndex: scheduleIndex, timeInterval: UserDefaultsController.getTimeInterval())
        var expFont: UIFont = UIFont.systemFont(ofSize: 14)
        // iPad
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad) {
            expFont = UIFont.systemFont(ofSize: 26)
        }
        else if (!UserDefaultsController.usingPatches()) {
            expFont = UIFont.systemFont(ofSize: 20)
        }
        estrogenButton.setTitleColor(PDColors.pdDarkLines, for: .normal)
        
        onView.backgroundColor = (isBlue) ? PDColors.pdLightBlue : view.backgroundColor
 
        /* -- Animation -- */
        if ScheduleController.shouldAnimate(scheduleIndex: scheduleIndex, newBG: new_bg_img) {
            UIView.transition(with: imageView as UIView, duration: 0.75, options: .transitionCrossDissolve, animations: {
                imageView.image = new_bg_img;
            }) {
                (void) in
                estrogenButton.setTitle(new_title, for: .normal);
                estrogenButton.titleLabel!.font = expFont
                estrogenButton.isEnabled = true
            }
        }
        /* -- Default, startup -- */
        else {
            imageView.image = new_bg_img
            estrogenButton.setTitle(new_title, for: .normal)
            estrogenButton.titleLabel!.font = expFont
            // enable
            estrogenButton.isEnabled = true
        }
    }
    
    // Determine the start of the week title for a schedule button.
    private func determineEstrogenButtonTitle(scheduleIndex: Int, timeInterval: String) -> String {
        var title: String = ""
        if let estro = ScheduleController.coreDataController.getEstrogenDeliveryMO(forIndex: scheduleIndex) {
            if estro.getDate() != nil {
                title += (estro.isExpired(timeInterval: timeInterval)) ? PDStrings.colonedStrings.expired : PDStrings.colonedStrings.expires
                title += PDDateHelper.dayOfWeekString(date: estro.expirationDate(timeInterval: UserDefaultsController.getTimeInterval()))
            }
            return title
        }
        return ""
    }
    
    // Disables and hides the unused esrtogen button stacks.
    private func disableUnusedEstrogenButtons(count: Int) {
        // this hides all the patches that are not in the schedule
        if count <= 3 {
            disable(unusedButton: estrogenFourButton, unusedImgView: estrogenImageViewFour, unusedView: estrogenViewFour, shouldAnimate: true)
        }
        if count <= 2 {
            disable(unusedButton: estrogenThreeButton, unusedImgView: estrogenImageViewThree, unusedView: estrogenViewThree, shouldAnimate: true)
        }
        if count == 1 {
            disable(unusedButton: estrogenTwoButton, unusedImgView: estrogenImageViewTwo, unusedView: estrogenViewTwo, shouldAnimate: true)
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
    
    private func determineEstrogenButtonImage(index: Int) -> UIImage {
        let usingPatches = UserDefaultsController.usingPatches()
        let default_img = (usingPatches) ? PDImages.addPatch : PDImages.addInjection
        
        if let estro = ScheduleController.coreDataController.getEstrogenDeliveryMO(forIndex: index) {
            // empty
            if estro.isEmpty() {
                return default_img
            }
            // custom patch
            else if estro.isCustomLocated() {
                let customDict = (usingPatches) ? [true: PDImages.custom_notified_p, false: PDImages.custom_p] : [true: PDImages.custom_notified_i, false : PDImages.custom_i]
                if let image = customDict[estro.isExpired(timeInterval: UserDefaultsController.getTimeInterval())]     { return image }
                    // failed to load custom patch (should never happen, but just in case)
                else {
                    return default_img
                }
            }
                
            // general located patch
            else {
                if usingPatches {
                    let img = (!estro.isExpired(timeInterval: UserDefaultsController.getTimeInterval())) ? PDImages.stringToPatchImage(imageString: estro.getLocation()) : PDImages.stringToNotifiedPatchImage(imageString: estro.getLocation())
                    return img
                }
                else {
                    let img = (!estro.isExpired(timeInterval: UserDefaultsController.getTimeInterval())) ? PDImages.stringToInjectionImage(imageString: estro.getLocation()) : PDImages.stringToNotifiedInjectionImage(imageString: estro.getLocation())
                    return img
                }
            }
        }
        // nil patch
        else {
            return default_img
        }
    }

}
