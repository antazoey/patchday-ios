// MFBadgeButton.swift
// moflo created this on Feb 3, 2017.
// https://gist.github.com/moflo/3939e6801dc9575903b05baa72365695

// Edited by Juliya Smith


import UIKit

enum PDBadgeButtonType {
    case patches
    case injections
    case pills
}

class MFBadgeButton : UIButton {
    
    public var type: PDBadgeButtonType = .patches
    
    var badgeValue : String! = "" {
        didSet {
            self.layoutSubviews()
        }
    }
    
    override init(frame :CGRect)  {
        // Initialize the UIView
        super.init(frame : frame)
        self.awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.awakeFromNib()
    }
    
    override func awakeFromNib() {
        self.drawBadgeLayer()
    }
    
    var badgeLayer :CAShapeLayer!
    func drawBadgeLayer() {
        
        if self.badgeLayer != nil {
            self.badgeLayer.removeFromSuperlayer()
        }
        
        // Omit layer if text is nil
        if self.badgeValue == nil || self.badgeValue.count == 0 {
            return
        }
        
        //! Initial label text layer
        let labelText = CATextLayer()
        labelText.contentsScale = UIScreen.main.scale
        labelText.string = self.badgeValue.uppercased()
        labelText.fontSize = 9.0
        labelText.font = UIFont.systemFont(ofSize: 9)
        labelText.alignmentMode = CATextLayerAlignmentMode.center
        labelText.foregroundColor = UIColor.white.cgColor
        let labelString = self.badgeValue.uppercased() as String?
        let labelFont = UIFont.systemFont(ofSize: 9)
        let attributes = [kCTFontAttributeName : labelFont]
        let w = self.frame.size.width
        let h = CGFloat(10.0)  // fixed height
        let labelWidth = min(w * 0.8, 10.0)    // Starting point
        let rect = labelString!.boundingRect(with: CGSize(width: labelWidth, height: h), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes as [NSAttributedString.Key : Any], context: nil)
        let textWidth = round(rect.width * UIScreen.main.scale)
        labelText.frame = CGRect(x: 0, y: 0, width: textWidth, height: h)
        
        //! Initialize outline, set frame and color
        let shapeLayer = CAShapeLayer()
        shapeLayer.contentsScale = UIScreen.main.scale
        let frame : CGRect = labelText.frame
        let cornerRadius = CGFloat(5.0)
        let borderInset = CGFloat(-1.0)
        let innerFrame = frame.insetBy(dx: borderInset, dy: borderInset)
        let aPath = UIBezierPath(roundedRect: innerFrame,
                                 cornerRadius: cornerRadius)
        
        shapeLayer.path = aPath.cgPath
        shapeLayer.fillColor = UIColor.red.cgColor
        shapeLayer.strokeColor = UIColor.red.cgColor

        shapeLayer.insertSublayer(labelText, at: 0)

        switch type {
        case .patches, .injections :
            shapeLayer.frame = shapeLayer.frame.offsetBy(dx: w * 0.90, dy: 20)
            shapeLayer.lineWidth = 4
        case .pills : shapeLayer.frame = shapeLayer.frame.offsetBy(dx: w * 0.71, dy: 0)
            shapeLayer.lineWidth = 0.5
        }
        
        self.layer.insertSublayer(shapeLayer, at: 999)
        self.layer.masksToBounds = false
        self.badgeLayer = shapeLayer
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.drawBadgeLayer()
        self.setNeedsDisplay()
    }
}
