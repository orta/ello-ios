//
//  UserListViewController.swift
//  Ello
//
//  Created by Ryan Boyajian on 3/5/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

class UserListViewController: StreamableViewController {

    var streamViewController : StreamViewController!
    var navigationBar: ElloNavigationBar!
    let endpoint: ElloAPI

    required init(endpoint: ElloAPI, title: String) {
        self.endpoint = endpoint
        super.init(nibName: nil, bundle: nil)
        self.title = title
        self.view.backgroundColor = UIColor.whiteColor()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupStreamController()
    }

    override func didSetCurrentUser() {
        if self.isViewLoaded() {
            streamViewController.currentUser = currentUser
        }
        super.didSetCurrentUser()
    }

    // MARK: Private

    private func setupNavigationBar() {
        navigationBar = ElloNavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: ElloNavigationBar.Size.height))
        navigationBar.autoresizingMask = .FlexibleBottomMargin | .FlexibleWidth
        self.view.addSubview(navigationBar)
        let item = UIBarButtonItem.backChevronWithTarget(self, action: "backTapped:")
        self.navigationItem.leftBarButtonItems = [item]
        self.fixNavBarItemPadding()
        navigationBar.items = [self.navigationItem]
    }

    private func setupStreamController() {
        streamViewController = StreamViewController.instantiateFromStoryboard()
        streamViewController.currentUser = currentUser
        streamViewController.streamKind = .UserList(endpoint: endpoint, title: self.title!)
        streamViewController.userTappedDelegate = self

        self.view.addSubview(streamViewController.view)
        streamViewController.willMoveToParentViewController(self)
        streamViewController.view.frame = self.view.bounds
        streamViewController.view.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        self.addChildViewController(streamViewController)

        streamViewController.loadInitialPage()
    }

    override func showNavBars(scrollToBottom : Bool) {
        super.showNavBars(scrollToBottom)
        navigationBar.frame = navigationBar.frame.atY(0)
        streamViewController.view.frame = navigationBar.frame.fromBottom().shiftDown(1).withHeight(self.view.frame.height - navigationBar.frame.height)

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