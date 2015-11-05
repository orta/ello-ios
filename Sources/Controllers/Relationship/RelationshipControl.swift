//
//  RelationshipControl.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/16/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import SVGKit

private let ViewHeight: CGFloat = 30
private let ButtonWidth: CGFloat = 30
private let StarredButtonMargin: CGFloat = 7
private let MinViewWidth: CGFloat = 105


public class RelationshipControl: UIView {
    let followingButton = FollowButton()
    let starredButton: UIButton = {
        let button = UIButton()
        button.setImage(SVGKImage(named: "star_normal.svg").UIImage!, forState: .Normal)
        button.setImage(SVGKImage(named: "star_selected.svg").UIImage!, forState: .Highlighted)
        return button
    }()

    public var userId: String
    public var userAtName: String

    public weak var relationshipDelegate: RelationshipDelegate?
    public var relationshipPriority: RelationshipPriority = .None {
        didSet { updateRelationshipPriority() }
    }

    public var showStarredButton = true {
        didSet {
            starredButton.hidden = !showStarredButton
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
        starredButton.hidden = !showStarredButton
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

        if showStarredButton {
            totalSize.width += ButtonWidth + StarredButtonMargin
        }

        return totalSize
    }

    // MARK: IBActions

    @IBAction func starredButtonTapped(sender: UIButton) {
        switch relationshipPriority {
        case .Mute:
            launchUnmuteModal()
        case .Starred:
            handleUnstar()
        default:
            handleStar()
        }
    }

    @IBAction func followingButtonTapped(sender: UIButton) {
        switch relationshipPriority {
        case .Mute:
            launchUnmuteModal()
        case .Following:
            handleUnfollow()
        case .Starred:
            handleUnstar()
        default:
            handleFollow()
        }
    }

    private func launchUnmuteModal() {
        guard relationshipPriority == .Mute else {
            return
        }

        guard let relationshipDelegate = relationshipDelegate else {
            return
        }

        relationshipDelegate.launchBlockModal(userId, userAtName: userAtName, relationshipPriority: relationshipPriority) { relationshipPriority in
            self.relationshipPriority = relationshipPriority
        }
    }

    private func handleRelationship(newRelationshipPriority: RelationshipPriority) {
        guard let relationshipDelegate = relationshipDelegate else {
            return
        }

        self.userInteractionEnabled = false
        let prevRelationshipPriority = self.relationshipPriority
        self.relationshipPriority = newRelationshipPriority
        relationshipDelegate.relationshipTapped(userId, relationshipPriority: newRelationshipPriority) { (status, relationship, isFinalValue) in
            if isFinalValue {
                self.userInteractionEnabled = true
            }

            if let newRelationshipPriority = relationship?.subject?.relationshipPriority {
                self.relationshipPriority = newRelationshipPriority
            }
            else {
                self.relationshipPriority = prevRelationshipPriority
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
        addSubview(starredButton)
        addSubview(followingButton)
    }

    private func addTargets() {
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

        let starredButtonWidth: CGFloat

        if showStarredButton {
            starredButton.frame = CGRect(x: frame.width - ButtonWidth, y: 0, width: ButtonWidth, height: ViewHeight)
            starredButtonWidth = ButtonWidth + StarredButtonMargin
        }
        else {
            starredButton.frame = CGRectZero
            starredButtonWidth = 0
        }

        followingButton.frame = bounds.inset(top: 0, left: 0, bottom: 0, right: starredButtonWidth)
    }

    private enum Config {
        case Starred
        case Following
        case Muted
        case None

        var title: String {
            switch self {
            case .None: return NSLocalizedString("Follow", comment: "Follow button title")
            case .Following: return InterfaceString.Following.Title.localized
//            case .Starred: return InterfaceString.Starred.Title.localized
            case .Starred: return NSLocalizedString("Starred", comment: "Starred button title")
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
