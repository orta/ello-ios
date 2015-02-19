//
//  StreamFooterCell.swift
//  Ello
//
//  Created by Sean Dougherty on 12/10/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import Foundation




class StreamFooterCell: UICollectionViewCell {

    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var chevronButton: StreamFooterButton!
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

    override func awakeFromNib() {
        super.awakeFromNib()
        self.toolBar.translucent = false
        self.toolBar.barTintColor = UIColor.whiteColor()
        self.toolBar.clipsToBounds = true
        self.toolBar.layer.borderColor = UIColor.whiteColor().CGColor
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
}
