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

    @IBOutlet var filterAllButton : ElloNotificationFilterButton!
    @IBOutlet var filterMiscButton : ElloNotificationFilterButton!
    @IBOutlet var filterMentionButton : ElloNotificationFilterButton!
    @IBOutlet var filterHeartButton : ElloNotificationFilterButton!
    @IBOutlet var filterRepostButton : ElloNotificationFilterButton!
    @IBOutlet var filterInviteButton : ElloNotificationFilterButton!

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
        filterBar.selectButton(self.filterAllButton)
    }

    @IBAction func allButtonTapped(sender : ElloNotificationFilterButton) {
        filterBar.selectButton(sender)
    }

    @IBAction func miscButtonTapped(sender : ElloNotificationFilterButton) {
        filterBar.selectButton(sender)
    }

    @IBAction func mentionButtonTapped(sender : ElloNotificationFilterButton) {
        filterBar.selectButton(sender)
    }

    @IBAction func heartButtonTapped(sender : ElloNotificationFilterButton) {
        filterBar.selectButton(sender)
    }

    @IBAction func repostButtonTapped(sender : ElloNotificationFilterButton) {
        filterBar.selectButton(sender)
    }

    @IBAction func inviteButtonTapped(sender : ElloNotificationFilterButton) {
        filterBar.selectButton(sender)
    }

    override func postTapped(post: Post, initialItems: [StreamCellItem]) {
        super.postTapped(post, initialItems: initialItems)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

}
