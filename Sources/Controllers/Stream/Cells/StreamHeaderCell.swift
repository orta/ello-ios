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
        if let items = bottomToolBar.items where count(items) == 5 {
            return 158.0
        }
        else {
            return 104.0
        }
    }

    var cellOpenObserver: NotificationObserver?
    var isOpen = false
    var maxUsernameWidth: CGFloat = 50.0

    @IBOutlet weak var avatarButton: AvatarButton!
    @IBOutlet weak var goToPostView: UIView!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var innerContentView: UIView!
    @IBOutlet weak var bottomContentView: UIView!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var chevronButton: StreamFooterButton!
    @IBOutlet weak var usernameButton: UIButton!
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

    let deleteItem = ElloPostToolBarOption.Delete.barButtonItem()
    public var deleteControl: ImageLabelControl {
        return self.deleteItem.customView as! ImageLabelControl
    }

    let replyItem = ElloPostToolBarOption.Reply.barButtonItem()
    public var replyControl: ImageLabelControl {
        return self.replyItem.customView as! ImageLabelControl
    }

    func setAvatarURL(url:NSURL?) {
        avatarButton.setAvatarURL(url)
    }

    override public func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
    }

    override public func awakeFromNib() {
        super.awakeFromNib()

        bottomToolBar.translucent = false
        bottomToolBar.barTintColor = UIColor.whiteColor()
        bottomToolBar.clipsToBounds = true
        bottomToolBar.layer.borderColor = UIColor.whiteColor().CGColor

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        addObservers()
        addButtonHandlers()

        styleUsernameButton()
        styleTimestampLabel()

        let goToPostTapRecognizer = UITapGestureRecognizer(target: self, action: Selector("postTapped:"))
        goToPostView.addGestureRecognizer(goToPostTapRecognizer)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
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

        if self.ownComment {
            bottomToolBar.items = [
                flexibleItem(), replyItem, deleteItem, fixedItem(-10)
            ]
        }
        else if self.ownPost {
            bottomToolBar.items = [
                flexibleItem(), replyItem, flagItem, deleteItem, fixedItem(-10)
            ]
        }
        else {
            bottomToolBar.items = [
                flexibleItem(), replyItem, flagItem, fixedItem(-10)
            ]
        }
    }

    private func positionTopContent() {
        let sidePadding: CGFloat = 15.0
        let minimumUsernameWidth: CGFloat = 44.0

        avatarButton.frame = CGRectMake(sidePadding, innerContentView.frame.midY - avatarHeight/2, avatarHeight, avatarHeight)

        if chevronHidden {
            chevronButton.frame = CGRectMake(innerContentView.frame.width - sidePadding, innerContentView.frame.height/2 - 22.0, 0, 44.0)
        }
        else {
            chevronButton.frame = CGRectMake(innerContentView.frame.width - 44.0, innerContentView.frame.height/2 - 22.0, 44.0, 44.0)
        }

        let timestampX = chevronButton.frame.x - timestampLabel.frame.width
        timestampLabel.frame = CGRectMake(timestampX, innerContentView.frame.midY - timestampLabel.frame.height/2, timestampLabel.frame.width, timestampLabel.frame.height)

        let usernameX = avatarButton.frame.maxX + sidePadding
        if !isGridLayout {
            maxUsernameWidth = timestampX - usernameX - sidePadding
        }
        else {
            maxUsernameWidth = innerContentView.frame.width - usernameX - sidePadding
        }
        let usernameWidth = max(minimumUsernameWidth, min(usernameButton.frame.width, maxUsernameWidth))

        usernameButton.frame = CGRectMake(usernameX, 0, usernameWidth, innerContentView.frame.height)

        var topoffset = usernameButton.frame.height / 2.0

        topoffset = topoffset < 0.0 ? 0.0 : topoffset

        goToPostView.frame = CGRectMake(usernameButton.frame.maxX, 0, innerContentView.bounds.width - usernameButton.frame.maxX, innerContentView.frame.height)
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
                dispatch_async(dispatch_get_main_queue()) {
                    UIView.animateWithDuration(0.25) {
                        self.close()
                    }
                }
            }
        }
    }

    private func addButtonHandlers() {
        flagControl.addTarget(self, action: Selector("flagButtonTapped:"), forControlEvents: .TouchUpInside)
        replyControl.addTarget(self, action: Selector("replyButtonTapped:"), forControlEvents: .TouchUpInside)
        deleteControl.addTarget(self, action: Selector("deleteButtonTapped:"), forControlEvents: .TouchUpInside)
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
        userDelegate?.userTappedCell(self)
    }

    @IBAction func usernameTapped(sender: UIButton) {
        userDelegate?.userTappedCell(self)
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

    private func openChevron(#isOpen: Bool) {
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
        userDelegate?.userTappedCell(self)
    }
}

// MARK: UIScrollViewDelegate
extension StreamHeaderCell: UIScrollViewDelegate {

    public func scrollViewDidScroll(scrollView: UIScrollView) {
        repositionBottomContent()

        if scrollView.contentOffset.x < 0 {
            scrollView.contentOffset = CGPointZero;
        }

        if scrollView.contentOffset.x >= revealWidth {
            isOpen = true
            openChevron(isOpen: true)
            postNotification(streamCellDidOpenNotification, self)
            Tracker.sharedTracker.commentBarVisibilityChanged(isOpen)
        } else {
            var angle: CGFloat = -CGFloat(M_PI) + CGFloat(M_PI) * scrollView.contentOffset.x / revealWidth
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
