// PDBadgeButton.swift
// Inspired by moflo's MFBadgeButton from  Feb 3, 2017.
// https://gist.github.com/moflo/3939e6801dc9575903b05baa72365695

import UIKit
import PDKit

enum PDBadgeButtonType {
	case forPatchesHormonesView
	case forInjectionsHormonesView
	case forPillsView
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

class PDBadgeButton: UIButton {

	var type: PDBadgeButtonType = .forPatchesHormonesView

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
