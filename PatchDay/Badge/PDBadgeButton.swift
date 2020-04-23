// PDBadgeButton.swift
// Inspired by moflo's MFBadgeButton from  Feb 3, 2017.
// https://gist.github.com/moflo/3939e6801dc9575903b05baa72365695


import UIKit
import PDKit

enum PDBadgeButtonType {
	case patches
	case injections
	case pills
}

struct CGDimensions {
	var width: CGFloat
	var height: CGFloat

	static func createBadgeDimensionsFromFrame(frame: CGRect) -> CGDimensions {
		let w = frame.size.width
		let h = CGFloat(10.0)
		return CGDimensions(width: w, height: h)
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
		case .patches, .injections:
			self.frame = self.frame.offsetBy(dx: width * 0.90, dy: 20)
			self.lineWidth = 4
		case .pills:
			self.frame = self.frame.offsetBy(dx: width * 0.71, dy: 0)
			self.lineWidth = 0.5
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

class PDBadgeButton: UIButton {

	var type: PDBadgeButtonType = .patches

	var badgeValue: String! = "" {
		didSet {
			self.layoutSubviews()
		}
	}

	override init(frame: CGRect) {
		// Initialize the UIView
		super.init(frame: frame)
		self.awakeFromNib()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.awakeFromNib()
	}

	override func awakeFromNib() {
		self.drawBadgeLayer()
	}

	var badgeLayer: CAShapeLayer!

	func drawBadgeLayer() {
		if self.badgeLayer != nil {
			self.badgeLayer.removeFromSuperlayer()
		}

		if self.badgeValue == nil || self.badgeValue.count == 0 {
			return
		}

		let dim = CGDimensions.createBadgeDimensionsFromFrame(frame: self.frame)
		let badge = CAShapeLayer.createBadge(
			dimensions: dim,
			text: self.badgeValue,
			type: self.type
		)
		self.layer.insertSublayer(badge, at: 999)
		self.layer.masksToBounds = false
		self.badgeLayer = badge
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		self.drawBadgeLayer()
		self.setNeedsDisplay()
	}
}
