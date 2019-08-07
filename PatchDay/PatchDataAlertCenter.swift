//
//  PatchDataAlert.swift
//  PatchData
//
//  Created by Juliya Smith on 12/20/18.
//  Copyright © 2018 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit
import PatchData

class PatchDataAlertCenter: NSObject {
    
    override var description: String {
        return "PatchDataAlert is where Patch Data Alerts are created and presented."
    }

    private var estrogenSchedule: EstrogenSchedule
    
    public init(estrogenSchedule: EstrogenSchedule) {
        self.estrogenSchedule = estrogenSchedule
    }
    
    // MARK: - Changing count

    
    //MARK: - Core data errors
    
    /// Alert for when Core Data has an error.
    func alertForCoreDataError() {
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
    func alertForPersistentStoreLoadError(error: NSError) {
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
