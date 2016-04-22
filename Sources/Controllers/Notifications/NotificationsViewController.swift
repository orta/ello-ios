//
//  NotificationsViewController.swift
//  Ello
//
//  Created by Sean Dougherty on 11/20/14.
//  Copyright (c) 2014 Ello. All rights reserved.
//

import WebKit

public class NotificationsViewController: StreamableViewController, NotificationDelegate, NotificationsScreenDelegate {

    private var hasNewContent = false
    var fromTabBar = false
    private var reloadNotificationsObserver: NotificationObserver?
    public var categoryFilterType = NotificationFilterType.All

    override public var tabBarItem: UITabBarItem? {
        get { return UITabBarItem.item(.Bolt) }
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
        addNotificationObservers()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        navigationNotificationObserver?.removeObserver()
        reloadNotificationsObserver?.removeObserver()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        screen.delegate = self
        self.title = InterfaceString.Notifications.Title
        addSearchButton()

        scrollLogic.prevOffset = streamViewController.collectionView.contentOffset
        scrollLogic.navBarHeight = 44

        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.loadInitialPage()
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true

        if hasNewContent && fromTabBar {
            ElloHUD.showLoadingHudInView(streamViewController.view)
            streamViewController.loadInitialPage()
            hasNewContent = false
        }
        fromTabBar = false

        PushNotificationController.sharedController.updateBadgeCount(0)
    }

    override func setupStreamController() {
        super.setupStreamController()

        streamViewController.streamKind = .Notifications(category: categoryFilterType.category)
        streamViewController.notificationDelegate = self
        let noResultsTitle = InterfaceString.Notifications.NoResultsTitle
        let noResultsBody = InterfaceString.Notifications.NoResultsBody
        streamViewController.noResultsMessages = (title: noResultsTitle, body: noResultsBody)
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


    // used to provide StreamableViewController access to the container it then
    // loads the StreamViewController's content into
    override func viewForStream() -> UIView {
        return self.screen.streamContainer
    }

    public func activatedCategory(filterTypeStr: String) {
        let filterType = NotificationFilterType(rawValue: filterTypeStr)!
        activatedCategory(filterType)
    }

    public func activatedCategory(filterType: NotificationFilterType) {
        screen.selectFilterButton(filterType)
        streamViewController.streamKind = .Notifications(category: filterType.category)
        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.hideNoResults()
        streamViewController.removeAllCellItems()
        streamViewController.loadInitialPage()
        if filterType == .All {
            hasNewContent = false
        }
    }

    public func commentTapped(comment: ElloComment) {
        if let post = comment.loadedFromPost {
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
        self.hasNewContent = false
    }

}

private extension NotificationsViewController {

    func addNotificationObservers() {
        navigationNotificationObserver = NotificationObserver(notification: NavigationNotifications.showingNotificationsTab) { [unowned self] components in
            self.respondToNotification(components)
        }

        reloadNotificationsObserver = NotificationObserver(notification: NewContentNotifications.reloadNotifications) {
            [unowned self] _ in
            ElloHUD.showLoadingHudInView(self.streamViewController.view)
            self.streamViewController.loadInitialPage()
            self.hasNewContent = false
        }
    }

    func updateInsets() {
        updateInsets(navBar: screen.filterBar, streamController: streamViewController)
    }
}
