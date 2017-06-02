//
//  SettingsViewController.swift
//  PatchDay
//
//  Created by Juliya Smith on 5/20/17.
//  Copyright © 2017 Juliya Smith. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Picker Vars
    @IBOutlet var multiPicker: UIPickerView!
    // options are "interval" and "count"
    private var whichTapped: String? = nil
    var intervals = ["Half-Week", "Week"]
    var patchCounts = ["1","2","3","4"]
    
    @IBOutlet var numberOfPatchesPicker: UIPickerView!
    
    // The Settings Outlets

    @IBOutlet var changePatchEvery: UIButton!
    @IBOutlet var numberOfPatches: UIButton!

    @IBOutlet var autoChooseSuggestedLocationSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Swipe Gestures
        
        // Load backwards SWIPE
        let swipeGestureRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.showPatchScheduleView))
        swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeGestureRecognizer)
        
        // END Swipe Gestures
        
        // Picker Load
        self.multiPicker.delegate = self
        self.multiPicker.dataSource = self
        
        // change patch every:
        self.changePatchEvery.setTitle(SettingsDefaultsController.getPatchInterval(), for: .normal)

        // number of patches:
        self.numberOfPatches.setTitle(SettingsDefaultsController.getNumberOfPatches(), for: .normal)
        
        // auto choose suggested locations:
        self.autoChooseSuggestedLocationSwitch.setOn(SettingsDefaultsController.getAutoChooseLocation(), animated: true)
        
        /* End User Defaults Set-Up */
        
    }
    
    // Picker Functions
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var numberOfRows = 0;
        // for change patch every tapped:
        if self.getWhichTapped() == "interval" {
            numberOfRows = self.intervals.count
        }
        // for number of patches tapped:
        else if self.getWhichTapped() == "count" {
            numberOfRows = self.patchCounts.count
        }
        return numberOfRows
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var title = " "
        // for change patch every tapped:
        if self.getWhichTapped() == "interval" {
            title = self.intervals[row]
        }
        // for number of patches tapped:
        else if self.getWhichTapped() == "count" {
            title = self.patchCounts[row]
        }
        return title
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // DID SELECT ROW
        // change label of corresponding button
        if self.getWhichTapped() == "interval" {
            // change the pushed state of the button
            self.changePatchEvery.titleLabel?.text = self.intervals[row]
            // change the normal state of the button
            self.changePatchEvery.setTitle(self.changePatchEvery.titleLabel?.text, for: .normal)
            // update User Defaults
            SettingsDefaultsController.setPatchInterval(to: self.intervals[row])
        }
        else if self.getWhichTapped() == "count" {
            // WARNING: This overwrites patch data
            // change the pushed state of the button
            self.numberOfPatches.titleLabel?.text = self.patchCounts[row]
            // change the normal state of the button
            self.numberOfPatches.setTitle(self.numberOfPatches.titleLabel?.text, for: .normal)
            // update User Defaults
            SettingsDefaultsController.setNumberOfPatches(to: self.patchCounts[row])
            // Overwrite data
            PatchDataController.resetPatchData()
            
        }
        
        self.multiPicker.isHidden = true
    }
    
    // END Picker funcs
    
    
    func setWhichTapped(to: String?) {
        self.whichTapped = to
    }
    
    func getWhichTapped() -> String? {
        return self.whichTapped
    }
    
    // Settings Load Picker funcs, switch functions
    
    @IBAction func numberOfPatchesArrowButtonTapped(_ sender: Any) {
        self.loadPicker(key: "count")
    }
    
    @IBAction func changePatchEveryArrowButtonTapped(_ sender: Any) {
        self.loadPicker(key: "interval")
    }
    
    @IBAction func changePatchEveryTapped(_ sender: Any) {
        self.loadPicker(key: "interval")
        
    }
    
    @IBAction func numberOfPatchesTapped(_ sender: Any) {
        // change member variable for determining correct picker
        self.loadPicker(key: "count")
        
    }
    
    @IBAction func autoChooseLocationChangeSwitch(_ sender: Any) {
        let state = self.autoChooseSuggestedLocationSwitch.isOn
        SettingsDefaultsController.setAutoChooseLocation(to: state)

    }
    
    // Segue Functions
    
    // to Patch Schedule - this is needed for the swipe, see viewDidLoad()
    func showPatchScheduleView() {
        self.performSegue(withIdentifier: "idSettingsToScheduleSegue", sender: self)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadPicker(key: String) {
        // key is either "interval" or "count"
        
        // change member variable for determining correct picker
        self.setWhichTapped(to: key)
        self.multiPicker.reloadAllComponents()
        // Unhide the picker
        self.multiPicker.isHidden = false
        // set start of picker
        if self.getWhichTapped() == "interval" {
            let selectedRowIndex = self.intervals.index(of: (self.changePatchEvery.titleLabel?.text)!)
            self.multiPicker.selectRow(selectedRowIndex!, inComponent: 0, animated: false)
        }
        else if self.getWhichTapped() == "count" {
            let selectedRowIndex = self.patchCounts.index(of: (self.numberOfPatches.titleLabel?.text)!)
            self.multiPicker.selectRow(selectedRowIndex!, inComponent: 0, animated: false)
            
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
