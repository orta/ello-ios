//
//  StreamFooterCell.swift
//  Ello
//
//  Created by Sean Dougherty on 12/10/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

let streamCellDidOpenNotification = TypedNotification<UICollectionViewCell>(name: "StreamCellDidOpenNotification")

public class StreamFooterCell: UICollectionViewCell {
    public var indexPath = NSIndexPath(forItem: 0, inSection: 0)
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

    public let viewsItem = ElloPostToolBarOption.Views.barButtonItem()
    public var viewsControl: ImageLabelControl {
        return self.viewsItem.customView as! ImageLabelControl
    }

    public let lovesItem = ElloPostToolBarOption.Loves.barButtonItem()
    public var lovesControl: ImageLabelControl {
        return self.lovesItem.customView as! ImageLabelControl
    }

    public let commentsItem = ElloPostToolBarOption.Comments.barButtonItem()
    public var commentsControl: ImageLabelControl {
        return self.commentsItem.customView as! ImageLabelControl
    }

    public let repostItem = ElloPostToolBarOption.Repost.barButtonItem()
    public var repostControl: ImageLabelControl {
        return self.repostItem.customView as! ImageLabelControl
    }

    public let flagItem = ElloPostToolBarOption.Flag.barButtonItem()
    public var flagControl: ImageLabelControl {
        return self.flagItem.customView as! ImageLabelControl
    }

    public let shareItem = ElloPostToolBarOption.Share.barButtonItem()
    public var shareControl: ImageLabelControl {
        return self.shareItem.customView as! ImageLabelControl
    }

    public let replyItem = ElloPostToolBarOption.Reply.barButtonItem()
    public var replyControl: ImageLabelControl {
        return self.replyItem.customView as! ImageLabelControl
    }

    public let deleteItem = ElloPostToolBarOption.Delete.barButtonItem()
    public var deleteControl: ImageLabelControl {
       return self.deleteItem.customView as! ImageLabelControl
    }

    public let editItem = ElloPostToolBarOption.Edit.barButtonItem()
    public var editControl: ImageLabelControl {
       return self.editItem.customView as! ImageLabelControl
    }

    private func updateButtonVisibility(button: UIControl, visibility: InteractionVisibility) {
        button.hidden = !visibility.isVisible
        button.enabled = visibility.isEnabled
        button.selected = visibility.isSelected
    }

    public func updateToolbarItems(
        streamKind streamKind: StreamKind,
        repostVisibility: InteractionVisibility,
        commentVisibility: InteractionVisibility,
        shareVisibility: InteractionVisibility,
        deleteVisibility: InteractionVisibility,
        editVisibility: InteractionVisibility,
        loveVisibility: InteractionVisibility
        )
    {
        updateButtonVisibility(self.repostControl, visibility: repostVisibility)
        updateButtonVisibility(self.lovesControl, visibility: loveVisibility)
        var toolbarItems: [UIBarButtonItem] = []

        if streamKind.isGridView {

            toolbarItems.append(fixedItem(-15))
            if commentVisibility.isVisible {
                toolbarItems.append(commentsItem)
            }

            if loveVisibility.isVisible {
                toolbarItems.append(lovesItem)
            }

            if repostVisibility.isVisible {
                toolbarItems.append(repostItem)
            }

            self.toolBar.items = toolbarItems
            self.bottomToolBar.items = []
        }
        else {
            toolbarItems.append(viewsItem)

            if commentVisibility.isVisible {
                toolbarItems.append(commentsItem)
            }

            if loveVisibility.isVisible {
                toolbarItems.append(lovesItem)
            }

            if repostVisibility.isVisible {
                toolbarItems.append(repostItem)
            }
            self.toolBar.items = toolbarItems

            var bottomItems: [UIBarButtonItem] = [flexibleItem()]
            if shareVisibility.isVisible {
                bottomItems.append(shareItem)
            }

            if editVisibility.isVisible {
                bottomItems.append(editItem)
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

        // the bottomItems affet the scrollview contentSize
        self.setNeedsLayout()
    }

    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
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
        chevronButton.setImages(.AngleBracket)

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
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
                nextTick {
                    UIView.animateWithDuration(0.25) {
                        self.close()
                    }
                }
            }
        }
    }

    private func addButtonHandlers() {
        flagControl.addTarget(self, action: Selector("flagButtonTapped"), forControlEvents: .TouchUpInside)
        commentsControl.addTarget(self, action: Selector("commentsButtonTapped"), forControlEvents: .TouchUpInside)
        lovesControl.addTarget(self, action: Selector("lovesButtonTapped"), forControlEvents: .TouchUpInside)
        replyControl.addTarget(self, action: Selector("replyButtonTapped"), forControlEvents: .TouchUpInside)
        repostControl.addTarget(self, action: Selector("repostButtonTapped"), forControlEvents: .TouchUpInside)
        shareControl.addTarget(self, action: Selector("shareButtonTapped"), forControlEvents: .TouchUpInside)
        viewsControl.addTarget(self, action: Selector("viewsButtonTapped"), forControlEvents: .TouchUpInside)
        deleteControl.addTarget(self, action: Selector("deleteButtonTapped"), forControlEvents: .TouchUpInside)
        editControl.addTarget(self, action: Selector("editButtonTapped"), forControlEvents: .TouchUpInside)
    }

// MARK: - IBActions

    @IBAction func viewsButtonTapped() {
        delegate?.viewsButtonTapped(self.indexPath)
    }

    @IBAction func commentsButtonTapped() {
        commentsOpened = !commentsOpened
        delegate?.commentsButtonTapped(self, imageLabelControl: commentsControl)
    }

    func cancelCommentLoading() {
        commentsControl.enabled = true
        commentsControl.finishAnimation()
        commentsControl.selected = false
        commentsOpened = false
    }

    @IBAction func lovesButtonTapped() {
        delegate?.lovesButtonTapped(self, indexPath: self.indexPath)
    }

    @IBAction func repostButtonTapped() {
        delegate?.repostButtonTapped(self.indexPath)
    }

    @IBAction func flagButtonTapped() {
        delegate?.flagPostButtonTapped(self.indexPath)
    }

    @IBAction func shareButtonTapped() {
        delegate?.shareButtonTapped(self.indexPath, sourceView: shareControl)
    }

    @IBAction func deleteButtonTapped() {
        delegate?.deletePostButtonTapped(self.indexPath)
    }

    @IBAction func editButtonTapped() {
        if commentsOpened {
            commentsOpened = false
            delegate?.commentsButtonTapped(self, imageLabelControl: commentsControl)
        }

        delegate?.editPostButtonTapped(self.indexPath)
        animate(delay: 0.5) {
            self.close()
        }
    }

    @IBAction func replyButtonTapped() {
    }

    @IBAction func chevronButtonTapped() {
        let contentOffset = isOpen ? CGPointZero : CGPointMake(revealWidth, 0)
        UIView.animateWithDuration(0.25) {
            self.scrollView.contentOffset = contentOffset
            self.openChevron(isOpen: self.isOpen)
        }
        Tracker.sharedTracker.postBarVisibilityChanged(isOpen)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        let newBounds = CGRect(x: 0, y: 0, width: bounds.width, height: 44)
        contentView.frame = newBounds
        innerContentView.frame = newBounds
        containerView.frame = newBounds
        scrollView.frame = newBounds
        toolBar.frame = newBounds
        bottomToolBar.frame = newBounds
        chevronButton.frame = CGRect(
            x: newBounds.width - 40,
            y: newBounds.height/2 - 22,
            width: 40,
            height: 44
        )
        scrollView.contentSize = CGSize(width: contentView.frame.size.width + revealWidth, height: contentView.frame.size.height)
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
            postNotification(streamCellDidOpenNotification, value: self)
            Tracker.sharedTracker.postBarVisibilityChanged(isOpen)
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
