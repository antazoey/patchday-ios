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
        return """
                PatchDataAlert makes calls to UIAlertController
                for the PatchData module. Each Alert function
                Alerts are functions in PatchDay.
                """
    }

    private var estrogenSchedule: EstrogenSchedule
    
    public init(estrogenSchedule: EstrogenSchedule) {
        self.estrogenSchedule = estrogenSchedule
    }
    
    // MARK: - Changing count
    
    /// Alert for changing the count of estrogens causing a loss of data.
    internal func alertForChangingCount(oldCount: Int, newCount: Int,
                                        simpleSetQuantity: @escaping (_ newCount: Int) -> (),
                                        reset: @escaping (_ newCount: Int) -> (),
                                        cancel: @escaping (_ oldCount: Int) -> ()) {
        if (newCount > oldCount) {
            simpleSetQuantity(newCount)
            return
        }
        if let currentVC = PatchDataAlert.getRootVC() {
            let isPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad
            let alertStyle: UIAlertController.Style = isPad ?
                .alert :
                .actionSheet
            typealias Alert = PDStrings.AlertStrings.LoseDataAlert
            let alert = UIAlertController(title: Alert.title,
                                             message: Alert.message,
                                             preferredStyle: alertStyle)
            let contStr = PDStrings.ActionStrings.cont
            let continueAction = UIAlertAction(title: contStr,
                                               style: .destructive) {
                void in
                // Note: newCount is start_i because reset only occurs
                // when decreasing count.
                self.estrogenSchedule.reset(from: newCount)
                simpleSetQuantity(newCount)
                reset(newCount)
            }
            let title = PDStrings.ActionStrings.decline
            let cancelAction = UIAlertAction(title: title,style: .cancel) {
                void in
                cancel(oldCount)
            }
            alert.addAction(continueAction)
            alert.addAction(cancelAction)
            currentVC.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - Core data errors
    
    /// Alert for when Core Data has an error.
    internal static func alertForCoreDataError() {
        typealias Alert = PDStrings.AlertStrings.CoreDataAlert
        if let currentVC = getRootVC() {
            let alert = UIAlertController(title: Alert.title,
                                             message: Alert.message,
                                             preferredStyle: .alert)
            let title = PDStrings.ActionStrings.dismiss
            let style = UIAlertAction.Style.cancel
            let closeAction = UIAlertAction(title: title,
                                            style: style,
                                            handler: nil)
            alert.addAction(closeAction)
            currentVC.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Persistent store load error
    
    /// Alert for when the persistentStore has an error.
    internal static func alertForPersistentStoreLoadError(error: NSError) {
        if let currentVC = getRootVC() {
            let alertTitle = PDStrings.AlertStrings.CoreDataAlert.title
            let msg = "(\(String(describing: error))"
            let alert = UIAlertController(title: alertTitle,
                                             message: msg,
                                             preferredStyle: .alert)
            let actionTitle = PDStrings.ActionStrings.accept
            let cancelAction = UIAlertAction(title: actionTitle,
                                             style: .destructive) {
                void in
                fatalError()
            }
            alert.addAction(cancelAction)
            currentVC.present(alert, animated: true, completion: nil)
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
