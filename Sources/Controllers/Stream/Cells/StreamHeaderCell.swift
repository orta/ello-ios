//
//  StreamHeaderCell.swift
//  Ello
//
//  Created by Sean Dougherty on 11/22/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import Foundation

public class StreamHeaderCell: UICollectionViewCell {

    public var indexPath = NSIndexPath(forItem: 0, inSection: 0)
    public var ownPost = false {
        didSet {
            self.updateItems()
        }
    }

    public var ownComment = false {
        didSet {
            self.updateItems()
        }
    }
    var revealWidth: CGFloat {
        if let items = bottomToolBar.items where items.count == 4 {
            return 106.0
        }
        else {
            return 54.0
        }
    }
    public var canReply = false {
        didSet {
            self.setNeedsLayout()
        }
    }

    var cellOpenObserver: NotificationObserver?
    var isOpen = false

    weak var avatarButton: AvatarButton!
    @IBOutlet weak var goToPostView: UIView!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var innerContentView: UIView!
    @IBOutlet weak var bottomContentView: UIView!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var chevronButton: StreamFooterButton!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var replyButton: UIButton!
    var isGridLayout = false

    weak var postbarDelegate: PostbarDelegate?

    var avatarHeight: CGFloat = 60.0 {
        didSet { setNeedsDisplay() }
    }

    var timeStamp:String {
        get { return self.timestampLabel.text ?? "" }
        set {
            timestampLabel.text = newValue
            timestampLabel.sizeToFit()
            setNeedsLayout()
        }
    }

    var chevronHidden = false

    var streamKind:StreamKind?
    weak var userDelegate: UserDelegate?

    let flagItem = ElloPostToolBarOption.Flag.barButtonItem()
    public var flagControl: ImageLabelControl {
        return self.flagItem.customView as! ImageLabelControl
    }

    let editItem = ElloPostToolBarOption.Edit.barButtonItem()
    public var editControl: ImageLabelControl {
       return self.editItem.customView as! ImageLabelControl
    }

    let deleteItem = ElloPostToolBarOption.Delete.barButtonItem()
    public var deleteControl: ImageLabelControl {
        return self.deleteItem.customView as! ImageLabelControl
    }

    func setAvatarURL(url:NSURL?) {
        avatarButton.setAvatarURL(url)
    }

    override public func awakeFromNib() {
        super.awakeFromNib()

        bottomToolBar.translucent = false
        bottomToolBar.barTintColor = UIColor.whiteColor()
        bottomToolBar.clipsToBounds = true
        bottomToolBar.layer.borderColor = UIColor.whiteColor().CGColor

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        addObservers()
        addButtonHandlers()

        styleUsernameButton()
        styleTimestampLabel()

        let goToPostTapRecognizer = UITapGestureRecognizer(target: self, action: Selector("postTapped:"))
        goToPostView.addGestureRecognizer(goToPostTapRecognizer)

        replyButton.setTitle("", forState: .Normal)
        replyButton.setSVGImages("reply")
    }

    override public func layoutSubviews() {
        let timestampLabelSize = timestampLabel.frame.size
        super.layoutSubviews()
        timestampLabel.frame.size = timestampLabelSize
        contentView.frame = bounds
        innerContentView.frame = bounds
        bottomContentView.frame = bounds
        containerView.frame = bounds
        scrollView.frame = bounds
        bottomToolBar.frame = bounds
        chevronButton.setSVGImages("abracket")
        scrollView.contentSize = CGSizeMake(contentView.frame.size.width + revealWidth, scrollView.frame.size.height)
        positionTopContent()
        repositionBottomContent()
    }

// MARK: - Public

    public func updateUsername(username: String, isGridLayout: Bool = false) {
        self.isGridLayout = isGridLayout
        usernameButton.setTitle(username, forState: UIControlState.Normal)
        usernameButton.sizeToFit()
    }

    public func close() {
        isOpen = false
        closeChevron()
        scrollView.contentOffset = CGPointZero
    }

// MARK: - Private

    private func updateItems() {
        if ownComment {
            bottomToolBar.items = [
                flexibleItem(), editItem, deleteItem, fixedItem(-10)
            ]
        }
        else if ownPost {
            bottomToolBar.items = [
                flexibleItem(), flagItem, deleteItem, fixedItem(-10)
            ]
        }
        else {
            bottomToolBar.items = [
                flexibleItem(), flagItem, fixedItem(-10)
            ]
        }
    }

    private func positionTopContent() {
        let sidePadding: CGFloat = 15
        let timestampMargin: CGFloat = 11.5
        let buttonWidth: CGFloat = 30
        let buttonMargin: CGFloat = 5
        let minimumUsernameWidth: CGFloat = 44

        avatarButton.frame = CGRect(
            x: sidePadding,
            y: innerContentView.frame.midY - avatarHeight/2,
            width: avatarHeight,
            height: avatarHeight
            )
        let usernameX = avatarButton.frame.maxX + sidePadding

        if chevronHidden {
            chevronButton.frame = CGRect(
                x: innerContentView.frame.width - sidePadding,
                y: 0,
                width: 0,
                height: frame.height
                )
        }
        else {
            chevronButton.frame = CGRect(
                x: innerContentView.frame.width - buttonWidth - buttonMargin,
                y: 0,
                width: buttonWidth,
                height: frame.height
                )
        }

        var timestampX = chevronButton.frame.x - timestampLabel.frame.width

        replyButton.frame.size.width = buttonWidth
        replyButton.frame.origin.x = timestampX - buttonWidth - buttonMargin - buttonMargin - sidePadding
        replyButton.hidden = isGridLayout || !canReply

        var maxUsernameWidth: CGFloat = 0
        if !isGridLayout {
            maxUsernameWidth = timestampX - usernameX - sidePadding

            if canReply {
                maxUsernameWidth -= replyButton.frame.width - timestampMargin
                timestampX -= timestampMargin
            }
        }
        else {
            maxUsernameWidth = innerContentView.frame.width - usernameX - sidePadding
        }

        timestampLabel.frame = CGRect(
            x: timestampX,
            y: innerContentView.frame.midY - timestampLabel.frame.height / 2,
            width: timestampLabel.frame.width,
            height: timestampLabel.frame.height
            )

        let usernameWidth = max(minimumUsernameWidth, min(usernameButton.frame.width, maxUsernameWidth))

        usernameButton.frame = CGRect(
            x: usernameX,
            y: 0,
            width: usernameWidth,
            height: innerContentView.frame.height
            )

        var topoffset = usernameButton.frame.height / 2

        topoffset = topoffset < 0.0 ? 0.0 : topoffset

        goToPostView.frame = CGRect(
            x: usernameButton.frame.maxX,
            y: 0,
            width: innerContentView.bounds.width - usernameButton.frame.maxX,
            height: innerContentView.frame.height
            )
    }

    private func fixedItem(width:CGFloat) -> UIBarButtonItem {
        let item = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
        item.width = width
        return item
    }

    private func flexibleItem() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: "")
    }

    private func addObservers() {
        cellOpenObserver = NotificationObserver(notification: streamCellDidOpenNotification) { cell in
            if cell != self && self.isOpen {
                nextTick {
                    animate(0.25) {
                        self.close()
                    }
                }
            }
        }
    }

    private func addButtonHandlers() {
        flagControl.addTarget(self, action: Selector("flagButtonTapped:"), forControlEvents: .TouchUpInside)
        replyButton.addTarget(self, action: Selector("replyButtonTapped:"), forControlEvents: .TouchUpInside)
        deleteControl.addTarget(self, action: Selector("deleteButtonTapped:"), forControlEvents: .TouchUpInside)
        editControl.addTarget(self, action: Selector("editButtonTapped:"), forControlEvents: .TouchUpInside)
    }

    private func styleUsernameButton() {
        usernameButton.titleLabel?.font = UIFont.typewriterFont(12.0)
        usernameButton.setTitleColor(UIColor.greyA(), forState: UIControlState.Normal)
        usernameButton.titleLabel?.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        usernameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
    }

    private func styleTimestampLabel() {
        timestampLabel.textColor = UIColor.greyA()
        timestampLabel.font = UIFont.typewriterFont(12.0)
    }

    private func repositionBottomContent() {
        var frame = bottomContentView.frame
        frame.size.height = innerContentView.bounds.height
        frame.size.width = innerContentView.bounds.width
        frame.origin.y = innerContentView.frame.origin.y
        frame.origin.x = scrollView.contentOffset.x
        bottomContentView.frame = frame
    }

// MARK: - IBActions

    func postTapped(recognizer: UITapGestureRecognizer) {
        postbarDelegate?.viewsButtonTapped(self.indexPath)
    }

    @IBAction func userTapped(sender: AvatarButton) {
        userDelegate?.userTappedAvatar(self)
    }

    @IBAction func usernameTapped(sender: UIButton) {
        userDelegate?.userTappedAvatar(self)
    }

    @IBAction func flagButtonTapped(sender: StreamFooterButton) {
        postbarDelegate?.flagCommentButtonTapped(self.indexPath)
    }

    @IBAction func replyButtonTapped(sender: StreamFooterButton) {
        postbarDelegate?.replyToCommentButtonTapped(self.indexPath)
    }

    @IBAction func deleteButtonTapped(sender: StreamFooterButton) {
        postbarDelegate?.deleteCommentButtonTapped(self.indexPath)
    }

    @IBAction func editButtonTapped(sender: StreamFooterButton) {
        postbarDelegate?.editCommentButtonTapped(self.indexPath)
    }

    @IBAction func chevronButtonTapped(sender: StreamFooterButton) {
        let contentOffset = isOpen ? CGPointZero : CGPointMake(revealWidth, 0)
        UIView.animateWithDuration(0.25) {
            self.scrollView.contentOffset = contentOffset
            self.openChevron(isOpen: self.isOpen)
        }
        Tracker.sharedTracker.commentBarVisibilityChanged(isOpen)
    }

}

extension StreamHeaderCell {

    private func openChevron(isOpen isOpen: Bool) {
        if isOpen {
            rotateChevron(CGFloat(0))
        }
        else {
            rotateChevron(CGFloat(M_PI))
        }
    }

    private func closeChevron() {
        openChevron(isOpen: false)
    }

    private func rotateChevron(var angle: CGFloat) {
        if angle < CGFloat(-M_PI) {
            angle = CGFloat(-M_PI)
        }
        else if angle > CGFloat(M_PI) {
            angle = CGFloat(M_PI)
        }
        self.chevronButton.transform = CGAffineTransformMakeRotation(angle)
    }

}

extension StreamHeaderCell: ElloTextViewDelegate {
    func textViewTapped(link: String, object: ElloAttributedObject) {
        userDelegate?.userTappedAvatar(self)
    }
    func textViewTappedDefault() {}
}

// MARK: UIScrollViewDelegate
extension StreamHeaderCell: UIScrollViewDelegate {

    public func scrollViewDidScroll(scrollView: UIScrollView) {
        repositionBottomContent()

        if scrollView.contentOffset.x < 0 {
            scrollView.contentOffset = CGPointZero;
        }

        if scrollView.contentOffset.x >= revealWidth {
            if !isOpen {
                isOpen = true
                openChevron(isOpen: true)
                postNotification(streamCellDidOpenNotification, value: self)
                Tracker.sharedTracker.commentBarVisibilityChanged(true)
            }
        } else {
            let angle: CGFloat = -CGFloat(M_PI) + CGFloat(M_PI) * scrollView.contentOffset.x / revealWidth
            rotateChevron(angle)
            isOpen = false
        }
    }

    public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if (velocity.x > 0) {
            targetContentOffset.memory.x = revealWidth
        }
        else {
            targetContentOffset.memory.x = 0
        }
    }

}
