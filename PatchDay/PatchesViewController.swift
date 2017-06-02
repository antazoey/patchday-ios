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
    
    @IBOutlet var patchOneButton: UIButton!
    @IBOutlet var patchTwoButton: UIButton!
    @IBOutlet var patchThreeButton: UIButton!
    @IBOutlet var patchFourButton: UIButton!
    
    var swipeRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer()
    
    private var numberOfPatches: Int = 1
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.setNumberOfPatches(to: Int(SettingsDefaultsController.getNumberOfPatches())!)
        self.setBackgroundColor(to: PatchDayColors.lighterCuteGray)
        self.swipeRight = self.addSwipeRecgonizer()
        self.displayPatches()
    
    }
    
    @IBAction func patchButtonTapped(_ sender: Any) {
        self.swipeRight.isEnabled = false
        self.showAddPatchView()
    }
    
    public func setNumberOfPatches(to: Int) {
        self.numberOfPatches = to
    }
    
    public func getNumberOfPatches() -> Int {
        return self.numberOfPatches
    }
    
    public func setBackgroundColor(to: UIColor) {
        view.backgroundColor = to
    }
    
    private func addSwipeRecgonizer() -> UISwipeGestureRecognizer {
        // Swipe Gesture Set-Up
        let swipeGestureRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.showSettingsView))
        swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeGestureRecognizer)
        swipeGestureRecognizer.isEnabled = true
        return swipeGestureRecognizer
        
    }
    
    // MARK: Segues
    
    @objc private func showSettingsView () {
        self.disableAllPatchButtons()
        self.performSegue(withIdentifier: "idScheduleToSettingsSegue", sender: self)
    }
    
    @objc private func showAddPatchView() {
        self.performSegue(withIdentifier: "idAddPatchSegue", sender: self)
        
    }
    
    // MARK: display patches private functions
    
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
        if index == 0 {
            self.makePatchButton(patchButton: self.patchOneButton, isBlue: true)
        }
        else if index == 1 {
            self.makePatchButton(patchButton: self.patchTwoButton, isBlue: false)
        }
        else if index == 2 {
            self.makePatchButton(patchButton: self.patchThreeButton, isBlue: true)
        }
        else if index == 3 {
            self.makePatchButton(patchButton: self.patchFourButton, isBlue: false)
            
        }
    }
    
    // called by self. displayPatchButton()
    private func makePatchButton(patchButton: UIButton, isBlue: Bool) {
        patchButton.setBackgroundImage(#imageLiteral(resourceName: "Patch Image"), for: .normal)
        patchButton.setTitle("", for: .normal)
        if isBlue {
            patchButton.backgroundColor = PatchDayColors.lightBlue
        }
        patchButton.isEnabled = true
    }
    
    // called by self.displayPatches()
    private func disableUnusedPatchButtons() {
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
    
}
