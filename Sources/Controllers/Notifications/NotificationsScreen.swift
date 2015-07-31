//
//  NotificationsScreen.swift
//  Ello
//
//  Created by Colin Gray on 2/19/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import SVGKit

@objc
public protocol NotificationsScreenDelegate {
    func activatedCategory(filter : String)
}

public class NotificationsScreen : UIView {
    private class func filterButton() -> UIButton {
        let button = UIButton()
        button.titleLabel!.font = UIFont.typewriterFont(14)
        button.setTitleColor(UIColor.whiteColor(), forState: .Selected)
        button.setTitleColor(UIColor.greyA(), forState: .Normal)
        button.setBackgroundImage(UIImage.imageWithColor(UIColor.blackColor()), forState: .Selected)
        button.setBackgroundImage(UIImage.imageWithColor(UIColor.greyE5()), forState: .Normal)
        return button
    }
    private class func filterButton(#imageName: String) -> UIButton {
        let button = filterButton()
        button.setSVGImage("\(imageName)_normal.svg", forState: .Normal)
        button.setSVGImage("\(imageName)_white.svg", forState: .Selected)
        button.imageView!.contentMode = .ScaleAspectFit
        return button
    }
    private class func filterButton(#title: String) -> UIButton {
        let button = filterButton()
        button.setTitle(title, forState: .Normal)
        return button
    }


    weak var delegate : NotificationsScreenDelegate?
    let filterBar = NotificationsFilterBar()
    let streamContainer = UIView()

    var navBarVisible = true

    override public init(frame: CGRect) {
        let filterAllButton = NotificationsScreen.filterButton(title: "All")
        let filterCommentsButton = NotificationsScreen.filterButton(imageName: "bubble")
        let filterMentionButton = NotificationsScreen.filterButton(title: "@")
        // no loves yet!
        let filterHeartButton = NotificationsScreen.filterButton(imageName: "hearts")
        let filterRepostButton = NotificationsScreen.filterButton(imageName: "repost")
        let filterInviteButton = NotificationsScreen.filterButton(imageName: "relationships")

        super.init(frame: frame)
        backgroundColor = UIColor.whiteColor()
        self.addSubview(streamContainer)

        for (button, action) in [
            (filterAllButton, "allButtonTapped:"),
            (filterCommentsButton, "commentsButtonTapped:"),
            (filterMentionButton, "mentionButtonTapped:"),
            (filterHeartButton, "heartButtonTapped:"),
            (filterRepostButton, "repostButtonTapped:"),
            (filterInviteButton, "inviteButtonTapped:"),
        ] {
            filterBar.addSubview(button)
            button.addTarget(self, action: Selector(action), forControlEvents: .TouchUpInside)
        }
        filterBar.selectButton(filterAllButton)
        self.addSubview(filterBar)
    }

    required public init(coder: NSCoder) {
        super.init(coder: coder)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        positionFilterBar()
        streamContainer.frame = self.bounds.fromTop()
            .withHeight(self.frame.height)
    }

    func allButtonTapped(sender : NotificationFilterButton) {
        filterBar.selectButton(sender)
        delegate?.activatedCategory(NotificationFilterType.All.rawValue)
    }

    func commentsButtonTapped(sender : NotificationFilterButton) {
        filterBar.selectButton(sender)
        delegate?.activatedCategory(NotificationFilterType.Comments.rawValue)
    }

    func mentionButtonTapped(sender : NotificationFilterButton) {
        filterBar.selectButton(sender)
        delegate?.activatedCategory(NotificationFilterType.Mention.rawValue)
    }

    func heartButtonTapped(sender : NotificationFilterButton) {
        filterBar.selectButton(sender)
        delegate?.activatedCategory(NotificationFilterType.Heart.rawValue)
    }

    func repostButtonTapped(sender : NotificationFilterButton) {
        filterBar.selectButton(sender)
        delegate?.activatedCategory(NotificationFilterType.Repost.rawValue)
    }

    func inviteButtonTapped(sender : NotificationFilterButton) {
        filterBar.selectButton(sender)
        delegate?.activatedCategory(NotificationFilterType.Relationship.rawValue)
    }
}


// MARK: Filter Bar
extension NotificationsScreen {

    func animateNavigationBar(#visible: Bool) {
        navBarVisible = visible
        animate {
            self.positionFilterBar()
        }
        UIApplication.sharedApplication().setStatusBarHidden(!visible, withAnimation: .None)
    }

    private func positionFilterBar() {
        filterBar.frame = self.bounds.withHeight(NotificationsFilterBar.Size.height)
        if navBarVisible {
            filterBar.frame.origin.y = 0
        }
        else {
            filterBar.frame.origin.y = -NotificationsFilterBar.Size.height
        }
    }

}
