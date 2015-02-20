//
//  NotificationsViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/20/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//


import UIKit
import WebKit


class NotificationsViewController: StreamableViewController, NotificationsScreenDelegate {

    @IBOutlet var contentView : UIView!
    @IBOutlet var filterBar : NotificationsFilterBar!

    override func loadView() {
        self.view = NotificationsScreen(frame: UIScreen.mainScreen().bounds)
    }

    var screen : NotificationsScreen {
        return self.view as NotificationsScreen
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true

        setupStreamController()
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
        self.screen.insertStreamView(controller.view)
        self.addChildViewController(controller)

        let streamService = NotificationsService()
        streamService.load(
            success: { notifications in
                let parser = NotificationCellItemParser()
                let items = parser.cellItems(notifications)
                controller.addUnsizedCellItems(items)
                controller.doneLoading()
            },
            failure: { (error, statusCode) -> () in
                println("failed to load notifications (reason: \(error))")
                controller.doneLoading()
            }
        )
    }

    override func postTapped(post: Post, initialItems: [StreamCellItem]) {
        super.postTapped(post, initialItems: initialItems)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    func allButtonTapped() {}
    func miscButtonTapped() {}
    func mentionButtonTapped() {}
    func heartButtonTapped() {}
    func repostButtonTapped() {}
    func inviteButtonTapped() {}

}
