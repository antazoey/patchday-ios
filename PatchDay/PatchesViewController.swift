//
//  ViewController.swift
//  PatchDay
//
//  Created by Juliya Smith on 1/8/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class PatchesViewController: UIViewController {
    
    // MARK: - Main
    
    @IBOutlet var patchOneButton: UIButton!
    @IBOutlet var patchTwoButton: UIButton!
    @IBOutlet var patchThreeButton: UIButton!
    @IBOutlet var patchFourButton: UIButton!
    
    var swipeRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer()
    
    private var expiredPatchCount: Int = 0
    
    // for segue to addPatchViewController
    private var patchButtonTapped = 0
    
    var numberOfPatches: Int = 1
    
    override func viewDidLoad() {
        self.updateFromBackground()
        super.viewDidLoad()
        self.setNumberOfPatches(to: SettingsController.getNumberOfPatchesInt())
        self.setBackgroundColor(to: PatchDayColors.lighterCuteGray)
        self.swipeRight = self.addSwipeRecgonizer()
        self.displayPatches()
        self.updateBadge()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: (Any)?) {
        if segue.identifier == PatchDayStrings.addPatchSegueID {
            if let destination = segue.destination as? AddPatchViewController {
                destination.setPatchReference(to: self.getPatchButtonTapped())
            }
        }
    }
    
    @IBAction func patchButtonTapped(_ sender: Any) {
        self.setPatchButtonTapped(to: self.getReference(fromPatchButton: sender))
        self.swipeRight.isEnabled = false
        self.showAddPatchView()
    }
    
    //MARK: - Public Setters
    
    public func setNumberOfPatches(to: Int) {
        self.numberOfPatches = to
    }
    
    public func getNumberOfPatches() -> Int {
        return self.numberOfPatches
    }
    
    public func setBackgroundColor(to: UIColor) {
        view.backgroundColor = to
    }
    
    // MARK: - updating from background
    
    func updateFromBackground() {
        // this part is for updating the patch buttons when VC is reloaded from a notification
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    func appWillEnterForeground() {
        self.displayPatches()
    }
    
    // MARK: - Segues
    
    @objc private func showSettingsView () {
        self.disableAllPatchButtons()
        self.performSegue(withIdentifier: PatchDayStrings.scheduleToSettingsID, sender: self)
    }
    
    @objc private func showAddPatchView() {
        self.performSegue(withIdentifier: PatchDayStrings.addPatchSegueID, sender: self)
        
    }
    
    // MARK: - private getters
    
    private func getPatchButtonTapped() -> Int {
        return self.patchButtonTapped
    }
    
    private func setPatchButtonTapped(to: Int) {
        self.patchButtonTapped = to
    }
    
    // MARK: private display funcs
    
    // called by self.viewDidLoad()
    private func displayPatches() {
        // give data and images to patches in schedule
        for i in 0...(self.getNumberOfPatches()-1) {
            self.displayPatchButton(index: i)
        }
        // disables unused button
        self.disableUnusedPatchButtons()
        
    }
    
    // called by self.displayPatches()
    private func displayPatchButton(index: Int) {
        let buttonDict: [Int: UIButton] = [0: self.patchOneButton, 1: self.patchTwoButton, 2: self.patchThreeButton, 3: self.patchFourButton]
        let colorDict: [Int: Bool] = [0: true, 1: false, 2: true, 3: false]
        self.makePatchButton(patchButton: buttonDict[index]!, isBlue: colorDict[index]!, patchIndex: index)
    }
    
    // called by self. displayPatchButton()
    private func makePatchButton(patchButton: UIButton, isBlue: Bool, patchIndex: Int) {
        patchButton.setBackgroundImage(self.determinePatchButtonImage(index: patchIndex), for: .normal)
        if isBlue {
            patchButton.backgroundColor = PatchDayColors.lightBlue
        }
        patchButton.setTitle("", for: .normal)
        patchButton.isEnabled = true
    }
    
    // called by self.displayPatches()
    private func disableUnusedPatchButtons() {
        // this hides all the patches that are not in the schedule
        if self.getNumberOfPatches() <= 3 {
            self.patchFourButton.isHidden = true
        }
        if self.getNumberOfPatches() <= 2 {
            self.patchThreeButton.isHidden = true
        }
        if self.getNumberOfPatches() == 1 {
            self.patchTwoButton.isHidden = true
        }
        
    }
    
    private func disableAllPatchButtons(){
        self.patchOneButton.isEnabled = false
        self.patchTwoButton.isEnabled = false
        self.patchThreeButton.isEnabled = false
        self.patchFourButton.isEnabled = false
    }
    
    private func enableAllPatchButtons() {
        self.patchOneButton.isEnabled = true
        self.patchTwoButton.isEnabled = true
        self.patchThreeButton.isEnabled = true
        self.patchFourButton.isEnabled = true
    }
    
    private func determinePatchButtonImage(index: Int) -> UIImage {
        let patch = PatchDataController.getPatch(forIndex: index)
        var image: UIImage = UIImage()
        // empty patch
        if patch == nil || patch!.isEmpty() {
            
            image = PatchDayImages.addPatch
        }
        // custom patch
        else if patch!.isCustomLocated() {
            let customDict = [true: PatchDayImages.custom_notified, false: PatchDayImages.custom]
            image = customDict[patch!.isExpired()]!
            if patch!.isExpired() {
                expiredPatchCount += 1
            }
        }
        else {
            // not expired, normal images
            if !patch!.isExpired() {
                image = PatchDayImages.stringToImage(imageString: patch!.getLocation())
            }
            // expired...
            else {
                image = PatchDayImages.stringToNotifiedImage(imageString: patch!.getLocation())
                expiredPatchCount += 1
            }
            
        }
        return image
    }
    
    // called by patchButtonTapped()idScheduleToSettingsSegue"
    private func getReference(fromPatchButton: Any) -> Int {
        var ref = 0
        var count = 0
        let givenPatchButtonID: String = (fromPatchButton as! UIButton).restorationIdentifier!
        for patchID in PatchDayStrings.patchButtonIDs {
            count += 1
            if givenPatchButtonID == patchID {
                ref = count
                break
            }
        }
        return ref
        
    }
    
    private func addSwipeRecgonizer() -> UISwipeGestureRecognizer {
        // Swipe Gesture Set-Up
        let swipeGestureRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.showSettingsView))
        swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeGestureRecognizer)
        swipeGestureRecognizer.isEnabled = true
        return swipeGestureRecognizer
        
    }
    
    private func updateBadge() {
        UIApplication.shared.applicationIconBadgeNumber = expiredPatchCount
    }
    
}
