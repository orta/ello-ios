//
//  RelationshipControl.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/16/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public class RelationshipControl: UIControl {

    private let size = CGSize(width: 90, height: 30)

    private var followNormalBackgroundColor: UIColor = .whiteColor()
    private var followSelectedBackgroundColor: UIColor = .blackColor()

    private var establishedNormalBackgroundColor: UIColor = .blackColor()
    private var establishedSelectedBackgroundColor: UIColor = .grey4D()

    lazy private var followNormalAttributedTitle: NSAttributedString = {
        return self.styleText("+ Follow", color: .blackColor())
    }()

    lazy private var followSelectedAttributedTitle: NSAttributedString = {
        return self.styleText("+ Follow", color: .whiteColor())
    }()

    lazy private var noiseNormalAttributedTitle: NSAttributedString = {
        return self.styleText("Noise", color: .whiteColor())
    }()

    lazy private var noiseSelectedAttributedTitle: NSAttributedString = {
        return self.styleText("Noise", color: .whiteColor())
    }()

    lazy private var friendNormalAttributedTitle: NSAttributedString = {
        return self.styleText("Friend", color: .whiteColor())
    }()

    lazy private var friendSelectedAttributedTitle: NSAttributedString = {
        return self.styleText("Friend", color: .whiteColor())
    }()

    private var attributedNormalTitle = NSAttributedString(string: "")
    private var attributedSelectedTitle = NSAttributedString(string: "")
    private var normalBackgroundColor: UIColor = .whiteColor()
    private var selectedBackgroundColor: UIColor = .blackColor()

    private let contentContainer = UIView(frame: CGRectZero)
    private let label = UILabel(frame: CGRectZero)
    private let button = UIButton(frame: CGRectZero)

    public var userId: String
    public var userAtName: String

    public weak var relationshipDelegate: RelationshipDelegate?
    public var relationship:RelationshipPriority = .None {
        didSet { updateRelationship(relationship) }
    }

    override public var selected: Bool {
        didSet {
            if !highlighted { updateTitles(selected) }
        }
    }

    override public var highlighted: Bool {
        didSet {
            if !selected { updateTitles(highlighted) }
        }
    }

    required public init(coder: NSCoder) {
        self.userId = ""
        self.userAtName = ""
        super.init(coder: coder)
        addSubviews()
        addTargets()
        self.backgroundColor = UIColor.redColor()
        self.attributedNormalTitle = followNormalAttributedTitle
        self.attributedSelectedTitle = followSelectedAttributedTitle
        layer.borderColor = UIColor.blackColor().CGColor
        layer.borderWidth = 1
    }

    // MARK: IBActions

    @IBAction func buttonTouchUpInside(sender: ImageLabelControl) {
        sendActionsForControlEvents(.TouchUpInside)
        highlighted = false
    }

    @IBAction func buttonTouchUpOutside(sender: ImageLabelControl) {
        sendActionsForControlEvents(.TouchUpOutside)
        highlighted = false
    }

    @IBAction func buttonTouchDown(sender: ImageLabelControl) {
        sendActionsForControlEvents(.TouchDown)
        highlighted = true
    }

    // MARK: Private

    private func addSubviews() {
        addSubview(contentContainer)
        addSubview(button)
        contentContainer.addSubview(label)
    }

    private func addTargets() {
        button.addTarget(self, action: Selector("buttonTouchUpInside:"), forControlEvents: .TouchUpInside)
        button.addTarget(self, action: Selector("buttonTouchDown:"), forControlEvents: .TouchDown | .TouchDragEnter)
        button.addTarget(self, action: Selector("buttonTouchUpOutside:"), forControlEvents: .TouchCancel | .TouchDragExit)
    }

    private func updateTitles(active: Bool) {
        switch relationship {
        case .Friend:
            attributedNormalTitle = friendNormalAttributedTitle
            attributedSelectedTitle = friendSelectedAttributedTitle
            normalBackgroundColor = establishedNormalBackgroundColor
            selectedBackgroundColor = establishedSelectedBackgroundColor
        case .Noise:
            attributedNormalTitle = noiseNormalAttributedTitle
            attributedSelectedTitle = noiseSelectedAttributedTitle
            normalBackgroundColor = establishedNormalBackgroundColor
            selectedBackgroundColor = establishedSelectedBackgroundColor
        default:
            attributedNormalTitle = followNormalAttributedTitle
            attributedSelectedTitle = followSelectedAttributedTitle
            normalBackgroundColor = followNormalBackgroundColor
            selectedBackgroundColor = followSelectedBackgroundColor
        }
        label.attributedText = active ? attributedSelectedTitle : attributedNormalTitle
        backgroundColor = active ? selectedBackgroundColor : normalBackgroundColor

        updateLayout()
    }

    private func updateRelationship(relationship: RelationshipPriority) {
        updateTitles(false)
    }

    private func updateLayout() {
        label.sizeToFit()
        let textWidth = attributedNormalTitle.widthForHeight(0)
        let contentX: CGFloat = size.width / 2 - textWidth / 2
        contentContainer.frame =
            CGRect(
                x: contentX,
                y: 0,
                width: textWidth,
                height: size.height
        )

        button.frame.size.width = size.width
        button.frame.size.height = size.height
        label.frame.origin.y = size.height / 2 - label.frame.size.height / 2
    }

    private func styleText(title: String, color: UIColor) -> NSAttributedString {
        let attributed = NSMutableAttributedString(string: title)
        var range = NSRange(location: 0, length: count(title))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Left

        var attributes = [
            NSFontAttributeName : UIFont.typewriterFont(13.0),
            NSForegroundColorAttributeName : color,
            NSParagraphStyleAttributeName : paragraphStyle
        ]
        attributed.addAttributes(attributes, range: range)
        return attributed
    }

}
