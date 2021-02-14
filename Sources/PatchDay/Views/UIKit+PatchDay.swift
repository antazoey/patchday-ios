//
//  UIKit+PatchDay.swift
//  PatchDay
//
//  Created by Juliya Smith on 10/17/19.
//  
//

import UIKit
import PDKit

extension UIControl {

    func showAsEnabled() {
        isEnabled = true
        isHidden = false
    }

    func hideAsDisabled() {
        isEnabled = false
        isHidden = true
    }

    func replaceTarget(_ baseTarget: Any?, newAction: Selector, for event: UIControl.Event = .touchUpInside) {
        removeTarget(nil, action: nil, for: .allEvents)
        addTarget(baseTarget, action: newAction, for: event)
    }

    func removeTarget(_ source: Any, action: Selector) {
        removeTarget(source, action: action, for: .allEditingEvents)
    }

    func addTarget(_ source: Any, action: Selector) {
        addTarget(source, action: action, for: .touchUpInside)
    }
}

extension UISwitch {

    func setOn(_ on: Bool) {
        setOn(on, animated: false)
    }
}

extension UIButton {

    func setTitleForNormalAndDisabled(_ title: String) {
        setTitle(title, for: .normal)
        setTitle(title, for: .disabled)
    }

    func setTitle(_ title: String) {
        setTitle(title, for: .normal)
    }

    func setTitleColor(_ color: UIColor?) {
        setTitleColor(color, for: .normal)
    }

    func restoreSuffix() -> Int? {
        if let restoreId = restorationIdentifier {
            return Int("\(restoreId.suffix(1))")
        }
        return -1
    }

    /// Tries to convert the restoration ID to a PDSetting.
    /// It must end with either "Button" or "ArrowButton" and it must be a the name of a PDSetting.
    func tryGetSettingFromButtonMetadata() -> PDSetting? {
        guard let id = restorationIdentifier else { return nil }
        guard id.substring(from: id.count - 6) == "Button" else { return nil }
        var setting = id.substring(to: id.count - 6)
        if setting.substring(from: setting.count - 5) == "Arrow" {
            setting = setting.substring(to: setting.count - 5)
        }
        return NameToSettingMap[setting.lowercased()]
    }

    private var NameToSettingMap: [String: PDSetting] {
        [
            "deliverymethod": .DeliveryMethod,
            "expirationinterval": .ExpirationInterval,
            "quantity": .Quantity,
            "notifications": .Notifications,
            "notificationsminutesbefore": .NotificationsMinutesBefore,
            "mentioneddisclaimer": .MentionedDisclaimer,
            "siteindex": .SiteIndex
        ]
    }
}

extension CAShapeLayer {

    static func createBadge(
        dimensions: CGDimensions,
        text: String,
        type: PDBadgeButtonType
    ) -> CAShapeLayer {

        let text = CATextLayer.createBadgeTextLayer(text: text, dimensions: dimensions)
        let path = UIBezierPath.createBadgePath(frame: text.frame)
        let badge = CAShapeLayer()
        badge.asBadgeShapeLayer(
            type: type,
            width: dimensions.width,
            path: path.cgPath
        )
        badge.insertTextSubLayer(textLayer: text)
        return badge
    }

    private func insertTextSubLayer(textLayer: CATextLayer) {
        self.insertSublayer(textLayer, at: 0)
    }

    private func asBadgeShapeLayer(type: PDBadgeButtonType, width: CGFloat, path: CGPath) {
        self.contentsScale = UIScreen.main.scale
        self.path = path
        self.fillColor = UIColor.red.cgColor
        self.strokeColor = UIColor.red.cgColor
        switch type {
            case .forPillsView:
                self.frame = self.frame.offsetBy(dx: width * 0.71, dy: 0)
                self.lineWidth = 0.5
            default:
                self.frame = self.frame.offsetBy(dx: width * 0.90, dy: 20)
                self.lineWidth = 4
        }
    }
}

extension CATextLayer {

    static func createBadgeTextLayer(text: String, dimensions: CGDimensions) -> CATextLayer {
        let labelText = CATextLayer()
        labelText.asBadgeTextLayer(text: text, dimensions: dimensions)
        return labelText
    }

    private func asBadgeTextLayer(text: String, dimensions: CGDimensions) {
        self.contentsScale = UIScreen.main.scale
        self.string = text
        self.fontSize = 9.0
        self.font = UIFont.systemFont(ofSize: 9)
        self.alignmentMode = CATextLayerAlignmentMode.center
        self.foregroundColor = UIColor.white.cgColor
        let labelFont = UIFont.systemFont(ofSize: 9)
        let attributes = [kCTFontAttributeName: labelFont]
        let labelWidth = min(dimensions.width * 0.8, 10.0)
        let size = CGSize(width: labelWidth, height: dimensions.height)
        let rect = String(text).boundingRect(
            with: size,
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: attributes as [NSAttributedString.Key: Any],
            context: nil
        )
        let textWidth = round(rect.width * UIScreen.main.scale)
        self.frame = CGRect(x: 0, y: 0, width: textWidth, height: dimensions.height)
    }

}

extension UIBezierPath {

    static func createBadgePath(frame: CGRect) -> UIBezierPath {
        let innerFrame = CGRect.createBadgeInnerFrame(from: frame)
        return UIBezierPath(roundedRect: innerFrame, cornerRadius: CGFloat(5.0))
    }

}

extension CGRect {

    static func createBadgeInnerFrame(from frame: CGRect) -> CGRect {
        let borderInset = CGFloat(-1.0)
        return frame.insetBy(dx: borderInset, dy: borderInset)
    }
}
