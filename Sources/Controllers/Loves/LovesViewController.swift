//
//  LovesViewController.swift
//  Ello
//
//  Created by Sean on 5/15/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

public class LovesViewController: StreamableViewController {

    var user: User
    var navigationBar: ElloNavigationBar!

    required public init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        self.title = NSLocalizedString("Loves", comment: "love stream")
        view.backgroundColor = .whiteColor()
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        scrollLogic.prevOffset = streamViewController.collectionView.contentOffset
        scrollLogic.navBarHeight = 44
        streamViewController.streamKind = StreamKind.Loves(userId: self.user.id)
        ElloHUD.showLoadingHudInView(streamViewController.view)
        streamViewController.loadInitialPage()
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateInsets()
    }

    private func updateInsets() {
        updateInsets(navBar: navigationBar, streamController: streamViewController)
    }

    override func viewForStream() -> UIView {
        return view
    }

    override public func didSetCurrentUser() {
        if isViewLoaded() {
            streamViewController.currentUser = currentUser
        }
        super.didSetCurrentUser()
        let noResultsTitle: String
        let noResultsBody: String
        if user.isCurrentUser {
            noResultsTitle = NSLocalizedString("You haven't Loved any posts yet!", comment: "No loves results title")
            noResultsBody = NSLocalizedString("You can use Ello Loves as a way to bookmark the things you care about most. Go Love someone's post, and it will be added to this stream.", comment: "No loves results body.")
        }
        else {
            noResultsTitle = NSLocalizedString("This person hasn’t Loved any posts yet!", comment: "No loves results title")
            noResultsBody = NSLocalizedString("Ello Loves are a way to bookmark the things you care about most. When they love something the posts will appear here.", comment: "No loves results body.")
        }
        streamViewController.noResultsMessages = (title: noResultsTitle, body: noResultsBody)
    }

    override public func hideNavBars() {
        super.hideNavBars()
        positionNavBar(navigationBar, visible: false)
        updateInsets(navBar: navigationBar, streamController: streamViewController, navBarsVisible: false)
    }

// MARK: Private

    private func setupNavigationBar() {
        navigationBar = ElloNavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: ElloNavigationBar.Size.height))
        navigationBar.autoresizingMask = .FlexibleBottomMargin | .FlexibleWidth
        view.addSubview(navigationBar)
        let item = UIBarButtonItem.backChevronWithTarget(self, action: Selector("backTapped:"))
        navigationItem.leftBarButtonItems = [item]
        navigationItem.fixNavBarItemPadding()
        navigationBar.items = [navigationItem]
    }

    override func showNavBars(scrollToBottom : Bool) {
        super.showNavBars(scrollToBottom)
        animate {
            self.navigationBar.frame = self.navigationBar.frame.atY(0)
        }
        updateInsets()
        if scrollToBottom {
            if let scrollView = streamViewController.collectionView {
                let contentOffsetY : CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
                if contentOffsetY > 0 {
                    scrollView.scrollEnabled = false
                    scrollView.setContentOffset(CGPoint(x: 0, y: contentOffsetY), animated: true)
                    scrollView.scrollEnabled = true
                }
            }
        }
    }
}
