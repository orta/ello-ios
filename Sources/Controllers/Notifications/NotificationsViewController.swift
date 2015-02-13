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

    @IBOutlet var filterAllButton : NotificationFilterButton!
    @IBOutlet var filterMiscButton : NotificationFilterButton!
    @IBOutlet var filterMentionButton : NotificationFilterButton!
    @IBOutlet var filterHeartButton : NotificationFilterButton!
    @IBOutlet var filterRepostButton : NotificationFilterButton!
    @IBOutlet var filterInviteButton : NotificationFilterButton!

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

        controller.willMoveToParentViewController(self)
        contentView.insertSubview(controller.view, atIndex: 0)
        controller.view.frame = contentView.bounds
        controller.view.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        self.addChildViewController(controller)

        let streamService = NotificationsService()
        ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
        streamService.load(
            success: { notifications in
                var parser = NotificationCellItemParser()
                controller.addUnsizedCellItems(parser.cellItems(notifications))
                controller.doneLoading()
            },
            failure: { (error, statusCode) -> () in
                println("failed to load notifications (reason: \(error))")
                controller.doneLoading()
            }
        )
        ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
    }

    private func setupFilterBar() {
        filterBar.selectButton(self.filterAllButton)
    }

    @IBAction func allButtonTapped(sender : NotificationFilterButton) {
        filterBar.selectButton(sender)
    }

    @IBAction func miscButtonTapped(sender : NotificationFilterButton) {
        filterBar.selectButton(sender)
    }

    @IBAction func mentionButtonTapped(sender : NotificationFilterButton) {
        filterBar.selectButton(sender)
    }

    @IBAction func heartButtonTapped(sender : NotificationFilterButton) {
        filterBar.selectButton(sender)
    }

    @IBAction func repostButtonTapped(sender : NotificationFilterButton) {
        filterBar.selectButton(sender)
    }

    @IBAction func inviteButtonTapped(sender : NotificationFilterButton) {
        filterBar.selectButton(sender)
    }

    override func postTapped(post: Post, initialItems: [StreamCellItem]) {
        super.postTapped(post, initialItems: initialItems)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

}
