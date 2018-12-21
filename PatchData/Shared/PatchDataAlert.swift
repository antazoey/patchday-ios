//
//  PatchDataAlert.swift
//  PatchData
//
//  Created by Juliya Smith on 12/20/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit

internal class PatchDataAlert: NSObject {
    
    override var description: String {
        return "Alert for Data issues."
    }
    
    internal static var currentAlert = UIAlertController()
    
    // MARK: - Changing count
    
    /// Alert for changing the count of estrogens causing a loss of data.
    internal static func alertForChangingCount(oldCount: Int, newCount: Int, countButton: UIButton, navController: UINavigationController?, reset: @escaping (_ newCount: Int) -> ()) {
        if (newCount > oldCount) {
            UserDefaultsController.setQuantityWithoutWarning(to: "\(newCount)")
            return
        }
        if let currentVC = getRootVC() {
            let alertStyle: UIAlertController.Style  = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad) ? .alert : .actionSheet
            currentAlert = UIAlertController(title: PDStrings.AlertStrings.LoseDataAlert.title, message: PDStrings.AlertStrings.LoseDataAlert.message, preferredStyle: alertStyle)
            let continueAction = UIAlertAction(title: PDStrings.ActionStrings.cont, style: .destructive) {
                (void) in
                // Note: newCount is start_i because reset only occurs when decreasing count
                PDSchedule.estrogenSchedule.resetEstrogenData(start_i: newCount, end_i: 3)
                UserDefaultsController.setQuantityWithoutWarning(to: "\(newCount)")
                
                // Tab bar image / badgeValue
                if let vcs = navController?.tabBarController?.viewControllers, vcs.count > 0 {
                    let c = PDSchedule.totalEstrogenDue(intervalStr: UserDefaultsController.getTimeIntervalString())
                    vcs[0].navigationController?.tabBarItem.badgeValue = (c > 0) ? String(c) : nil
                }
                reset(newCount)
            }
            let cancelAction = UIAlertAction(title: PDStrings.ActionStrings.decline, style: .cancel) {
                (void) in
                countButton.setTitle(String(oldCount), for: .normal)
            }
            currentAlert.addAction(continueAction)
            currentAlert.addAction(cancelAction)
            currentVC.present(currentAlert, animated: true, completion: nil)
        }
    }
    
    //MARK: - Core data errors
    
    /// Alert for when Core Data has an error.
    internal static func alertForCoreDataError() {
        if let currentVC = getRootVC() {
            currentAlert = UIAlertController(title: PDStrings.AlertStrings.CoreDataAlert.title, message: PDStrings.AlertStrings.CoreDataAlert.message, preferredStyle: .alert)
            let closeAction = UIAlertAction(title: PDStrings.ActionStrings.dismiss, style: UIAlertAction.Style.cancel, handler: nil)
            currentAlert.addAction(closeAction)
            currentVC.present(currentAlert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Persistent store load error
    
    /// Alert for when the persistentStore has an error.
    internal static func alertForPersistentStoreLoadError(error: NSError) {
        if let currentVC = getRootVC() {
            currentAlert = UIAlertController(title: PDStrings.AlertStrings.CoreDataAlert.title, message: "(\(String(describing: error))", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: PDStrings.ActionStrings.accept, style: .destructive) {
                (void) in
                fatalError()
            }
            currentAlert.addAction(cancelAction)
            currentVC.present(currentAlert, animated: true, completion: nil)
        }
    }
    
    /// Gets keywindow.
    private static func getKeyWindow() -> UIWindow {
        if let window = UIApplication.shared.keyWindow {
            return window
        }
        return UIWindow()
    }
    
    /// Gets root VC.
    private static func getRootVC() -> UIViewController? {
        let window = getKeyWindow()
        return window.rootViewController
    }
}
