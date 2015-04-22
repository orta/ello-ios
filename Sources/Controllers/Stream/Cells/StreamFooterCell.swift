//
//  StreamFooterCell.swift
//  Ello
//
//  Created by Sean Dougherty on 12/10/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import Foundation

let streamCellDidOpenNotification = TypedNotification<UICollectionViewCell>(name: "StreamCellDidOpenNotification")

public class StreamFooterCell: UICollectionViewCell {

    let revealWidth:CGFloat = 85.0
    var cellOpenObserver: NotificationObserver?
    public private(set) var isOpen = false

    @IBOutlet weak public var toolBar: UIToolbar!
    @IBOutlet weak public var bottomToolBar: UIToolbar!
    @IBOutlet weak public var chevronButton: StreamFooterButton!
    @IBOutlet weak public var scrollView: UIScrollView!
    @IBOutlet weak public var containerView: UIView!
    @IBOutlet weak public var innerContentView: UIView!
    @IBOutlet weak public var bottomContentView: UIView!

    public var commentsOpened = false
    weak var delegate: PostbarDelegate?

    let viewsItem:UIBarButtonItem = ElloPostToolBarOption.Views.barButtonItem()
    public var viewsButton:StreamFooterButton {
        get { return self.viewsItem.customView as! StreamFooterButton }
    }

    let lovesItem:UIBarButtonItem = ElloPostToolBarOption.Loves.barButtonItem()
    public var lovesButton:StreamFooterButton {
        get { return self.lovesItem.customView as! StreamFooterButton }
    }

    let commentsItem:UIBarButtonItem = ElloPostToolBarOption.Comments.barButtonItem()
    public var commentsButton:CommentButton {
        get { return self.commentsItem.customView as! CommentButton }
    }

    let repostItem:UIBarButtonItem = ElloPostToolBarOption.Repost.barButtonItem()
    public var repostButton:StreamFooterButton {
        get { return self.repostItem.customView as! StreamFooterButton }
    }

    let flagItem:UIBarButtonItem = ElloPostToolBarOption.Flag.barButtonItem()
    public var flagButton:StreamFooterButton {
        get { return self.flagItem.customView as! StreamFooterButton }
    }

    let shareItem:UIBarButtonItem = ElloPostToolBarOption.Share.barButtonItem()
    public var shareButton:StreamFooterButton {
        get { return self.shareItem.customView as! StreamFooterButton }
    }

    let replyItem:UIBarButtonItem = ElloPostToolBarOption.Reply.barButtonItem()
    public var replyButton:StreamFooterButton {
        get { return self.replyItem.customView as! StreamFooterButton }
    }

    let deleteItem:UIBarButtonItem = ElloPostToolBarOption.Delete.barButtonItem()
    public var deleteButton:StreamFooterButton {
        get { return self.deleteItem.customView as! StreamFooterButton }
    }

    public var footerConfig: (ownPost: Bool, streamKind: StreamKind?) = (false, nil) {
        didSet {
            if let streamKind = footerConfig.streamKind {
                if streamKind.isGridLayout {
                    self.toolBar.items = [
                        fixedItem(-15), commentsItem, flexibleItem(), repostItem, shareItem, fixedItem(-17)
                    ]
                    self.bottomToolBar.items = [
                    ]
                }
                else {
                    self.toolBar.items = [
                        viewsItem, commentsItem, repostItem
                    ]
                    let rightItem = footerConfig.ownPost ? deleteItem : flagItem
                    self.bottomToolBar.items = [
                        flexibleItem(), shareItem, rightItem, fixedItem(-17)
                    ]
                }
            }
        }
    }

    override public func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        toolBar.translucent = false
        toolBar.barTintColor = UIColor.whiteColor()
        toolBar.clipsToBounds = true
        toolBar.layer.borderColor = UIColor.whiteColor().CGColor

        bottomToolBar.translucent = false
        bottomToolBar.barTintColor = UIColor.whiteColor()
        bottomToolBar.clipsToBounds = true
        bottomToolBar.layer.borderColor = UIColor.whiteColor().CGColor

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        addObservers()
        addButtonHandlers()
    }

    public var views:String? {
        get { return viewsButton.attributedTitleForState(.Normal)?.string }
        set { viewsButton.setButtonTitleWithPadding(newValue) }
    }

    public var comments:String? {
        get { return commentsButton.attributedTitleForState(.Normal)?.string }
        set {
            commentsButton.setButtonTitleWithPadding(newValue, titlePadding: 13.0, contentPadding: 15.0)
            commentsButton.titleLabel?.sizeToFit()
        }
    }

    public var loves:String? {
        get { return lovesButton.attributedTitleForState(.Normal)?.string }
        set { lovesButton.setButtonTitleWithPadding(newValue) }
    }

    public var reposts:String? {
        get { return repostButton.attributedTitleForState(.Normal)?.string }
        set { repostButton.setButtonTitleWithPadding(newValue) }
    }

    public func close() {
        isOpen = false
        scrollView.contentOffset = CGPointZero
    }

// MARK: - Private

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
                        self.openChevron()
                    }
                }
            }
        }
    }

    private func addButtonHandlers() {
        flagButton.addTarget(self, action: "flagButtonTapped:", forControlEvents: .TouchUpInside)
        commentsButton.addTarget(self, action: "commentsButtonTapped:", forControlEvents: .TouchUpInside)
        commentsButton.addTarget(self, action: "commentsButtonTouchDown:", forControlEvents: .TouchDown)
        lovesButton.addTarget(self, action: "lovesButtonTapped:", forControlEvents: .TouchUpInside)
        replyButton.addTarget(self, action: "replyButtonTapped:", forControlEvents: .TouchUpInside)
        repostButton.addTarget(self, action: "repostButtonTapped:", forControlEvents: .TouchUpInside)
        shareButton.addTarget(self, action: "shareButtonTapped:", forControlEvents: .TouchUpInside)
        viewsButton.addTarget(self, action: "viewsButtonTapped:", forControlEvents: .TouchUpInside)
        deleteButton.addTarget(self, action: "deleteButtonTapped:", forControlEvents: .TouchUpInside)
    }

// MARK: - IBActions

    @IBAction func viewsButtonTapped(sender: StreamFooterButton) {
        delegate?.viewsButtonTapped(self)
    }

    @IBAction func commentsButtonTapped(sender: CommentButton) {
        if let streamKind = footerConfig.streamKind {
            if streamKind.isGridLayout {
                delegate?.viewsButtonTapped(self)
                return
            }
        }

        if !commentsOpened {
            sender.animate()
        }

        sender.selected = !commentsOpened
        delegate?.commentsButtonTapped(self, commentsButton: sender)
        commentsOpened = !commentsOpened
    }

    func cancelCommentLoading() {
        commentsButton.enabled = true
        commentsButton.finishAnimation()
        commentsButton.selected = false
        commentsOpened = false
    }

    @IBAction func commentsButtonTouchDown(sender: CommentButton) {
        sender.highlighted = true
    }

    @IBAction func lovesButtonTapped(sender: StreamFooterButton) {
        delegate?.lovesButtonTapped(self)
    }

    @IBAction func repostButtonTapped(sender: StreamFooterButton) {
        delegate?.repostButtonTapped(self)
    }

    @IBAction func flagButtonTapped(sender: StreamFooterButton) {
        delegate?.flagPostButtonTapped(self)
    }

    @IBAction func shareButtonTapped(sender: StreamFooterButton) {
        delegate?.shareButtonTapped(self)
    }

    @IBAction func deleteButtonTapped(sender: StreamFooterButton) {
        delegate?.deletePostButtonTapped(self)
    }

    @IBAction func replyButtonTapped(sender: StreamFooterButton) {
        println("reply tapped")
    }

    @IBAction func chevronButtonTapped(sender: StreamFooterButton) {
        let contentOffset = isOpen ? CGPointZero : CGPointMake(revealWidth, 0)

        dispatch_async(dispatch_get_main_queue(), {
            UIView.animateWithDuration(0.25, animations: {
                self.scrollView.contentOffset = contentOffset
                self.openChevron(isOpen: self.isOpen)
            })
        })
    }

    private func openChevron(isOpen: Bool = true) {
        if isOpen {
            rotateChevron(CGFloat(M_PI))
        }
        else {
            rotateChevron(0)
        }
    }

    private func closeChevron() {
        openChevron(isOpen: false)
    }

    private func rotateChevron(var angle: CGFloat) {
        if angle < 0 {
            angle = 0
        }
        else if angle > CGFloat(M_PI) {
            angle = CGFloat(M_PI)
        }
        self.chevronButton.transform = CGAffineTransformMakeRotation(angle)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        let newBounds = CGRectMake(0, 0, bounds.width, 44)
        contentView.frame = newBounds
        innerContentView.frame = newBounds
        containerView.frame = newBounds
        scrollView.frame = newBounds
        toolBar.frame = newBounds
        bottomToolBar.frame = newBounds
        chevronButton.frame = CGRectMake(newBounds.width - chevronButton.bounds.width - 10, newBounds.height/2 - chevronButton.bounds.height/2, chevronButton.bounds.size.width, chevronButton.bounds.size.height)
        scrollView.contentSize = CGSizeMake(contentView.frame.size.width + revealWidth, scrollView.frame.size.height)
        repositionBottomContent()
    }

    private func repositionBottomContent() {
        var frame = bottomContentView.frame
        frame.size.height = innerContentView.bounds.height
        frame.size.width = innerContentView.bounds.width
        frame.origin.y = innerContentView.frame.origin.y
        frame.origin.x = scrollView.contentOffset.x
        bottomContentView.frame = frame
    }
}

// MARK: UIScrollViewDelegate
extension StreamFooterCell: UIScrollViewDelegate {

    public func scrollViewDidScroll(scrollView: UIScrollView) {
        repositionBottomContent()

        if (scrollView.contentOffset.x < 0) {
            scrollView.contentOffset = CGPointZero;
        }

        if (scrollView.contentOffset.x >= revealWidth) {
            isOpen = true
            openChevron()
            postNotification(streamCellDidOpenNotification, self)
        } else {
            var angle: CGFloat = CGFloat(M_PI) * scrollView.contentOffset.x / revealWidth
            rotateChevron(angle)
            isOpen = false
        }

        Tracker.sharedTracker.postBarVisibilityChanged(isOpen)
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
