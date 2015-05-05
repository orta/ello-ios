//
//  NotificationsViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/20/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//


import UIKit
import WebKit


public class NotificationsViewController: StreamableViewController, NotificationDelegate, NotificationsScreenDelegate {

    override public func loadView() {
        self.view = NotificationsScreen(frame: UIScreen.mainScreen().bounds)
    }

    var screen: NotificationsScreen {
        return self.view as! NotificationsScreen
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.screen.delegate = self
        streamViewController.streamKind = .Notifications
        streamViewController.loadInitialPage()
        scrollLogic.prevOffset = streamViewController.collectionView.contentOffset
        scrollLogic.navBarHeight = 44
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }

    override public func showNavBars(scrollToBottom: Bool) {
        super.showNavBars(scrollToBottom)
        self.screen.showFilterBar()
        self.screen.layoutIfNeeded()
    }

    override public func hideNavBars() {
        super.hideNavBars()
        self.screen.hideFilterBar()
        self.screen.layoutIfNeeded()
    }

    // used to provide StreamableViewController access to the container it then
    // loads the StreamViewController's content into
    override func viewForStream() -> UIView {
        return self.screen.streamContainer
    }


    public func activatedFilter(filterTypeStr: String) {
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
                if let notification = item.jsonable as? Notification {
                    return contains(notificationKinds, notification.activity.kind)
                }
                else {
                    return false
                }
            }
        }
        else {
            streamViewController.streamFilter = nil
        }
    }

    public func commentTapped(comment: Comment) {
        if let post = comment.parentPost {
            postTapped(post)
        }
        else {
            postTapped(postId: comment.postId)
        }
    }

}
