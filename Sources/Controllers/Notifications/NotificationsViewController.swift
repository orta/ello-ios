//
//  NotificationsViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/20/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//


import UIKit
import WebKit

class NotificationsViewController: StreamableViewController {

    required override init() {
        super.init(nibName: "NotificationsViewController", bundle: NSBundle(forClass: NotificationsViewController.self))
    }

    @IBOutlet var contentView : UIView!
    @IBOutlet var filterBar : NotificationsFilterBar!

    lazy var filterAllButton : UIButton = {
        var button = UIButton()
        button.setTitle("All", forState: .Normal)
        self.styleButton(button)
        button.addTarget(self, action: "allButtonTapped:", forControlEvents: .TouchUpInside)
        return button
    }()
    lazy var filterMiscButton : UIButton = {
        var button = UIButton()
        button.setTitle("…", forState: .Normal)
        self.styleButton(button)
        button.addTarget(self, action: "miscButtonTapped:", forControlEvents: .TouchUpInside)
        return button
    }()
    lazy var filterMentionButton : UIButton = {
        var button = UIButton()
        button.setTitle("@", forState: .Normal)
        self.styleButton(button)
        button.addTarget(self, action: "mentionButtonTapped:", forControlEvents: .TouchUpInside)
        return button
    }()
    lazy var filterHeartButton : UIButton = {
        var button = UIButton()
        button.setTitle("❤︎", forState: .Normal)
        self.styleButton(button)
        button.addTarget(self, action: "heartButtonTapped:", forControlEvents: .TouchUpInside)
        return button
    }()
    lazy var filterRepostButton : UIButton = {
        var button = UIButton()
        button.setTitle("↻", forState: .Normal)
        self.styleButton(button)
        button.addTarget(self, action: "repostButtonTapped:", forControlEvents: .TouchUpInside)
        return button
    }()
    lazy var filterInviteButton : UIButton = {
        var button = UIButton()
        button.setTitle("+", forState: .Normal)
        self.styleButton(button)
        button.addTarget(self, action: "inviteButtonTapped:", forControlEvents: .TouchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true

        setupStreamController()
        setupFilterBar()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    private func setupStreamController() {
        let controller = StreamViewController.instantiateFromStoryboard()
        controller.streamKind = .Notifications
        controller.postTappedDelegate = self

        let streamService = StreamService()
        ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
        streamService.loadStream(StreamKind.Notifications.endpoint,
            success: { (streamables) -> () in
                controller.addStreamables(streamables)
                controller.doneLoading()
            },
            failure: { (error, statusCode) -> () in
                println("failed to load notifications (reason: \(error))")
                controller.doneLoading()
            }
        )
        ElloProvider.sharedProvider = ElloProvider.DefaultProvider()

        controller.willMoveToParentViewController(self)
        contentView.insertSubview(controller.view, atIndex: 0)
        controller.view.frame = contentView.bounds
        controller.view.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        self.addChildViewController(controller)
    }

    private func setupFilterBar() {
        filterBar.addButton(self.filterAllButton)
        filterBar.addButton(self.filterMiscButton)
        filterBar.addButton(self.filterMentionButton)
        filterBar.addButton(self.filterHeartButton)
        filterBar.addButton(self.filterRepostButton)
        filterBar.addButton(self.filterInviteButton)
        filterBar.selectButton(self.filterAllButton)
    }

    private func styleButton(button : UIButton) {
        button.titleLabel!.font = UIFont.typewriterFont(12)
        button.setTitleColor(UIColor.whiteColor(), forState: .Selected)
        button.setTitleColor(UIColor.elloUnselectedGray(), forState: .Normal)
        button.setBackgroundImage(UIImage(named: "selected-pixel"), forState: .Selected)
        button.setBackgroundImage(UIImage(named: "unselected-pixel"), forState: .Normal)
    }

    func allButtonTapped(sender : UIButton) {
        filterBar.selectButton(sender)
    }

    func miscButtonTapped(sender : UIButton) {
        filterBar.selectButton(sender)
    }

    func mentionButtonTapped(sender : UIButton) {
        filterBar.selectButton(sender)
    }

    func heartButtonTapped(sender : UIButton) {
        filterBar.selectButton(sender)
    }

    func repostButtonTapped(sender : UIButton) {
        filterBar.selectButton(sender)
    }

    func inviteButtonTapped(sender : UIButton) {
        filterBar.selectButton(sender)
    }

    override func postTapped(post: Post, initialItems: [StreamCellItem]) {
        super.postTapped(post, initialItems: initialItems)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

}
