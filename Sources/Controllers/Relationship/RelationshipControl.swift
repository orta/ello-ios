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
    private var config = Config.Follow
    private let contentContainer = UIView(frame: CGRectZero)
    public let label = UILabel(frame: CGRectZero)
    public let mainButton = UIButton(frame: CGRectZero)
    lazy public var moreButton: UIButton = {
        let button = UIButton.buttonWithType(.Custom) as! UIButton
        button.frame = CGRect(x:0, y: 0, width: 44, height: 30)
        button.setTitle("", forState: .Normal)
        button.setSVGImages("dots")
        button.addTarget(self, action: Selector("moreTapped:"), forControlEvents: .TouchUpInside)
        return button
    }()
    public let mainButtonBackground = UIView(frame: CGRectZero)

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

    public var showMoreButton = false {
        didSet {
            moreButton.hidden = !showMoreButton
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
        label.attributedText = styleText(config.name, color: config.normalTextColor)
        mainButtonBackground.layer.borderWidth = 1
    }

    public override func intrinsicContentSize() -> CGSize {
        return showMoreButton ? sizeWithMore : size
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
        label.attributedText = styleText(config.name, color: active ? config.selectedTextColor : config.normalTextColor)
        mainButtonBackground.backgroundColor = active ? config.selectedBackgroundColor : config.normalBackgroundColor
        mainButtonBackground.layer.borderColor = config.borderColor.CGColor
        updateLayout()
    }

    private func updateRelationship(relationship: RelationshipPriority) {
        switch relationship {
        case .Friend: config = .Friend
        case .Noise: config = .Noise
        case .Mute: config = .Muted
        default: config = .Follow
        }

        updateTitles(false)
    }

    private func updateLayout() {
        label.sizeToFit()
        let textWidth = label.attributedText.widthForHeight(0)
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
        let mainButtonX = !showMoreButton ? 0 : moreButton.frame.size.width
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

    private enum Config {
        case Follow
        case Noise
        case Friend
        case Muted

        var name: String {
            switch self {
            case .Follow: return "+ Follow"
            case .Noise: return "Noise"
            case .Friend: return "Friend"
            case .Muted: return "Muted"
            }
        }

        var normalTextColor: UIColor {
            switch self {
            case .Follow: return .blackColor()
            default: return .whiteColor()
            }
        }

        var selectedTextColor: UIColor {
            return .whiteColor()
        }

        var borderColor: UIColor {
            switch self {
            case .Muted: return .redColor()
            default: return .blackColor()
            }
        }

        var normalBackgroundColor: UIColor {
            switch self {
            case .Muted: return .redColor()
            case .Follow: return .whiteColor()
            default: return .blackColor()
            }
        }

        var selectedBackgroundColor: UIColor {
            switch self {
            case .Muted: return .redColor()
            case .Follow: return .blackColor()
            default: return .grey4D()
            }
        }
    }
}
