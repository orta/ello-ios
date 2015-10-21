//
//  RelationshipControl.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/16/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation
import SVGKit

private let ViewHeight: CGFloat = 30
private let ButtonWidth: CGFloat = 30
private let MoreButtonMargin: CGFloat = 5
private let MinViewWidth: CGFloat = 105


public class RelationshipControl: UIView {
    let followingButton: FollowButton = FollowButton()
    let starredButton: UIButton = {
        let button = UIButton()
        button.setImage(SVGKImage(named: "star_normal.svg").UIImage!, forState: .Normal)
        button.setImage(SVGKImage(named: "star_selected.svg").UIImage!, forState: .Highlighted)
        return button
    }()

    lazy public var moreButton: UIButton = {
        let button = UIButton(type: .Custom)
        button.frame = CGRect(x:0, y: 0, width: 44, height: ViewHeight)
        button.setSVGImages("dots")
        return button
    }()

    public var userId: String
    public var userAtName: String

    public weak var relationshipDelegate: RelationshipDelegate?
    public var relationshipPriority: RelationshipPriority = .None {
        didSet { updateRelationshipPriority() }
    }

    public var showMoreButton = false {
        didSet {
            moreButton.hidden = !showMoreButton
            setNeedsLayout()
            invalidateIntrinsicContentSize()
        }
    }

    required public override init(frame: CGRect) {
        self.userId = ""
        self.userAtName = ""
        super.init(frame: frame)
        setup()
    }

    required public init?(coder: NSCoder) {
        self.userId = ""
        self.userAtName = ""
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addSubviews()
        addTargets()
        moreButton.hidden = true
        updateRelationshipPriority()
    }

    public override func intrinsicContentSize() -> CGSize {
        var totalSize = CGSize(width: 0, height: ViewHeight)
        let followingSize = followingButton.intrinsicContentSize()
        if followingSize.width > MinViewWidth {
            totalSize.width += followingSize.width
        }
        else {
            totalSize.width += MinViewWidth
        }
        totalSize.width += ButtonWidth

        if showMoreButton {
            totalSize.width += ButtonWidth + MoreButtonMargin
        }

        return totalSize
    }

    // MARK: IBActions

    @IBAction func moreTapped(sender: UIButton) {
        relationshipDelegate?.launchBlockModal(userId, userAtName: userAtName, relationshipPriority: relationshipPriority) {
            [unowned self] relationshipPriority in
            self.relationshipPriority = relationshipPriority
        }
    }

    @IBAction func starredButtonTapped(sender: UIButton) {
        switch relationshipPriority {
        case .Mute:
            launchBlockModal()
        case .Starred:
            handleUnstar()
        default:
            handleStar()
        }
    }

    @IBAction func followingButtonTapped(sender: UIButton) {
        switch relationshipPriority {
        case .Mute:
            launchBlockModal()
        case .Following, .Starred:
            handleUnfollow()
        default:
            handleFollow()
        }
    }

    private func launchBlockModal() {
        guard relationshipPriority == .Mute else {
            return
        }

        relationshipDelegate?.launchBlockModal(userId, userAtName: userAtName, relationshipPriority: relationshipPriority) {
            [unowned self] relationshipPriority in
            self.relationshipPriority = relationshipPriority
        }
    }

    private func handleRelationship(newRelationshipPriority: RelationshipPriority) {
        self.userInteractionEnabled = false
        relationshipDelegate?.relationshipTapped(userId, relationshipPriority: newRelationshipPriority) { [unowned self] (status, relationshipPriority) in
            self.userInteractionEnabled = true
            if let newRelationshipPriority = relationshipPriority?.subject?.relationshipPriority {
                self.relationshipPriority = newRelationshipPriority
            }
        }
    }

    private func handleFollow() {
        handleRelationship(.Following)
    }

    private func handleStar() {
        handleRelationship(.Starred)
    }

    private func handleUnstar() {
        handleRelationship(.Following)
    }

    private func handleUnfollow() {
        handleRelationship(.Inactive)
    }

    // MARK: Private
    private func addSubviews() {
        addSubview(moreButton)
        addSubview(starredButton)
        addSubview(followingButton)
    }

    private func addTargets() {
        moreButton.addTarget(self, action: Selector("moreTapped:"), forControlEvents: .TouchUpInside)
        followingButton.addTarget(self, action: Selector("followingButtonTapped:"), forControlEvents: .TouchUpInside)
        starredButton.addTarget(self, action: Selector("starredButtonTapped:"), forControlEvents: .TouchUpInside)
    }

    private func updateRelationshipPriority() {
        let config: Config
        switch relationshipPriority {
        case .Following: config = .Following
        case .Starred: config = .Starred
        case .Mute: config = .Muted
        default: config = .None
        }

        followingButton.config = config
        if config.starred {
            let star = SVGKImage(named: "star_selected.svg").UIImage!
            starredButton.setImage(star, forState: .Normal)
        }
        else {
            let star = SVGKImage(named: "star_normal.svg").UIImage!
            starredButton.setImage(star, forState: .Normal)
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        if showMoreButton {
            moreButton.frame = CGRect(x: 0, y: 0, width: ButtonWidth, height: ViewHeight)
            followingButton.frame = CGRect(x: moreButton.frame.maxX + MoreButtonMargin, y: 0, width: frame.width - 2 * ButtonWidth - MoreButtonMargin, height: ViewHeight)
        }
        else {
            moreButton.frame = CGRectZero
            followingButton.frame = CGRect(x: 0, y: 0, width: frame.width - ButtonWidth, height: ViewHeight)
        }

        starredButton.frame = CGRect(x: frame.width - ButtonWidth, y: 0, width: ButtonWidth, height: ViewHeight)
    }

    private enum Config {
        case Starred
        case Following
        case Muted
        case None

        var title: String {
            switch self {
            case .None: return NSLocalizedString("Follow", comment: "Follow button title")
            case .Starred, .Following: return NSLocalizedString("Following", comment: "Following button title")
            case .Muted: return NSLocalizedString("Muted", comment: "Muted button title")
            }
        }

        var starred: Bool {
            switch self {
            case .Starred: return true
            default: return false
            }
        }

        var normalTextColor: UIColor {
            switch self {
            case .None: return .blackColor()
            default: return .whiteColor()
            }
        }

        var highlightedTextColor: UIColor {
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
            case .None: return .whiteColor()
            default: return .blackColor()
            }
        }

        var selectedBackgroundColor: UIColor {
            switch self {
            case .Muted: return UIColor.redFFCCCC()
            case .None: return .blackColor()
            default: return .grey4D()
            }
        }

        var image: UIImage? {
            switch self {
            case .Muted: return nil
            case .Starred, .Following: return SVGKImage(named: "checksmall_white.svg").UIImage!
            default: return SVGKImage(named: "plussmall_selected.svg").UIImage
            }
        }

        var highlightedImage: UIImage? {
            switch self {
            case .Muted, .Starred, .Following: return self.image
            default: return SVGKImage(named: "plussmall_white.svg").UIImage
            }
        }
    }

    class FollowButton: WhiteElloButton {
        private var config: Config = .None {
            didSet {
                setTitleColor(config.normalTextColor, forState: .Normal)
                setTitleColor(config.highlightedTextColor, forState: .Highlighted)
                setTitleColor(UIColor.greyC(), forState: .Disabled)
                setTitle(config.title, forState: .Normal)
                borderColor = config.borderColor
                setImage(config.image, forState: .Normal)
                setImage(config.highlightedImage, forState: .Highlighted)

                updateOutline()
            }
        }

        var borderColor = UIColor.greyE5()

        override func sharedSetup() {
            super.sharedSetup()
            contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 10)
            let plus = SVGKImage(named: "plussmall_selected.svg").UIImage!
            setImage(plus, forState: .Normal)

            layer.borderWidth = 1
            updateOutline()
            config = .None
            backgroundColor = config.normalBackgroundColor
        }

        override var highlighted: Bool {
            didSet {
                updateOutline()
            }
        }

        private func updateOutline() {
            layer.borderColor = borderColor.CGColor
            backgroundColor = highlighted ? config.selectedBackgroundColor : config.normalBackgroundColor
        }
    }
}
