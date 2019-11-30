//
// Created by Juliya Smith on 11/29/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import UIKit
import PDKit


class DoneButtonFactory {

    func createDoneButton(doneAction: Selector, mainView: UIView) -> UIButton {
        let donePoint = CGPoint(x: configureDoneButtonStartX(), y: 0)
        let doneSize = CGSize(width: 100, height: 50)
        let doneRect = CGRect(origin: donePoint, size: doneSize)
        let doneButton = UIButton(frame: doneRect)
        doneButton.setTitle(ActionStrings.done, for: UIControl.State.normal)
        doneButton.setTitle(ActionStrings.done, for: UIControl.State.highlighted)
        doneButton.setTitleColor(UIColor.blue, for: UIControl.State.normal)
        doneButton.setTitleColor(UIColor.black, for: UIControl.State.highlighted)
        doneButton.replaceTarget(self, newAction: doneAction)
        return doneButton
    }

    private func configureDoneButtonStartX(mainView: UIView) -> CGFloat {
        AppDelegate.isPad ? 0 : (mainView.frame.size.width / 2) - 50
    }
}