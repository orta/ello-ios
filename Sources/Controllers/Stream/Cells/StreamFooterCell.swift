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

class StreamFooterCell: UICollectionViewCell {

    let revealWidth:CGFloat = 85.0
    var cellOpenObserver: NotificationObserver?
    var isOpen = false

    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var chevronButton: StreamFooterButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var innerContentView: UIView!
    @IBOutlet weak var bottomContentView: UIView!
    var commentsOpened = false
    weak var delegate: PostbarDelegate?

    let viewsItem:UIBarButtonItem = ElloPostToolBarOption.Views.barButtonItem()
    var viewsButton:StreamFooterButton {
        get { return self.viewsItem.customView as! StreamFooterButton }
    }

    let lovesItem:UIBarButtonItem = ElloPostToolBarOption.Loves.barButtonItem()
    var lovesButton:StreamFooterButton {
        get { return self.lovesItem.customView as! StreamFooterButton }
    }

    let commentsItem:UIBarButtonItem = ElloPostToolBarOption.Comments.barButtonItem()
    var commentsButton:CommentButton {
        get { return self.commentsItem.customView as! CommentButton }
    }

    let repostItem:UIBarButtonItem = ElloPostToolBarOption.Repost.barButtonItem()
    var repostButton:StreamFooterButton {
        get { return self.repostItem.customView as! StreamFooterButton }
    }

    let flagItem:UIBarButtonItem = ElloPostToolBarOption.Flag.barButtonItem()
    var flagButton:StreamFooterButton {
        get { return self.flagItem.customView as! StreamFooterButton }
    }

    let shareItem:UIBarButtonItem = ElloPostToolBarOption.Share.barButtonItem()
    var shareButton:StreamFooterButton {
        get { return self.shareItem.customView as! StreamFooterButton }
    }

    let replyItem:UIBarButtonItem = ElloPostToolBarOption.Reply.barButtonItem()
    var replyButton:StreamFooterButton {
        get { return self.replyItem.customView as! StreamFooterButton }
    }


    var streamKind:StreamKind? {
        didSet {
            if let streamKind = streamKind {
                if streamKind.isGridLayout {
                    self.toolBar.items = [
                        commentsItem, lovesItem, repostItem
                    ]
                    self.bottomToolBar.items = [
                    ]
                }
                else {
                    self.toolBar.items = [
                        fixedItem(-15), commentsItem, flexibleItem(), repostItem, shareItem, fixedItem(-17)
                    ]
                    self.bottomToolBar.items = [
                        flexibleItem(), shareItem, flagItem
                    ]
                }
            }
        }
    }

    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
    }

    override func awakeFromNib() {
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

    var views:String? {
        get { return viewsButton.titleForState(.Normal) }
        set { viewsButton.setButtonTitleWithPadding(newValue) }
    }

    var comments:String? {
        get { return commentsButton.titleForState(.Normal) }
        set {
            commentsButton.setButtonTitleWithPadding(newValue, titlePadding: 13.0, contentPadding: 15.0)
            commentsButton.titleLabel?.sizeToFit()
        }
    }

    var loves:String? {
        get { return lovesButton.titleForState(.Normal) }
        set { lovesButton.setButtonTitleWithPadding(newValue) }
    }

    var reposts:String? {
        get { return repostButton.titleForState(.Normal) }
        set { repostButton.setButtonTitleWithPadding(newValue) }
    }

// MARK: - Private

    private func fixedItem(width:CGFloat) -> UIBarButtonItem {
        let item =  UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil, action: nil)
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
                        self.scrollView.contentOffset = CGPointZero
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
    }

// MARK: - IBActions

    @IBAction func viewsButtonTapped(sender: StreamFooterButton) {
        delegate?.viewsButtonTapped(self)
    }

    @IBAction func commentsButtonTapped(sender: CommentButton) {
        if !commentsOpened {
            sender.animate()
        }
        sender.selected = !commentsOpened
        delegate?.commentsButtonTapped(self, commentsButton: sender)
        commentsOpened = !commentsOpened
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

    @IBAction func replyButtonTapped(sender: StreamFooterButton) {
        println("reply tapped")
    }

    @IBAction func chevronButtonTapped(sender: StreamFooterButton) {
        let contentOffset = isOpen ? CGPointZero : CGPointMake(revealWidth, 0)
        dispatch_async(dispatch_get_main_queue(), {
            UIView.animateWithDuration(0.25, animations: {
                self.scrollView.contentOffset = contentOffset
            })
        })
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        innerContentView.frame = bounds
        containerView.frame = bounds
        scrollView.frame = bounds
        toolBar.frame = bounds
        bottomToolBar.frame = bounds
        chevronButton.frame = CGRectMake(bounds.width - chevronButton.bounds.width - 10, bounds.height/2 - chevronButton.bounds.height/2, chevronButton.bounds.size.width, chevronButton.bounds.size.height)
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

    func scrollViewDidScroll(scrollView: UIScrollView) {
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

    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if (velocity.x > 0) {
            targetContentOffset.memory.x = revealWidth
        }
        else {
            targetContentOffset.memory.x = 0
        }
    }

}