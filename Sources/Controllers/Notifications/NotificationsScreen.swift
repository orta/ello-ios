//
//  NotificationsScreen.swift
//  Ello
//
//  Created by Colin Gray on 2/19/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

@objc
protocol NotificationsScreenDelegate {
    func allButtonTapped()
    func miscButtonTapped()
    func mentionButtonTapped()
    func heartButtonTapped()
    func repostButtonTapped()
    func inviteButtonTapped()
}


class NotificationsScreen : UIView {
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
        return button
    }
    private class func filterButton(title: String) -> UIButton {
        let button = filterButton()
        button.setTitle(title, forState: .Normal)
        return button
    }


    weak var delegate : NotificationsScreenDelegate?
    let filterBar : NotificationsFilterBar
    let streamContainer : UIView

    override init(frame: CGRect) {
        filterBar = NotificationsFilterBar()

        let filterAllButton = NotificationsScreen.filterButton("All")
        let filterMiscButton = NotificationsScreen.filterButton("…")
        let filterMentionButton = NotificationsScreen.filterButton("@")
        let filterHeartButton = NotificationsScreen.filterButton(UIImage(named: "heart-icon")!)
        let filterRepostButton = NotificationsScreen.filterButton(UIImage(named: "repost-icon")!)
        let filterInviteButton = NotificationsScreen.filterButton(UIImage(named: "profile-icon")!)

        streamContainer = UIView()
        super.init(frame: frame)
        backgroundColor = UIColor.whiteColor()

        for (button, action) in [
            (filterAllButton, "allButtonTapped:"),
            (filterMiscButton, "miscButtonTapped:"),
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
        self.addSubview(streamContainer)
    }

    required init(coder: NSCoder) {
        filterBar = NotificationsFilterBar()
        streamContainer = UIView()
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        filterBar.frame = self.bounds.fromTop().withHeight(NotificationsFilterBar.Size.height)
        streamContainer.frame = self.bounds.fromTop()
            .withHeight(self.frame.height)
            .shrinkDown(filterBar.frame.height)
    }

    func insertStreamView(streamView : UIView) {
        streamContainer.addSubview(streamView)
        streamView.frame = streamContainer.bounds
        streamView.autoresizingMask = .FlexibleHeight | .FlexibleWidth
    }

    @IBAction func allButtonTapped(sender : NotificationFilterButton) {
        filterBar.selectButton(sender)
        delegate?.allButtonTapped()
    }

    @IBAction func miscButtonTapped(sender : NotificationFilterButton) {
        filterBar.selectButton(sender)
        delegate?.miscButtonTapped()
    }

    @IBAction func mentionButtonTapped(sender : NotificationFilterButton) {
        filterBar.selectButton(sender)
        delegate?.mentionButtonTapped()
    }

    @IBAction func heartButtonTapped(sender : NotificationFilterButton) {
        filterBar.selectButton(sender)
        delegate?.heartButtonTapped()
    }

    @IBAction func repostButtonTapped(sender : NotificationFilterButton) {
        filterBar.selectButton(sender)
        delegate?.repostButtonTapped()
    }

    @IBAction func inviteButtonTapped(sender : NotificationFilterButton) {
        filterBar.selectButton(sender)
        delegate?.inviteButtonTapped()
    }
}