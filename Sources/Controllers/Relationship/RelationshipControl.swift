//
//  RelationshipControl.swift
//  Ello
//
//  Created by Ryan Boyajian on 2/16/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

private let ViewHeight: CGFloat = 30
private let MinViewWidth: CGFloat = 105


public enum RelationshipControlStyle {
    case Default
    case ProfileView

    var starButtonMargin: CGFloat {
        switch self {
            case .ProfileView: return 10
            default: return 7
        }
    }

    var starButtonWidth: CGFloat {
        switch self {
            case .ProfileView: return 50
            default: return 30
        }
    }
}


public class RelationshipControl: UIView {
    let followingButton = FollowButton()
    let starButton = StarButton()
    var style: RelationshipControlStyle = .Default {
        didSet {
            starButton.style = style
        }
    }

    public var userId: String
    public var userAtName: String

    public weak var relationshipDelegate: RelationshipDelegate?
    public var relationshipPriority: RelationshipPriority = .None {
        didSet { updateRelationshipPriority() }
    }

    public var showStarButton = true {
        didSet {
            starButton.hidden = !showStarButton
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
        starButton.hidden = !showStarButton
        updateRelationshipPriority()
        backgroundColor = .clearColor()
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

        if showStarButton {
            totalSize.width += style.starButtonWidth + style.starButtonMargin
        }

        return totalSize
    }

    // MARK: IBActions

    @IBAction func starButtonTapped(sender: UIButton) {
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
        nextTick {
            let prevRelationshipPriority = self.relationshipPriority
            self.relationshipPriority = newRelationshipPriority
            relationshipDelegate.relationshipTapped(self.userId, relationshipPriority: newRelationshipPriority) { (status, relationship, isFinalValue) in
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
        addSubview(starButton)
        addSubview(followingButton)
    }

    private func addTargets() {
        followingButton.addTarget(self, action: Selector("followingButtonTapped:"), forControlEvents: .TouchUpInside)
        starButton.addTarget(self, action: Selector("starButtonTapped:"), forControlEvents: .TouchUpInside)
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
        starButton.config = config
        starButton.hidden = (relationshipPriority == .Mute) || !showStarButton

        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        let starButtonWidth: CGFloat

        if relationshipPriority != .Mute && showStarButton {
            starButton.frame = CGRect(x: frame.width - style.starButtonWidth, y: 0, width: style.starButtonWidth, height: ViewHeight)
            starButtonWidth = style.starButtonWidth + style.starButtonMargin
        }
        else {
            starButton.frame = CGRectZero
            starButtonWidth = 0
        }

        followingButton.frame = bounds.inset(top: 0, left: 0, bottom: 0, right: starButtonWidth)
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
            case .Starred: return InterfaceString.Starred.Title.localized
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
            case .None: return UIColor.clearColor()
            default: return .blackColor()
            }
        }

        var starBackgroundColor: UIColor {
            switch self {
            case .Starred: return UIColor.blackColor()
            default: return .clearColor()
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
            case .Starred, .Following: return InterfaceImage.CheckSmall.whiteImage
            default: return InterfaceImage.PlusSmall.selectedImage
            }
        }

        var highlightedImage: UIImage? {
            switch self {
            case .Muted, .Starred, .Following: return self.image
            default: return InterfaceImage.PlusSmall.whiteImage
            }
        }
    }

    class FollowButton: RoundedElloButton {
        private var config: Config = .None {
            didSet {
                setTitleColor(config.normalTextColor, forState: .Normal)
                setTitleColor(config.highlightedTextColor, forState: .Highlighted)
                setTitleColor(UIColor.greyC(), forState: .Disabled)
                setTitle(config.title, forState: .Normal)
                setImage(config.image, forState: .Normal)
                setImage(config.highlightedImage, forState: .Highlighted)
                borderColor = config.borderColor
            }
        }


        override func sharedSetup() {
            super.sharedSetup()
            contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 10)
            setImage(.PlusSmall, imageStyle: .Selected, forState: .Normal)

            config = .None
            backgroundColor = config.normalBackgroundColor
            borderColor = UIColor.greyE5()
        }

        override func updateOutline() {
            layer.borderColor = borderColor.CGColor
            backgroundColor = highlighted ? config.selectedBackgroundColor : config.normalBackgroundColor
        }
    }

    class StarButton: RoundedElloButton {
        var style: RelationshipControlStyle = .Default {
            didSet {
                updateStyle()
            }
        }

        private var config: Config = .None {
            didSet {
                updateOutline()
                updateStyle()
            }
        }

        override func sharedSetup() {
            super.sharedSetup()

            config = .None
            updateStyle()
        }

        override func updateStyle() {
            super.updateStyle()

            let selected = config.starred
            switch style {
                case .ProfileView:
                    if selected {
                        setImage(.Star, imageStyle: .White, forState: .Normal)
                    }
                    else {
                        setImage(.Star, imageStyle: .Normal, forState: .Normal)
                    }
                    setImage(.Star, imageStyle: .White, forState: .Highlighted)
                    layer.borderWidth = 1
                    backgroundColor = config.starBackgroundColor
                    imageEdgeInsets.top = -1
                default:
                    if selected {
                        setImage(.Star, imageStyle: .Selected, forState: .Normal)
                    }
                    else {
                        setImage(.Star, imageStyle: .Normal, forState: .Normal)
                    }
                    setImage(.Star, imageStyle: .Selected, forState: .Highlighted)
                    layer.borderWidth = 0
                    backgroundColor = .clearColor()
                    imageEdgeInsets.top = 0
            }

        }
    }
}
