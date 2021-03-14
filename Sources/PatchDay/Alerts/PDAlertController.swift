//
//  PDAlert.swift
//  PatchDay
//
//  Created by Juliya Smith on 6/16/19.

import UIKit
import PDKit

// My Hero @Umair Aamir: https://stackoverflow.com/questions/48307833/alert-is-not-displayed-in-tableviewcontroller
class PDAlertController: UIAlertController {

    var alertWindow: UIWindow?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        alertWindow?.isHidden = true
        alertWindow = nil
    }

    func show(animated: Bool = true) {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIViewController()
        window.windowLevel = UIApplication.shared.windows.last!.windowLevel + 1
        window.makeKeyAndVisible()
        window.rootViewController?.present(self, animated: animated, completion: nil)
        alertWindow = window
    }
}

class PDAlert: PDAlerting {

    let alert: PDAlertController

    init(title: String, message: String, style: UIAlertController.Style) {
        let _style = AppDelegate.isPad ? .alert : style
        self.alert = PDAlertController(title: title, message: message, preferredStyle: _style)
    }

    static var style: UIAlertController.Style = {
        AppDelegate.isPad ? .alert : .actionSheet
    }()

    func present(actions: [UIAlertAction]) {
        if alert.actions.count == 0 {
            for a in actions {
                if !alert.actions.contains(a) {
                    alert.addAction(a)
                }
            }
        }
        alert.show()
    }

    func present() {
        self.alert.show()
    }
}
