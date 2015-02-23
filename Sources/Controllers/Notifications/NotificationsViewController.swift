//
//  NotificationsViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/20/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//


import UIKit
import WebKit


class NotificationsViewController: StreamableViewController, NotificationDelegate, NotificationsScreenDelegate {
    var streamController : StreamViewController!

    override func loadView() {
        self.view = NotificationsScreen(frame: UIScreen.mainScreen().bounds)
    }

    var screen : NotificationsScreen {
        return self.view as NotificationsScreen
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.screen.delegate = self
        self.navigationController?.navigationBarHidden = true

        setupStreamController()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    private func setupStreamController() {
        streamController = StreamViewController.instantiateFromStoryboard()
        streamController.streamKind = .Notifications
        streamController.postTappedDelegate = self
        streamController.notificationDelegate = self

        streamController.willMoveToParentViewController(self)
        self.screen.insertStreamView(streamController.view)
        self.addChildViewController(streamController)

        let streamService = NotificationsService()
        streamService.load(
            success: { notifications in
                let parser = NotificationCellItemParser()
                let items = parser.cellItems(notifications)
                self.streamController.addUnsizedCellItems(items)
                self.streamController.doneLoading()
            },
            failure: { (error, statusCode) -> () in
                println("failed to load notifications (reason: \(error))")
                self.streamController.doneLoading()
            }
        )
    }

    func activatedFilter(filterTypeStr: String) {
        let filterType = NotificationFilterType(rawValue: filterTypeStr)!
        var notificationKinds: [Activity.Kind]?

        switch filterType {
            case .All:
                notificationKinds = nil
            case .Misc:  // …
                notificationKinds = Activity.Kind.commentNotifications()
            case .Mention:  // @
                notificationKinds = Activity.Kind.mentionNotifications()
            case .Heart:
                notificationKinds = nil
            case .Repost:
                notificationKinds = Activity.Kind.repostNotifications()
            case .Relationship:
                notificationKinds = Activity.Kind.relationshipNotifications()
        }

        if let notificationKinds = notificationKinds {
            streamController.streamFilter = { item in
                let notification = item.jsonable as Notification
                return contains(notificationKinds, notification.kind)
            }
        }
        else {
            streamController.streamFilter = nil
        }
    }

    func userTapped(user: User) {
        let vc = ProfileViewController(user: user)
        self.navigationController?.pushViewController(vc, animated: true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    func commentTapped(comment: Comment) {}

    var sizer : StreamTextCellSizeCalculator?
    func postTapped(post: Post) {
        if let sizer = sizer {
            return
        }
        else {
            sizer = StreamTextCellSizeCalculator(webView: UIWebView(frame: self.view.bounds))
            var parser = StreamCellItemParser()
            let initialItems = parser.postCellItems([post], streamKind: .PostDetail(post: post))
            ElloHUD.showLoadingHud()
            sizer!.processCells(initialItems) {
                ElloHUD.hideLoadingHud()
                self.postTapped(post, initialItems: initialItems)
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.sizer = nil
            }
        }
    }

}
