//
//  StreamFooterCell.swift
//  Ello
//
//  Created by Sean Dougherty on 12/10/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import UIKit
import Foundation

protocol PostbarDelegate : NSObjectProtocol {
    func viewsButtonTapped(cell:StreamFooterCell)
    func commentsButtonTapped(cell:StreamFooterCell)
    func lovesButtonTapped(cell:StreamFooterCell)
    func repostButtonTapped(cell:StreamFooterCell)
}

enum ElloPostToolBar {
    case Views
    case Comments
    case Loves
    case Repost
    case Share
    case Delete
    case Edit

    func button() -> UIButton {
        switch self {
        case .Views:
            return normalButton("eye-icon")
        case .Comments:
            return normalButton("dots-icon")
        case .Loves:
            return normalButton("heart-icon")
        case .Repost:
            return normalButton("repost-icon")
        case .Share:
            return normalButton("eye-icon")
        case .Delete:
            return normalButton("eye-icon")
        case .Edit:
            return normalButton("eye-icon")
        }
    }

    func barButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem(customView: self.button())
    }

    private func normalButton(imageName: String, count: Int? = nil) -> UIButton {
        let image = UIImage(named: imageName)
        let button = StreamFooterButton()
        button.sizeToFit()
        if let count = count {
            button.setButtonTitle(String(count))
        }
        button.setImage(image, forState: .Normal)
        button.contentMode = .Center
        return button
    }
}

class StreamFooterCell: UICollectionViewCell {

    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var chevronButton: StreamFooterButton!
    var commentsOpened = false
    weak var delegate: PostbarDelegate?

    let viewsItem:UIBarButtonItem = ElloPostToolBar.Views.barButtonItem()
    var viewsButton:StreamFooterButton {
        get {
            let button = self.viewsItem.customView as StreamFooterButton
            button.addTarget(self, action: "viewsButtonTapped:", forControlEvents: .TouchUpInside)
            return button
        }
    }

    let lovesItem:UIBarButtonItem = ElloPostToolBar.Loves.barButtonItem()
    var lovesButton:StreamFooterButton {
        get {
            let button = self.lovesItem.customView as StreamFooterButton
            button.addTarget(self, action: "lovesButtonTapped:", forControlEvents: .TouchUpInside)
            return button
        }
    }

    let commentsItem:UIBarButtonItem = ElloPostToolBar.Comments.barButtonItem()
    var commentsButton:StreamFooterButton {
        get {
            let button = self.commentsItem.customView as StreamFooterButton
            button.addTarget(self, action: "commentsButtonTapped:", forControlEvents: .TouchUpInside)
            return button
        }
    }

    let repostItem:UIBarButtonItem = ElloPostToolBar.Repost.barButtonItem()
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
                        viewsItem, self.fixedItem(10), commentsItem, self.fixedItem(10), lovesItem, self.fixedItem(10), repostItem
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

    @IBAction func commentsButtonTapped(sender: StreamFooterButton) {
        commentsOpened = !commentsOpened
        delegate?.commentsButtonTapped(self)
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
