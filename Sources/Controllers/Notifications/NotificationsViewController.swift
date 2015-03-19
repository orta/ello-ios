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
    var streamViewController : StreamViewController!

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
        scrollLogic.prevOffset = streamViewController.collectionView.contentOffset
        scrollLogic.navBarHeight = 30
    }

    override func showNavBars(scrollToBottom : Bool) {
        super.showNavBars(scrollToBottom)
        self.screen.showFilterBar()
        self.screen.layoutIfNeeded()
    }

    override func hideNavBars() {
        super.hideNavBars()
        self.screen.hideFilterBar()
        self.screen.layoutIfNeeded()
    }

    private func setupStreamController() {
        streamViewController = StreamViewController.instantiateFromStoryboard()
        streamViewController.currentUser = currentUser
        streamViewController.streamKind = .Notifications
        streamViewController.streamScrollDelegate = self
        streamViewController.postTappedDelegate = self
        streamViewController.userTappedDelegate = self
        streamViewController.notificationDelegate = self

        streamViewController.willMoveToParentViewController(self)
        self.screen.insertStreamView(streamViewController.view)
        self.addChildViewController(streamViewController)

        streamViewController.loadInitialPage()
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
            streamViewController.streamFilter = { item in
                let notification = item.jsonable as Notification
                return contains(notificationKinds, notification.kind)
            }
        }
        else {
            streamViewController.streamFilter = nil
        }
    }

    func commentTapped(comment: Comment) {}

    var sizer : StreamTextCellSizeCalculator?
    func postTapped(post: Post) {
        if let sizer = sizer {
            return
        }
        else {
            sizer = StreamTextCellSizeCalculator(webView: UIWebView(frame: self.view.bounds))
            let initialItems = StreamCellItemParser().parse([post], streamKind: streamViewController.streamKind)
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
