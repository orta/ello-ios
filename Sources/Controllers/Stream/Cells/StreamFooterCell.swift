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

    var revealWidth: CGFloat {
        if let items = bottomToolBar.items {
            let numberOfSpacingItems = 2
            let itemWidth = CGFloat(57.0)
            return itemWidth * CGFloat(items.count - numberOfSpacingItems)
        }
        return 0
    }
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

    let viewsItem = ElloPostToolBarOption.Views.barButtonItem()
    public var viewsControl: ImageLabelControl {
        return self.viewsItem.customView as! ImageLabelControl
    }

    let lovesItem = ElloPostToolBarOption.Loves.barButtonItem()
    public var lovesControl: ImageLabelControl {
        return self.lovesItem.customView as! ImageLabelControl
    }

    let commentsItem = ElloPostToolBarOption.Comments.barButtonItem()
    public var commentsControl: ImageLabelControl {
        return self.commentsItem.customView as! ImageLabelControl
    }

    let repostItem = ElloPostToolBarOption.Repost.barButtonItem()
    public var repostControl: ImageLabelControl {
        return self.repostItem.customView as! ImageLabelControl
    }

    let flagItem = ElloPostToolBarOption.Flag.barButtonItem()
    public var flagControl: ImageLabelControl {
        return self.flagItem.customView as! ImageLabelControl
    }

    let shareItem = ElloPostToolBarOption.Share.barButtonItem()
    public var shareControl: ImageLabelControl {
        return self.shareItem.customView as! ImageLabelControl
    }

    let replyItem = ElloPostToolBarOption.Reply.barButtonItem()
    public var replyControl: ImageLabelControl {
        return self.replyItem.customView as! ImageLabelControl
    }

    let deleteItem = ElloPostToolBarOption.Delete.barButtonItem()
    public var deleteControl: ImageLabelControl {
       return self.deleteItem.customView as! ImageLabelControl
    }

    private func updateButtonVisibility(button: UIControl, visibility: InteractionVisibility) {
        button.hidden = !visibility.isVisible
        button.enabled = visibility.isEnabled
    }

    public func updateToolbarItems(
        #streamKind: StreamKind,
        repostVisibility: InteractionVisibility,
        commentVisibility: InteractionVisibility,
        shareVisibility: InteractionVisibility,
        deleteVisibility: InteractionVisibility
        )
    {
        updateButtonVisibility(self.repostControl, visibility: repostVisibility)

        var toolbarItems: [UIBarButtonItem] = []

        if streamKind.isGridLayout {
            if commentVisibility.isVisible {
                toolbarItems.append(fixedItem(-15))
                toolbarItems.append(commentsItem)
            }

            if repostVisibility.isVisible || shareVisibility.isVisible {
                toolbarItems.append(flexibleItem())
                if repostVisibility.isVisible {
                    toolbarItems.append(repostItem)
                }
                if shareVisibility.isVisible {
                    toolbarItems.append(shareItem)
                }
                toolbarItems.append(fixedItem(-10))
            }

            self.toolBar.items = toolbarItems
            self.bottomToolBar.items = []
        }
        else {
            toolbarItems.append(viewsItem)
            if commentVisibility.isVisible {
                toolbarItems.append(commentsItem)
            }
            if repostVisibility.isVisible {
                toolbarItems.append(repostItem)
            }
            self.toolBar.items = toolbarItems

            var bottomItems: [UIBarButtonItem] = [flexibleItem()]
            if shareVisibility.isVisible {
                bottomItems.append(shareItem)
            }
            if deleteVisibility.isVisible {
                bottomItems.append(deleteItem)
            }
            else {
                bottomItems.append(flagItem)
            }
            bottomItems.append(fixedItem(-10))
            self.bottomToolBar.items = bottomItems
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
        get { return viewsControl.title }
        set { viewsControl.title = newValue }
    }

    public var comments:String? {
        get { return commentsControl.title }
        set { commentsControl.title = newValue }
    }

    public var loves:String? {
        get { return lovesControl.title }
        set { lovesControl.title = newValue }
    }

    public var reposts:String? {
        get { return repostControl.title }
        set { repostControl.title = newValue }
    }

    public func close() {
        isOpen = false
        closeChevron()
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
                    }
                }
            }
        }
    }

    private func addButtonHandlers() {
        flagControl.addTarget(self, action: Selector("flagButtonTapped:"), forControlEvents: .TouchUpInside)
        commentsControl.addTarget(self, action: Selector("commentsButtonTapped:"), forControlEvents: .TouchUpInside)
        lovesControl.addTarget(self, action: Selector("lovesButtonTapped:"), forControlEvents: .TouchUpInside)
        replyControl.addTarget(self, action: Selector("replyButtonTapped:"), forControlEvents: .TouchUpInside)
        repostControl.addTarget(self, action: Selector("repostButtonTapped:"), forControlEvents: .TouchUpInside)
        shareControl.addTarget(self, action: Selector("shareButtonTapped:"), forControlEvents: .TouchUpInside)
        viewsControl.addTarget(self, action: Selector("viewsButtonTapped:"), forControlEvents: .TouchUpInside)
        deleteControl.addTarget(self, action: Selector("deleteButtonTapped:"), forControlEvents: .TouchUpInside)
    }

// MARK: - IBActions

    @IBAction func viewsButtonTapped(sender: ImageLabelControl) {
        delegate?.viewsButtonTapped(self)
    }

    @IBAction func commentsButtonTapped(sender: ImageLabelControl) {
        commentsOpened = !commentsOpened
        delegate?.commentsButtonTapped(self, imageLabelControl: sender)
    }

    func cancelCommentLoading() {
        commentsControl.enabled = true
        commentsControl.finishAnimation()
        commentsControl.selected = false
        commentsOpened = false
    }

    @IBAction func lovesButtonTapped(sender: ImageLabelControl) {
        delegate?.lovesButtonTapped(self)
    }

    @IBAction func repostButtonTapped(sender: ImageLabelControl) {
        delegate?.repostButtonTapped(self)
    }

    @IBAction func flagButtonTapped(sender: ImageLabelControl) {
        delegate?.flagPostButtonTapped(self)
    }

    @IBAction func shareButtonTapped(sender: ImageLabelControl) {
        delegate?.shareButtonTapped(self)
    }

    @IBAction func deleteButtonTapped(sender: ImageLabelControl) {
        delegate?.deletePostButtonTapped(self)
    }

    @IBAction func replyButtonTapped(sender: ImageLabelControl) {
        println("reply tapped")
    }

    @IBAction func chevronButtonTapped(sender: StreamFooterButton) {
        let contentOffset = isOpen ? CGPointZero : CGPointMake(revealWidth, 0)
        UIView.animateWithDuration(0.25) {
            self.scrollView.contentOffset = contentOffset
            self.openChevron(isOpen: self.isOpen)
        }
        Tracker.sharedTracker.postBarVisibilityChanged(isOpen)
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

extension StreamFooterCell {

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

// MARK: UIScrollViewDelegate
extension StreamFooterCell: UIScrollViewDelegate {

    public func scrollViewDidScroll(scrollView: UIScrollView) {
        repositionBottomContent()

        if scrollView.contentOffset.x < 0 {
            scrollView.contentOffset = CGPointZero;
        }

        if scrollView.contentOffset.x >= revealWidth {
            isOpen = true
            openChevron(isOpen: true)
            postNotification(streamCellDidOpenNotification, self)
            Tracker.sharedTracker.postBarVisibilityChanged(isOpen)
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
