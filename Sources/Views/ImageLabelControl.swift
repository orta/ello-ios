//
//  ImageLabelControl.swift
//  Ello
//
//  Created by Sean on 4/29/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit

public class ImageLabelControl: UIControl {

    public var title: String? {
        get { return self.attributedNormalTitle?.string }
        set {
            if label.attributedText?.string != newValue && newValue != nil {
                attributedNormalTitle = attributedText(newValue!, color: UIColor.greyA())
                attributedSelectedTitle = attributedText(newValue!, color: UIColor.blackColor())
                reLayout()
            }
        }
    }

    override public var selected: Bool {
        didSet { icon.selected = selected }
    }

    override public var highlighted: Bool {
        didSet { icon.highlighted = highlighted }
    }

    let innerPadding: CGFloat = 5
    let outerPadding: CGFloat = 5
    let minWidth: CGFloat = 44
    let height: CGFloat = 44
    let titleFont = UIFont.typewriterFont(13.0)
    let contentContainer = UIView(frame: CGRectZero)
    let label = UILabel(frame: CGRectZero)
    let button = UIButton(frame: CGRectZero)
    var icon: ImageLabelAnimatable
    var attributedNormalTitle: NSAttributedString!
    var attributedSelectedTitle: NSAttributedString!

    // MARK: Initializers

    public init(icon: ImageLabelAnimatable, title: String) {
        self.icon = icon
        super.init(frame: CGRectZero)
        addSubviews()
        addTargets()
        self.title = title
//        backgroundColor = UIColor.redColor()
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public func animate() {
        self.icon.animate?()
    }

    public func finishAnimation() {
        self.icon.finishAnimation?()
    }

    // MARK: IBActions

    @IBAction func buttonTouchUpInside(sender: ImageLabelControl) {
        sendActionsForControlEvents(.TouchUpInside)
        icon.selected = false
        if highlighted { return }
        label.attributedText = attributedNormalTitle
    }

    @IBAction func buttonTouchUpOutside(sender: ImageLabelControl) {
        sendActionsForControlEvents(.TouchUpOutside)
        icon.selected = false
        if highlighted { return }
        label.attributedText = attributedNormalTitle
    }

    @IBAction func buttonTouchDown(sender: ImageLabelControl) {
        sendActionsForControlEvents(.TouchDown)
        icon.selected = true
        label.attributedText = attributedSelectedTitle
    }

    // MARK: Private

    private func addSubviews() {
        addSubview(contentContainer)
        addSubview(button)
        contentContainer.addSubview(icon.view)
        contentContainer.addSubview(label)
    }

    private func addTargets() {
        button.addTarget(self, action: Selector("buttonTouchUpInside:"), forControlEvents: .TouchUpInside)
        button.addTarget(self, action: Selector("buttonTouchDown:"), forControlEvents: .TouchDown)
        button.addTarget(self, action: Selector("buttonTouchUpOutside:"), forControlEvents: .TouchUpOutside)
    }

    private func reLayout() {
        label.attributedText = attributedNormalTitle
        label.sizeToFit()
        let textWidth = attributedNormalTitle.widthForHeight(0)
        let contentWidth = textWidth == 0 ?
            icon.view.frame.width :
            icon.view.frame.width + textWidth + innerPadding

        var width: CGFloat =  contentWidth + outerPadding * 2

        // force a minimum width of 44 pts
        width = max(width, minWidth)

        self.frame =
            CGRect(
                x: 0,
                y: 0,
                width: width,
                height: height
            )

        let iconViewY: CGFloat = height / 2 - icon.view.frame.size.height / 2
        icon.view.frame =
            CGRect(
                x: 0,
                y: iconViewY,
                width: icon.view.frame.width,
                height: icon.view.frame.height
            )

        let contentX: CGFloat = width / 2 - contentWidth / 2
        contentContainer.frame =
            CGRect(
                x: contentX,
                y: 0,
                width: contentWidth,
                height: height
            )

        button.frame =
            CGRect(
                x: 0,
                y: 0,
                width: width,
                height: height
            )

        label.frame =
            CGRect(
                x: icon.view.frame.origin.x + icon.view.frame.width + innerPadding,
                y: height / 2 - label.frame.size.height / 2,
                width: label.frame.width,
                height: label.frame.height
            )
    }

    private func attributedText(title: String, color: UIColor) -> NSAttributedString {
        let attributed = NSMutableAttributedString(string: title)
        var range = NSRange(location: 0, length: count(title))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Left

        var attributes = [
            NSFontAttributeName : titleFont,
            NSForegroundColorAttributeName : color,
//            NSBackgroundColorAttributeName : UIColor.purpleColor(),
            NSParagraphStyleAttributeName : paragraphStyle
        ]
        attributed.addAttributes(attributes, range: range)
        return attributed
    }
}
