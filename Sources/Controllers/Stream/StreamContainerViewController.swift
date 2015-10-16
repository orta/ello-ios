//
//  StreamContainerViewController.swift
//  Ello
//
//  Created by Sean on 1/17/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import UIKit
import SVGKit

public class StreamContainerViewController: StreamableViewController {
    private var loggedPromptEventForThisSession = false
    private var noiseLoaded = false
    private var reloadStreamContentObserver: NotificationObserver?
    private var friendsViewController: StreamViewController?
    private var appBackgroundObserver: NotificationObserver?
    private var appForegroundObserver: NotificationObserver?

    enum Notifications : String {
        case StreamDetailTapped = "StreamDetailTappedNotification"
    }

    override public var tabBarItem: UITabBarItem? {
        get { return UITabBarItem.svgItem("circbig") }
        set { self.tabBarItem = newValue }
    }

    @IBOutlet weak public var scrollView: UIScrollView!
    weak public var navigationBar: ElloNavigationBar!
    @IBOutlet weak public var navigationBarTopConstraint: NSLayoutConstraint!

    public var streamsSegmentedControl: UISegmentedControl!
    public var streamControllerViews:[UIView] = []

    private var childStreamControllers: [StreamViewController] {
        return childViewControllers as! [StreamViewController]
    }

    deinit {
        removeTemporaryNotificationObservers()
        removeNotificationObservers()
    }

    override public func backGestureAction() {
        hamburgerButtonTapped()
    }

    override func setupStreamController() { /* intentially left blank */ }

    override public func viewDidLoad() {
        super.viewDidLoad()
        addNotificationObservers()
        setupStreamsSegmentedControl()
        setupChildViewControllers()
        elloNavigationItem.titleView = streamsSegmentedControl
        elloNavigationItem.leftBarButtonItem = UIBarButtonItem(image: SVGKImage(named: "burger_normal.svg").UIImage!, style: .Done, target: self, action: Selector("hamburgerButtonTapped"))
        addSearchButton()
        navigationBar.items = [elloNavigationItem]

        let initialStream = childStreamControllers[0]
        scrollLogic.prevOffset = initialStream.collectionView.contentOffset
        initialStream.collectionView.scrollsToTop = true

        let stream = StreamKind.streamValues[0]
        Tracker.sharedTracker.streamAppeared(stream.name)
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        addTemporaryNotificationObservers()
        if !loggedPromptEventForThisSession {
            Rate.sharedRate.logEvent()
            loggedPromptEventForThisSession = true
        }
    }

    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        removeNotificationObservers()
    }

    private func updateInsets() {
        for controller in self.childViewControllers as! [StreamViewController] {
            updateInsets(navBar: navigationBar, streamController: controller)
        }
    }

    override public func showNavBars(scrollToBottom : Bool) {
        super.showNavBars(scrollToBottom)
        positionNavBar(navigationBar, visible: true, withConstraint: navigationBarTopConstraint)
        updateInsets()

        if scrollToBottom {
            for controller in childStreamControllers {
                self.scrollToBottom(controller)
            }
        }
    }

    override public func hideNavBars() {
        super.hideNavBars()
        positionNavBar(navigationBar, visible: false, withConstraint: navigationBarTopConstraint)
        updateInsets()
    }

    public class func instantiateFromStoryboard() -> StreamContainerViewController {
        let navController = UIStoryboard.storyboardWithId(.StreamContainer) as! UINavigationController
        let streamsController = navController.topViewController
        return streamsController as! StreamContainerViewController
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let width: CGFloat = view.bounds.size.width
        let height: CGFloat = view.bounds.size.height

        for (index, view) in streamControllerViews.enumerate() {
            view.frame = CGRect(x: width * CGFloat(index), y: 0, width: width, height: height)
        }

        scrollView.contentSize = CGSize(width: width * CGFloat(StreamKind.streamValues.count), height: height)

        let selectedIndex = streamsSegmentedControl.selectedSegmentIndex
        let x = CGFloat(selectedIndex) * width
        let rect = CGRect(x: x, y: 0, width: width, height: height)
        scrollView.scrollRectToVisible(rect, animated: false)

    }

    private func setupChildViewControllers() {
        scrollView.scrollEnabled = false
        scrollView.scrollsToTop = false
        let width:CGFloat = scrollView.frame.size.width
        let height:CGFloat = scrollView.frame.size.height

        for (index, kind) in StreamKind.streamValues.enumerate() {
            let vc = StreamViewController.instantiateFromStoryboard()
            vc.currentUser = currentUser
            vc.streamKind = kind
            vc.createPostDelegate = self
            vc.postTappedDelegate = self
            vc.userTappedDelegate = self
            vc.streamScrollDelegate = self
            vc.collectionView.scrollsToTop = false

            vc.willMoveToParentViewController(self)

            let x = CGFloat(index) * width
            let frame = CGRect(x: x, y: 0, width: width, height: height)
            vc.view.frame = frame
            scrollView.addSubview(vc.view)
            streamControllerViews.append(vc.view)

            self.addChildViewController(vc)
            vc.didMoveToParentViewController(self)
            ElloHUD.showLoadingHudInView(vc.view)

            switch kind {
            case .Following:
                let noResultsTitle = NSLocalizedString("Welcome to your Friends Stream!", comment: "No friend results title")
                let noResultsBody = NSLocalizedString("You aren't following anyone in Friends yet.\n\nWhen you follow someone as a Friend their posts will show up here. Ello is way more rad when you're following lots of people.\n\nUse Discover to find people you're interested in, and to find or invite your friends.", comment: "No friend results body.")
                friendsViewController = vc
                vc.noResultsMessages = (title: noResultsTitle, body: noResultsBody)
                vc.loadInitialPage()
            case .Starred:
                let noResultsTitle = NSLocalizedString("Welcome to your Noise Stream!", comment: "No noise results title")
                let noResultsBody = NSLocalizedString("You aren't following anyone in Noise yet.\n\nWhen you follow someone as Noise their posts will show up here. Ello is way more rad when you're following lots of people.\n\nUse Discover to find people you're interested in, and to find or invite your friends.", comment: "No noise results body.")
                vc.noResultsMessages = (title: noResultsTitle, body: noResultsBody)
            default:
                break
            }
        }
    }

    private func setupStreamsSegmentedControl() {
        let control = UISegmentedControl(items: StreamKind.streamValues.map{ $0.name })
        control.addTarget(self, action: Selector("streamSegmentTapped:"), forControlEvents: .ValueChanged)
        control.frame.size.height = 19.0
        control.layer.borderWidth = 1.0
        control.selectedSegmentIndex = 0
        control.tintColor = .blackColor()
        streamsSegmentedControl = control
    }

    // MARK: - IBActions

    @IBAction func hamburgerButtonTapped() {
        let drawer = DrawerViewController()
        drawer.currentUser = currentUser

        self.navigationController?.pushViewController(drawer, animated: true)
    }

    @IBAction func streamSegmentTapped(sender: UISegmentedControl) {
        for controller in childStreamControllers {
            controller.collectionView.scrollsToTop = false
        }

        let selectedIndex = streamsSegmentedControl.selectedSegmentIndex
        childStreamControllers[selectedIndex].collectionView.scrollsToTop = true

        let width:CGFloat = view.bounds.size.width
        let height:CGFloat = view.bounds.size.height
        let x = CGFloat(selectedIndex) * width
        let rect = CGRect(x: x, y: 0, width: width, height: height)
        scrollView.scrollRectToVisible(rect, animated: true)

        let stream = StreamKind.streamValues[selectedIndex]
        Tracker.sharedTracker.streamAppeared(stream.name)

        if selectedIndex == 1 && !noiseLoaded {
            noiseLoaded = true
            childStreamControllers[1].loadInitialPage()
        }
    }
}

private extension StreamContainerViewController {

    func addTemporaryNotificationObservers() {
        reloadStreamContentObserver = NotificationObserver(notification: NewContentNotifications.reloadStreamContent) {
            [unowned self] _ in
            if let vc = self.friendsViewController {
                ElloHUD.showLoadingHudInView(vc.view)
                vc.loadInitialPage()
            }
        }
    }

    func removeTemporaryNotificationObservers() {
        reloadStreamContentObserver?.removeObserver()
    }

    func addNotificationObservers() {
        appBackgroundObserver = NotificationObserver(notification: Application.Notifications.DidEnterBackground) {
            [unowned self] _ in
            self.loggedPromptEventForThisSession = false
        }
    }

    func removeNotificationObservers() {
        appBackgroundObserver?.removeObserver()
    }
}
