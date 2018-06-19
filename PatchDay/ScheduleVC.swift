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

class ScheduleVC: UIViewController {
    
    // MARK: - Main
    
    @IBOutlet weak var pillNav: UIBarButtonItem!
    @IBOutlet weak var scheduleStack: UIStackView!
    
    // ONE
    @IBOutlet weak var deliveryViewOne: UIView!
    @IBOutlet weak var deliveryImageViewOne: UIImageView!
    @IBOutlet private var deliveryOneButton: UIButton!
    
    // TWO
    @IBOutlet weak var deliveryViewTwo: UIView!
    @IBOutlet weak var deliveryImageViewTwo: UIImageView!
    @IBOutlet private var deliveryTwoButton: UIButton!
    
    // THREE
    @IBOutlet weak var deliveryViewThree: UIView!
    @IBOutlet weak var deliveryImageViewThree: UIImageView!
    @IBOutlet private var deliveryThreeButton: UIButton!
    
    // FOUR
    @IBOutlet weak var deliveryViewFour: UIView!
    @IBOutlet weak var deliveryImageViewFour: UIImageView!
    @IBOutlet private var deliveryFourButton: UIButton!
    
    private var scheduleButtonTapped = 0            // for navigation
    private var deliveryCount: Int = 1              // for schedule button setup
    private var setUpFromViewDidLoad: Bool = true   // from change patch
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.blue
        self.updateFromBackground()
        self.view.backgroundColor = PDColors.pdLighterCuteGray
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        // set count, display Schedule Buttons
        self.setCount(to: UserDefaultsController.getQuantityInt())
        self.displayScheduleButtons()
        // alert for disclaimer and tutorial on first start up
        if !UserDefaultsController.getMentionedDisclaimer() {
            PDAlertController.alertForDisclaimerAndTutorial()
            UserDefaultsController.setMentionedDisclaimer(to: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        self.deliveryOneButton.setTitle("", for: .normal)
        self.deliveryTwoButton.setTitle("", for: .normal)
        self.deliveryThreeButton.setTitle("", for: .normal)
        self.deliveryFourButton.setTitle("", for: .normal)
        self.pillNavSetUp()
    }
    
    // MARK: - IBAction

    @IBAction private func scheduleButtonTapped(_ sender: Any) {
        if let sb = storyboard, let navCon = self.navigationController, let sButton: UIButton = sender as? UIButton, let buttonID = sButton.restorationIdentifier, let estro_index = Int(buttonID), let detailsVC: DetailsVC = sb.instantiateViewController(withIdentifier: "DetailsVC_id") as? DetailsVC {
            detailsVC.setEstrogenScheduleIndex(to: estro_index)
            navCon.pushViewController(detailsVC, animated: true)
        }
    }
    
    @IBAction func pillsTapped(_ sender: Any) {
        if let sb = storyboard, let navCon = self.navigationController {
            let pillsVC = sb.instantiateViewController(withIdentifier: "PillsVC_id")
            navCon.pushViewController(pillsVC, animated: true)
        }
    }
    
    //MARK: - Public Setters
    
    internal func setCount(to: Int) {
        self.deliveryCount = to
    }
    
    internal func getCount() -> Int {
        return self.deliveryCount
    }
    
    // MARK: - updating from background
    
    internal func updateFromBackground() {
        // this part is for updating the patch buttons when VC is reloaded from a notification
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    @objc internal func appWillEnterForeground() {
        self.displayScheduleButtons()
        self.pillNavSetUp()
    }
 
    // MARK: private display funcs
    
    private func pillNavSetUp() {
        // set up pill button
        if !PillDataController.includingPG() && !PillDataController.includingTB() {
            self.pillNav.isEnabled = false
            self.pillNav.title = ""
        }
        else {
            self.pillNav.isEnabled = true
            if PillDataController.containsDue() {
                self.pillNav.title = PDStrings.titleStrings.pills + "❗️"
                return
            }
            self.pillNav.title = PDStrings.titleStrings.pills
        }
    }
    
    // called by self.viewDidLoad()
    private func displayScheduleButtons() {
        let buttons: [UIButton] = [self.deliveryOneButton, self.deliveryTwoButton, self.deliveryThreeButton, self.deliveryFourButton]
        let views: [UIView] = [self.deliveryViewOne, self.deliveryViewTwo, self.deliveryViewThree, self.deliveryViewFour]
        let img_views: [UIImageView] = [self.deliveryImageViewOne, self.deliveryImageViewTwo, self.deliveryImageViewThree, self.deliveryImageViewFour]
        let colorDict: [Int: Bool] = [0: true, 1: false, 2: true, 3: false]
        // give data and images to patches in schedule
        if self.getCount() > 0 {
            
            // injection
            if UserDefaultsController.getDeliveryMethod() == PDStrings.pickerData.deliveryMethods[1] {
                self.scheduleStack.removeArrangedSubview(views[1])
                self.scheduleStack.removeArrangedSubview(views[2])
                self.scheduleStack.removeArrangedSubview(views[3])
                
                views[0].frame = CGRect(x: views[0].frame.origin.x, y: views[0].frame.origin.y, width: views[0].frame.width, height: views[0].frame.height * 4)
                img_views[0].frame = CGRect(x: img_views[0].frame.origin.x, y: img_views[0].frame.origin.y, width: img_views[0].frame.width, height: img_views[0].frame.height * 4)
                buttons[0].frame = CGRect(x: buttons[0].frame.origin.x, y: buttons[0].frame.origin.y, width: buttons[0].frame.width, height: buttons[0].frame.height * 4)
                self.makeScheduleButton(scheduleButton: buttons[0], onView: views[0], imageView: img_views[0], isBlue: true, scheduleIndex: 0)
            }
                
            // patches
            else {
                
                self.scheduleStack.addArrangedSubview(views[1])
                self.scheduleStack.addArrangedSubview(views[2])
                self.scheduleStack.addArrangedSubview(views[3])
                views[0].frame = CGRect(x: views[0].frame.origin.x, y: views[0].frame.origin.y, width: views[1].frame.width, height: views[1].frame.height)
                img_views[0].frame = CGRect(x: img_views[0].frame.origin.x, y: img_views[0].frame.origin.y, width: img_views[1].frame.width, height: img_views[1].frame.height)
                buttons[0].frame = CGRect(x:buttons[0].frame.origin.x, y: buttons[0].frame.origin.y, width: buttons[1].frame.width, height: buttons[1].frame.height)
 
                for i in 0...(self.getCount()-1) {
                    if let isB = colorDict[i], i < buttons.count {
                        self.makeScheduleButton(scheduleButton: buttons[i], onView: views[i], imageView: img_views[i], isBlue: isB, scheduleIndex: i)
                    }
                }
            }
            // disables unused button
            self.disableUnusedScheduleButtons()
        }
        // reset animation bools
        ScheduleController.increasedCount = false
        ScheduleController.decreasedCount = false
        ScheduleController.deliveryMethodChanged = false
        ScheduleController.animateScheduleFromChangeDelivery = false
        ScheduleController.onlySiteChanged = false
    }
    
    // makeScheduleButton(scheduleButton, isBlue, scheduleIndex) : called by self. displayScheduleButton(), generated a schedule button with the appropriate properties, including its animation in the cases when loaded from other view controller that change applicable schedule properties.
    private func makeScheduleButton(scheduleButton: UIButton, onView: UIView, imageView: UIImageView, isBlue: Bool, scheduleIndex: Int) {
        
        scheduleButton.isHidden = false
        let new_bg_img = self.determineScheduleButtonImage(index: scheduleIndex)
        let new_title = self.determineScheduleButtonTitle(scheduleIndex: scheduleIndex, timeInterval: UserDefaultsController.getTimeInterval())
        var expFont: UIFont = UIFont.systemFont(ofSize: 14)
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad) {
            expFont = UIFont.systemFont(ofSize: 26)
        }
        else if (UserDefaultsController.getDeliveryMethod() == PDStrings.pickerData.deliveryMethods[1]) {
            expFont = UIFont.systemFont(ofSize: 20)
        }
        scheduleButton.setTitleColor(PDColors.pdDarkLines, for: .normal)
        
        // Blue views
         if isBlue {
            onView.backgroundColor = PDColors.pdLightBlue
         }
         else {
            onView.backgroundColor = self.view.backgroundColor
        }
 
        /* -- Animation Process -- */
        if ScheduleController.shouldAnimate(scheduleIndex: scheduleIndex, newBG: new_bg_img) {
            UIView.transition(with: imageView as UIView, duration: 0.75, options: .transitionCrossDissolve, animations: {
                imageView.image = new_bg_img;
            }) {
                (void) in
                scheduleButton.setTitle(new_title, for: .normal);
                scheduleButton.titleLabel!.font = expFont
                // enable
                scheduleButton.isEnabled = true
            }
        }
        /* -- Default -- */
        /* (happens on startup) */
        else {
            imageView.image = new_bg_img
            scheduleButton.setTitle(new_title, for: .normal)
            scheduleButton.titleLabel!.font = expFont
            // enable
            scheduleButton.isEnabled = true
        }
    }
    
    // called by self.makeScheduleButton()
    private func determineScheduleButtonTitle(scheduleIndex: Int, timeInterval: String) -> String {
        var title: String = ""
        if let mo = ScheduleController.coreDataController.getEstrogenDeliveryMO(forIndex: scheduleIndex) {
            if mo.getDate() != nil {
                title += (mo.isExpired(timeInterval: timeInterval)) ? PDStrings.colonedStrings.expired : PDStrings.colonedStrings.expires
                title += MOEstrogen.dayOfWeekString(date: mo.expirationDate(timeInterval: UserDefaultsController.getTimeInterval()))
            }
            return title
        }
        return ""
    }
    
    // called by self.displayScheduleButtons()
    private func disableUnusedScheduleButtons() {
        // this hides all the patches that are not in the schedule
        if self.getCount() <= 3 {
            self.disable(unusedButton: self.deliveryFourButton, unusedImgView: self.deliveryImageViewFour, unusedView: self.deliveryViewFour, shouldAnimate: true)
        }
        if self.getCount() <= 2 {
            self.disable(unusedButton: self.deliveryThreeButton, unusedImgView: self.deliveryImageViewThree, unusedView: self.deliveryViewThree, shouldAnimate: true)
        }
        if self.getCount() == 1 {
            self.disable(unusedButton: self.deliveryTwoButton, unusedImgView: self.deliveryImageViewTwo, unusedView: self.deliveryViewTwo, shouldAnimate: true)
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
            unusedView.backgroundColor = self.view.backgroundColor
        }
    }
    
    private func determineScheduleButtonImage(index: Int) -> UIImage {
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
