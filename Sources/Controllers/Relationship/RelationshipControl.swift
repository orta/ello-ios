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
    private let sizeWithMore = CGSize(width: 134, height: 30)

    private var followNormalBackgroundColor: UIColor = .whiteColor()
    private var followSelectedBackgroundColor: UIColor = .blackColor()

    private var establishedNormalBackgroundColor: UIColor = .blackColor()
    private var establishedSelectedBackgroundColor: UIColor = .grey4D()

    private var muteNormalBackgroundColor: UIColor = .redColor()
    private var muteSelectedBackgroundColor: UIColor = .redColor()

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

    lazy private var muteNormalAttributedTitle: NSAttributedString = {
        return self.styleText("Muted", color: .whiteColor())
    }()

    lazy private var muteSelectedAttributedTitle: NSAttributedString = {
        return self.styleText("Muted", color: .whiteColor())
    }()

    public private(set) var attributedNormalTitle = NSAttributedString(string: "")
    public private(set) var attributedSelectedTitle = NSAttributedString(string: "")
    private var normalBackgroundColor: UIColor = .whiteColor()
    private var selectedBackgroundColor: UIColor = .blackColor()

    private let contentContainer = UIView(frame: CGRectZero)
    private let label = UILabel(frame: CGRectZero)
    private let mainButton = UIButton(frame: CGRectZero)
    lazy private var moreButton: UIButton = {
        let button = UIButton.buttonWithType(.Custom) as! UIButton
        button.frame = CGRect(x:0, y: 0, width: 44, height: 30)
        button.setTitle("", forState: .Normal)
        button.setSVGImages("dots")
        button.addTarget(self, action: Selector("moreTapped:"), forControlEvents: .TouchUpInside)
        return button
    }()
    private let mainButtonBackground = UIView(frame: CGRectZero)

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

    public var showMareButton = false {
        didSet {
            moreButton.hidden = !showMareButton
            updateLayout()
            invalidateIntrinsicContentSize()
        }
    }

    required public init(coder: NSCoder) {
        self.userId = ""
        self.userAtName = ""
        super.init(coder: coder)
        addSubviews()
        addTargets()
        moreButton.hidden = true
        attributedNormalTitle = followNormalAttributedTitle
        attributedSelectedTitle = followSelectedAttributedTitle
        mainButtonBackground.layer.borderColor = UIColor.blackColor().CGColor
        mainButtonBackground.layer.borderWidth = 1
    }

    // MARK: IBActions

    @IBAction func moreTapped(sender: UIButton) {
        relationshipDelegate?.launchBlockModal(userId, userAtName: userAtName, relationship: relationship) {
            [unowned self] relationship in
            self.relationship = relationship
        }
    }

    @IBAction func buttonTouchUpInside(sender: UIButton) {
        if relationship == .Mute {
            relationshipDelegate?.launchBlockModal(userId, userAtName: userAtName, relationship: relationship) {
                [unowned self] relationship in
                self.relationship = relationship
            }
        }
        else {
            handleTapped(sender)
        }
        highlighted = false
    }

    @IBAction func buttonTouchUpOutside(sender: UIButton) {
        highlighted = false
    }

    @IBAction func buttonTouchDown(sender: UIButton) {
        highlighted = true
    }

    private func handleTapped(sender: UIButton) {
        relationshipDelegate?.relationshipTapped(userId, relationship: relationship) {
            [unowned self] (status, relationship) in
        }
    }

    public override func intrinsicContentSize() -> CGSize {
        return showMareButton ? sizeWithMore : size
    }

    // MARK: Private
    private func addSubviews() {
        addSubview(mainButtonBackground)
        addSubview(moreButton)
        mainButtonBackground.addSubview(contentContainer)
        contentContainer.addSubview(label)
        addSubview(mainButton)
    }

    private func addTargets() {
        mainButton.addTarget(self, action: Selector("buttonTouchUpInside:"), forControlEvents: .TouchUpInside)
        mainButton.addTarget(self, action: Selector("buttonTouchDown:"), forControlEvents: .TouchDown | .TouchDragEnter)
        mainButton.addTarget(self, action: Selector("buttonTouchUpOutside:"), forControlEvents: .TouchCancel | .TouchDragExit)
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
        case .Mute:
            attributedNormalTitle = muteNormalAttributedTitle
            attributedSelectedTitle = muteSelectedAttributedTitle
            normalBackgroundColor = muteNormalBackgroundColor
            selectedBackgroundColor = muteSelectedBackgroundColor
        default:
            attributedNormalTitle = followNormalAttributedTitle
            attributedSelectedTitle = followSelectedAttributedTitle
            normalBackgroundColor = followNormalBackgroundColor
            selectedBackgroundColor = followSelectedBackgroundColor
        }
        label.attributedText = active ? attributedSelectedTitle : attributedNormalTitle
        mainButtonBackground.backgroundColor = active ? selectedBackgroundColor : normalBackgroundColor

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

        mainButton.frame.size.width = size.width
        mainButton.frame.size.height = size.height
        label.frame.origin.y = size.height / 2 - label.frame.size.height / 2
        let mainButtonX = !showMareButton ? 0 : moreButton.frame.size.width
        mainButton.frame.origin.x = mainButtonX
        mainButtonBackground.frame = mainButton.frame
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
