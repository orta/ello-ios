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

    let revealWidth:CGFloat = 85.0
    var cellOpenObserver: NotificationObserver?
    var isOpen = false
    var maxUsernameWidth: CGFloat = 50.0

    @IBOutlet weak var avatarButton: AvatarButton!
    @IBOutlet weak var usernameTextView: ElloTextView!
    @IBOutlet weak var goToPostView: UIView!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var innerContentView: UIView!
    @IBOutlet weak var bottomContentView: UIView!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var chevronButton: StreamFooterButton!

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

    let flagItem:UIBarButtonItem = ElloPostToolBarOption.Flag.barButtonItem()
    var flagButton:StreamFooterButton {
        get { return self.flagItem.customView as! StreamFooterButton }
    }

    let replyItem:UIBarButtonItem = ElloPostToolBarOption.Reply.barButtonItem()
    var replyButton:StreamFooterButton {
        get { return self.replyItem.customView as! StreamFooterButton }
    }

    func setAvatarURL(url:NSURL?) {
        avatarButton.setAvatarURL(url)
    }

    private var originalUsernameFrame = CGRectZero

    override public func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
    }

    override public func awakeFromNib() {
        super.awakeFromNib()

        originalUsernameFrame = usernameTextView.frame
        bottomToolBar.translucent = false
        bottomToolBar.barTintColor = UIColor.whiteColor()
        bottomToolBar.clipsToBounds = true
        bottomToolBar.layer.borderColor = UIColor.whiteColor().CGColor

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        addObservers()
        addButtonHandlers()

        usernameTextView.textViewDelegate = self
        styleUsernameTextView()
        styleTimestampLabel()

        bottomToolBar.items = [
            flexibleItem(), replyItem, flagItem
        ]

        let goToPostTapRecognizer = UITapGestureRecognizer(target: self, action: "postTapped:")
        goToPostView.addGestureRecognizer(goToPostTapRecognizer)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        innerContentView.frame = bounds
        bottomContentView.frame = bounds
        containerView.frame = bounds
        scrollView.frame = bounds
        bottomToolBar.frame = scrollView.bounds
        scrollView.contentSize = CGSizeMake(contentView.frame.size.width + revealWidth, scrollView.frame.size.height)
        positionTopContent()
        repositionBottomContent()
    }

    func resetUsernameTextView() {
        usernameTextView.frame = originalUsernameFrame
        usernameTextView.textContainerInset = UIEdgeInsetsZero
    }

// MARK: - Private

    private func positionTopContent() {
        let sidePadding: CGFloat = 15.0
        let minimumUsernameWidth: CGFloat = 60.0

        avatarButton.frame = CGRectMake(sidePadding, innerContentView.frame.midY - avatarHeight/2, avatarHeight, avatarHeight)

        if chevronHidden {
            chevronButton.frame = CGRectMake(innerContentView.frame.width - sidePadding, innerContentView.frame.height/2 - chevronButton.bounds.height/2, 0, chevronButton.frame.height)
        }
        else {
            chevronButton.frame = CGRectMake(innerContentView.frame.width - chevronButton.bounds.width - sidePadding, innerContentView.frame.height/2 - chevronButton.bounds.height/2, chevronButton.frame.width, chevronButton.frame.height)
        }

        let timestampX = chevronButton.frame.x - timestampLabel.frame.width
        timestampLabel.frame = CGRectMake(timestampX, innerContentView.frame.midY - timestampLabel.frame.height/2, timestampLabel.frame.width, timestampLabel.frame.height)

        let usernameX = avatarButton.frame.maxX + sidePadding
        maxUsernameWidth = timestampX - usernameX
        let usernameWidth = max(minimumUsernameWidth, min(usernameTextView.frame.width, maxUsernameWidth))

        usernameTextView.frame = CGRectMake(usernameX, 0, usernameWidth, innerContentView.frame.height)

        var topoffset = (usernameTextView.frame.height - originalUsernameFrame.height) / 2.0

        topoffset = topoffset < 0.0 ? 0.0 : topoffset
        usernameTextView.textContainerInset = UIEdgeInsetsMake(topoffset, 0, 0, 0)

        goToPostView.frame = CGRectMake(usernameTextView.frame.maxX, 0, innerContentView.bounds.width - usernameTextView.frame.maxX, innerContentView.frame.height)
    }

    private func flexibleItem() -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: "")
    }

    private func addObservers() {
        cellOpenObserver = NotificationObserver(notification: streamCellDidOpenNotification) { cell in
            if cell != self && self.isOpen {
                dispatch_async(dispatch_get_main_queue()) {
                    UIView.animateWithDuration(0.25) {
                        self.scrollView.contentOffset = CGPointZero
                    }
                }
            }
        }
    }

    private func addButtonHandlers() {
        flagButton.addTarget(self, action: "flagButtonTapped:", forControlEvents: .TouchUpInside)
        replyButton.addTarget(self, action: "replyButtonTapped:", forControlEvents: .TouchUpInside)
    }

    private func styleUsernameTextView() {
        usernameTextView.customFont = UIFont.typewriterFont(14.0)
        usernameTextView.textColor = UIColor.greyA()
    }

    private func styleTimestampLabel() {
        timestampLabel.textColor = UIColor.greyA()
        timestampLabel.font = UIFont.typewriterFont(14.0)
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
        postbarDelegate?.viewsButtonTapped(self)
    }

    @IBAction func userTapped(sender: AvatarButton) {
        userDelegate?.userTappedCell(self)
    }

    @IBAction func flagButtonTapped(sender: StreamFooterButton) {
        postbarDelegate?.flagCommentButtonTapped(self)
    }

    @IBAction func replyButtonTapped(sender: StreamFooterButton) {
        postbarDelegate?.replyToCommentButtonTapped(self)
    }

    @IBAction func chevronButtonTapped(sender: StreamFooterButton) {
        let contentOffset = isOpen ? CGPointZero : CGPointMake(revealWidth, 0)
        dispatch_async(dispatch_get_main_queue(), {
            UIView.animateWithDuration(0.25, animations: {
                self.scrollView.contentOffset = contentOffset
            })
        })
    }

}

extension StreamHeaderCell: ElloTextViewDelegate {
    func textViewTapped(link: String, object: AnyObject?) {
        userDelegate?.userTappedCell(self)
    }
}

// MARK: UIScrollViewDelegate
extension StreamHeaderCell: UIScrollViewDelegate {

    public func scrollViewDidScroll(scrollView: UIScrollView) {
        repositionBottomContent()

        if (scrollView.contentOffset.x < 0) {
            scrollView.contentOffset = CGPointZero;
        }

        if (scrollView.contentOffset.x >= revealWidth) {
            isOpen = true
            postNotification(streamCellDidOpenNotification, self)
        } else {
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
