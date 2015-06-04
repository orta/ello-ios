//
//  NotificationsScreen.swift
//  Ello
//
//  Created by Colin Gray on 2/19/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

@objc
public protocol NotificationsScreenDelegate {
    func activatedFilter(filter : String)
}

import SVGKit

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
    private class func filterButton(image: UIImage) -> UIButton {
        let button = filterButton()
        button.setImage(image, forState: .Normal)
        button.imageView!.contentMode = .ScaleAspectFit
        return button
    }
    private class func filterButton(title: String) -> UIButton {
        let button = filterButton()
        button.setTitle(title, forState: .Normal)
        return button
    }


    weak var delegate : NotificationsScreenDelegate?
    let filterBar = NotificationsFilterBar()
    var filterBarVisible = false
    let streamContainer = UIView()

    let temporaryNavBar = ElloNavigationBar()
    var navBarVisible = true

    override public init(frame: CGRect) {
        let filterAllButton = NotificationsScreen.filterButton("All")
        let filterMiscButton = NotificationsScreen.filterButton(SVGKImage(named: "bubble_normal.svg").UIImage!)
        let filterMentionButton = NotificationsScreen.filterButton("@")
        // no loves yet!
        // let filterHeartButton = NotificationsScreen.filterButton(SVGKImage(named: "heartplus_normal.svg").UIImage!)
        let filterRepostButton = NotificationsScreen.filterButton(SVGKImage(named: "repost_normal.svg").UIImage!)
        let filterInviteButton = NotificationsScreen.filterButton(SVGKImage(named: "relationships_normal.svg").UIImage!)

        super.init(frame: frame)
        backgroundColor = UIColor.whiteColor()
        self.addSubview(streamContainer)

        for (button, action) in [
            (filterAllButton, "allButtonTapped:"),
            (filterMiscButton, "miscButtonTapped:"),
            (filterMentionButton, "mentionButtonTapped:"),
            // (filterHeartButton, "heartButtonTapped:"),
            (filterRepostButton, "repostButtonTapped:"),
            (filterInviteButton, "inviteButtonTapped:"),
        ] {
            filterBar.addSubview(button)
            button.addTarget(self, action: Selector(action), forControlEvents: .TouchUpInside)
        }
        filterBar.selectButton(filterAllButton)
        // self.addSubview(filterBar)

        self.addSubview(temporaryNavBar)
    }

    required public init(coder: NSCoder) {
        super.init(coder: coder)
    }

    func animateFilterBar(#visible: Bool) {
        filterBarVisible = visible
        animate {
            self.positionFilterBar()
        }
    }

    private func positionFilterBar() {
        filterBar.frame = self.bounds.withHeight(NotificationsFilterBar.Size.height)
        if filterBarVisible {
            filterBar.frame.origin.y = 0
        }
        else {
            filterBar.frame.origin.y = -NotificationsFilterBar.Size.height
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        // positionFilterBar()
        positionNavigationBar()
        streamContainer.frame = self.bounds.fromTop()
            .withHeight(self.frame.height)
    }

    func allButtonTapped(sender : NotificationFilterButton) {
        filterBar.selectButton(sender)
        delegate?.activatedFilter(NotificationFilterType.All.rawValue)
    }

    func miscButtonTapped(sender : NotificationFilterButton) {
        filterBar.selectButton(sender)
        delegate?.activatedFilter(NotificationFilterType.Misc.rawValue)
    }

    func mentionButtonTapped(sender : NotificationFilterButton) {
        filterBar.selectButton(sender)
        delegate?.activatedFilter(NotificationFilterType.Mention.rawValue)
    }

    func heartButtonTapped(sender : NotificationFilterButton) {
        filterBar.selectButton(sender)
        delegate?.activatedFilter(NotificationFilterType.Heart.rawValue)
    }

    func repostButtonTapped(sender : NotificationFilterButton) {
        filterBar.selectButton(sender)
        delegate?.activatedFilter(NotificationFilterType.Repost.rawValue)
    }

    func inviteButtonTapped(sender : NotificationFilterButton) {
        filterBar.selectButton(sender)
        delegate?.activatedFilter(NotificationFilterType.Relationship.rawValue)
    }
}


// MARK: Temporary Navigation Bar
extension NotificationsScreen {

    func animateNavigationBar(#visible: Bool) {
        navBarVisible = visible
        animate {
            self.positionNavigationBar()
        }
        UIApplication.sharedApplication().setStatusBarHidden(!visible, withAnimation: .None)
    }

    private func positionNavigationBar() {
        temporaryNavBar.frame = self.bounds.withHeight(ElloNavigationBar.Size.height)
        if navBarVisible {
            temporaryNavBar.frame.origin.y = 0
        }
        else {
            temporaryNavBar.frame.origin.y = -ElloNavigationBar.Size.height
        }
    }

}
