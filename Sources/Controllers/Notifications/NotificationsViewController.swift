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

    private var hasNewContent = false
    private var newNotificationsObserver: NotificationObserver?

    override public var tabBarItem: UITabBarItem? {
        get { return UITabBarItem.svgItem("bolt") }
        set { self.tabBarItem = newValue }
    }

    override public func loadView() {
        self.view = NotificationsScreen(frame: UIScreen.mainScreen().bounds)
    }

    var screen: NotificationsScreen {
        return self.view as! NotificationsScreen
    }

    var navigationNotificationObserver: NotificationObserver?

    required public override init(nibName: String?, bundle: NSBundle?) {
        super.init(nibName: nibName, bundle: bundle)
        navigationNotificationObserver = NotificationObserver(notification: NavigationNotifications.showingNotificationsTab) { [unowned self] components in
            self.respondToNotification(components)
        }

        newNotificationsObserver = NotificationObserver(notification: NewContentNotifications.newNotifications) {
            _ in
            self.hasNewContent = true
        }
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        navigationNotificationObserver?.removeObserver()
        newNotificationsObserver?.removeObserver()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        screen.delegate = self
        self.title = "Notifications"
        addSearchButton()

        scrollLogic.prevOffset = streamViewController.collectionView.contentOffset
        scrollLogic.navBarHeight = 44
        streamViewController.streamKind = .Notifications(category: nil)
        ElloHUD.showLoadingHudInView(streamViewController.view)
        let noResultsTitle = NSLocalizedString("Welcome to your Notifications Center!", comment: "No notification results title")
        let noResultsBody = NSLocalizedString("Whenever someone mentions you, follows you, accepts an invitation, comments, reposts or Loves one of your posts, you'll be notified here.", comment: "No notification results body.")
        streamViewController.noResultsMessages = (title: noResultsTitle, body: noResultsBody)
        streamViewController.loadInitialPage()
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true

        if hasNewContent {
            hasNewContent = false
            ElloHUD.showLoadingHudInView(streamViewController.view)
            streamViewController.loadInitialPage()
        }
    }

    override func setupStreamController() {
        super.setupStreamController()

        streamViewController.notificationDelegate = self
    }

    override public func showNavBars(scrollToBottom: Bool) {
        super.showNavBars(scrollToBottom)
        screen.animateNavigationBar(visible: true)
        updateInsets()

        if scrollToBottom {
            self.scrollToBottom(streamViewController)
        }
    }

    override public func hideNavBars() {
        super.hideNavBars()
        screen.animateNavigationBar(visible: false)
        updateInsets()
    }

    private func updateInsets() {
        updateInsets(navBar: screen.filterBar, streamController: streamViewController)
    }

    // used to provide StreamableViewController access to the container it then
    // loads the StreamViewController's content into
    override func viewForStream() -> UIView {
        return self.screen.streamContainer
    }

    public func activatedCategory(filterTypeStr: String) {
        let filterType = NotificationFilterType(rawValue: filterTypeStr)!
        streamViewController.streamKind = .Notifications(category: filterType.category)
        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.loadInitialPage()
    }

    public func commentTapped(comment: Comment) {
        if let post = comment.parentPost {
            postTapped(post)
        }
        else {
            postTapped(postId: comment.postId)
        }
    }

    public func respondToNotification(components: [String]) {
        var popToRoot: Bool = true
        if let path = components.safeValue(0) {
            switch path {
            case "posts":
                if let id = components.safeValue(1) {
                    popToRoot = false
                    postTapped(postId: id)
                }
            case "users":
                if let id = components.safeValue(1) {
                    popToRoot = false
                    userParamTapped(id)
                }
            default:
                break
            }
        }

        if popToRoot {
            navigationController?.popToRootViewControllerAnimated(true)
        }

        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.loadInitialPage()
    }

}
