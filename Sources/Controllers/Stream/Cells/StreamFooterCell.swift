//
//  StreamFooterCell.swift
//  Ello
//
//  Created by Sean Dougherty on 12/10/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import Foundation




class StreamFooterCell: UICollectionViewCell, UIScrollViewDelegate {

    let revealWidth:CGFloat = 160.0
    var isOpen = false

    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var chevronButton: StreamFooterButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var innerContentView: UIView!
    var commentsOpened = false
    weak var delegate: PostbarDelegate?

    let viewsItem:UIBarButtonItem = ElloPostToolBarOption.Views.barButtonItem()
    var viewsButton:StreamFooterButton {
        get {
            let button = self.viewsItem.customView as StreamFooterButton
            button.addTarget(self, action: "viewsButtonTapped:", forControlEvents: .TouchUpInside)
            return button
        }
    }

    let lovesItem:UIBarButtonItem = ElloPostToolBarOption.Loves.barButtonItem()
    var lovesButton:StreamFooterButton {
        get {
            let button = self.lovesItem.customView as StreamFooterButton
            button.addTarget(self, action: "lovesButtonTapped:", forControlEvents: .TouchUpInside)
            return button
        }
    }

    let commentsItem:UIBarButtonItem = ElloPostToolBarOption.Comments.barButtonItem()
    var commentsButton:StreamFooterButton {
        get {
            let button = self.commentsItem.customView as StreamFooterButton
            button.addTarget(self, action: "commentsButtonTapped:", forControlEvents: .TouchUpInside)
            button.addTarget(self, action: "commentsButtonTouchDown:", forControlEvents: .TouchDown)
            return button
        }
    }

    let repostItem:UIBarButtonItem = ElloPostToolBarOption.Repost.barButtonItem()
    var repostButton:StreamFooterButton {
        get {
            let button = self.repostItem.customView as StreamFooterButton
            button.addTarget(self, action: "repostButtonTapped:", forControlEvents: .TouchUpInside)
            return button
        }
    }

    var streamKind:StreamKind? {
        didSet {
            if let streamKind = streamKind {
                if streamKind.isGridLayout {
                    self.toolBar.items = [
                        commentsItem, lovesItem, repostItem
                    ]
                }
                else {
                    self.toolBar.items = [
                        viewsItem, commentsItem, repostItem
                    ]
                }
            }
        }
    }

    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        toolBar.translucent = false
        toolBar.barTintColor = UIColor.whiteColor()
        toolBar.clipsToBounds = true
        toolBar.layer.borderColor = UIColor.whiteColor().CGColor

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false

//        self.moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        self.moreButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
//        self.moreButton.backgroundColor = [UIColor colorWithWhite:0.76 alpha:1.0];
//        self.moreButton.frame = CGRectMake(0, 0, kRevealWidth / 2.0, self.contentView.frame.size.height);
//        [self.moreButton setTitle:@"More..." forState:UIControlStateNormal];
//
//        self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        self.deleteButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
//        self.deleteButton.backgroundColor = [UIColor redColor];
//        self.deleteButton.frame = CGRectMake(self.moreButton.frame.size.width, 0, kRevealWidth / 2.0, self.contentView.frame.size.height);
//        [self.deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
//
//        self.buttonContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kRevealWidth, self.deleteButton.frame.size.height)];
//        [self.buttonContainerView addSubview:self.moreButton];
//        [self.buttonContainerView addSubview:self.deleteButton];
//
//        [self.scrollView insertSubview:self.buttonContainerView
//        belowSubview:self.innerContentView];
//
//        [[NSNotificationCenter defaultCenter] addObserver:self
//        selector:@selector(onOpen:)
//        name:RevealCellDidOpenNotification
//        object:nil];
    }

    var views:String? {
        get { return viewsButton.titleForState(.Normal) }
        set { viewsButton.setButtonTitle(newValue) }
    }

    var comments:String? {
        get { return commentsButton.titleForState(.Normal) }
        set { commentsButton.setButtonTitle(newValue) }
    }

    var loves:String? {
        get { return lovesButton.titleForState(.Normal) }
        set { lovesButton.setButtonTitle(newValue) }
    }

    var reposts:String? {
        get { return repostButton.titleForState(.Normal) }
        set { repostButton.setButtonTitle(newValue) }
    }

    // MARK: - Private

    private func fixedItem(width:CGFloat) -> UIBarButtonItem {
        let item = UIBarButtonItem()
        item.width = width
        return item
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

    @IBAction func chevronButtonTapped(sender: StreamFooterButton) {
    }


    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        innerContentView.frame = bounds
        containerView.frame = bounds
        scrollView.contentSize = CGSizeMake(contentView.frame.size.width + revealWidth, scrollView.frame.size.height)
        repositionButtonContent()
    }



    func scrollViewDidScroll(scrollView: UIScrollView) {
        repositionButtonContent()

        if (scrollView.contentOffset.x < 0) {
            scrollView.contentOffset = CGPointZero;
        }

        if (scrollView.contentOffset.x >= revealWidth) {
            isOpen = true
//            [[NSNotificationCenter defaultCenter] postNotificationName:RevealCellDidOpenNotificationobject:self];
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

    func repositionButtonContent() {

    }

}
