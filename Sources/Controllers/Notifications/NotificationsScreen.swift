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


public class NotificationsScreen : UIView {
    private class func filterButton() -> UIButton {
        let button = UIButton()
        button.titleLabel!.font = UIFont.typewriterFont(12)
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
    let filterBar : NotificationsFilterBar
    var filterBarVisible : Bool
    let streamContainer : UIView

    override public init(frame: CGRect) {
        filterBar = NotificationsFilterBar()
        filterBarVisible = true

        let filterAllButton = NotificationsScreen.filterButton("All")
        let filterMiscButton = NotificationsScreen.filterButton("…")
        let filterMentionButton = NotificationsScreen.filterButton("@")
        // no loves yet!
        // let filterHeartButton = NotificationsScreen.filterButton(UIImage(named: "heart-icon")!)
        let filterRepostButton = NotificationsScreen.filterButton(UIImage(named: "repost-icon")!)
        let filterInviteButton = NotificationsScreen.filterButton(UIImage(named: "profile-icon")!)

        streamContainer = UIView()
        super.init(frame: frame)
        backgroundColor = UIColor.whiteColor()

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
        self.addSubview(filterBar)
        self.addSubview(streamContainer)
    }

    required public init(coder: NSCoder) {
        filterBar = NotificationsFilterBar()
        filterBarVisible = true
        streamContainer = UIView()
        super.init(coder: coder)
    }

    func showFilterBar() {
        filterBarVisible = true
        self.setNeedsLayout()
    }

    func hideFilterBar() {
        filterBarVisible = false
        self.setNeedsLayout()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        filterBar.frame = self.bounds.withHeight(NotificationsFilterBar.Size.height)
        if filterBarVisible {
            filterBar.frame = filterBar.frame.atY(0)
        }
        else {
            filterBar.frame = filterBar.frame.atY(-NotificationsFilterBar.Size.height)
        }
        streamContainer.frame = self.bounds.fromTop()
            .withHeight(self.frame.height)
            .shrinkDown(filterBar.frame.maxY)
    }

    func insertStreamView(streamView : UIView) {
        streamContainer.addSubview(streamView)
        streamView.frame = streamContainer.bounds
        streamView.autoresizingMask = .FlexibleHeight | .FlexibleWidth
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